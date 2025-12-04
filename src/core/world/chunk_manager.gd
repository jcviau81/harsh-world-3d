## ChunkManager - Manages chunk loading/unloading based on player position
## Implements streaming with async loading and delta persistence

class_name ChunkManager
extends Node

# ============================================
# EXPORTED PROPERTIES
# ============================================

@export var streaming_radius: int = 3
@export var chunk_size: int = 32
@export var base_seed: int = 12345

# ============================================
# PROPERTIES
# ============================================

var player: Node3D
var terrain_generator: Node  # Cache to avoid thread issues
var biome_spawner: Node  # Cache to avoid thread issues
var biome_generator: BiomeGenerator  # NEW: Biome assignment system
var loaded_chunks: Dictionary = {}  # {Vector2i: ChunkData}
var pending_threads: Array = []  # [{thread, chunk_x, chunk_y}]
var active_chunks: Array[Vector2i] = []

# ============================================
# LIFECYCLE
# ============================================

func _ready() -> void:
	"""Initialize and connect to player/terrain generator on scene ready."""
	# Find player in scene
	if not player:
		player = get_parent().get_node_or_null("Player")
		if not player:
			push_warning("ChunkManager: Could not find Player node - streaming disabled until set_player() called")

	# Find TerrainGenerator (can be anywhere in scene tree)
	if not terrain_generator:
		terrain_generator = _get_terrain_generator()
		if not terrain_generator:
			push_warning("ChunkManager: Could not find TerrainGenerator - chunk generation disabled until assigned")

	# Initialize biome system (NEW in Story 2.1)
	BiomeDefinitions.initialize()
	biome_generator = BiomeGenerator.new()
	biome_generator._ready()


func _init() -> void:
	"""Initialize ChunkManager."""
	pass


func set_player(p_player: Node3D) -> void:
	"""Set the player node to track position.

	Args:
		p_player: Player Node3D to track
	"""
	player = p_player


func _process(delta: float) -> void:
	"""Process frame: update streaming and check pending threads."""
	if not player or not terrain_generator:
		return

	# Update streaming based on current player position
	update_streaming()

	# Check pending threads for completion
	_process_pending_threads()


# ============================================
# STREAMING OPERATIONS
# ============================================

func update_streaming() -> void:
	"""Update active chunks based on player position and streaming radius.

	Uses async loading to prevent main thread stalls. Preloads radius+1 ahead.
	"""
	if not player:
		return

	var new_active = get_active_chunks()

	# Unload chunks no longer in range
	for chunk_coord in loaded_chunks.keys():
		if chunk_coord not in new_active:
			var chunk = loaded_chunks[chunk_coord]
			unload_chunk(chunk)
			loaded_chunks.erase(chunk_coord)

	# Queue async loads for chunks now in range (but not yet loaded)
	for chunk_coord in new_active:
		if chunk_coord not in loaded_chunks:
			# Check if already pending
			var already_pending = false
			for pending in pending_threads:
				if pending["chunk_x"] == chunk_coord.x and pending["chunk_y"] == chunk_coord.y:
					already_pending = true
					break

			if not already_pending:
				load_chunk_async(chunk_coord.x, chunk_coord.y)

	active_chunks = new_active


func get_active_chunks() -> Array[Vector2i]:
	"""Calculate active chunks based on player position.

	Returns:
		Array of Vector2i chunk coordinates in streaming radius
	"""
	if not player:
		return []

	var player_chunk_x = int(player.position.x / chunk_size)
	var player_chunk_y = int(player.position.z / chunk_size)

	var active: Array[Vector2i] = []
	for x in range(player_chunk_x - streaming_radius, player_chunk_x + streaming_radius + 1):
		for y in range(player_chunk_y - streaming_radius, player_chunk_y + streaming_radius + 1):
			active.append(Vector2i(x, y))

	return active


# ============================================
# CHUNK LOADING / UNLOADING
# ============================================

func load_chunk(chunk_x: int, chunk_y: int) -> ChunkData:
	"""Load a chunk synchronously.

	Args:
		chunk_x: Chunk grid X coordinate
		chunk_y: Chunk grid Y coordinate

	Returns:
		ChunkData for the loaded chunk
	"""
	var chunk_seed = get_chunk_seed(chunk_x, chunk_y)
	var chunk_data = ChunkData.new()
	chunk_data.chunk_x = chunk_x
	chunk_data.chunk_y = chunk_y
	chunk_data.chunk_seed = chunk_seed

	# Check if chunk exists on disk
	var chunk_path = "user://saves/chunks/%d_%d.tres" % [chunk_x, chunk_y]
	if ResourceLoader.exists(chunk_path):
		chunk_data = ResourceLoader.load(chunk_path)
	else:
		# Generate new chunk from seed
		_generate_chunk_from_seed(chunk_data)

	chunk_data.mark_loaded()
	return chunk_data


func load_chunk_async(chunk_x: int, chunk_y: int) -> Thread:
	"""Load a chunk asynchronously using background thread.

	Args:
		chunk_x: Chunk grid X coordinate
		chunk_y: Chunk grid Y coordinate

	Returns:
		Thread object for async loading
	"""
	var thread = Thread.new()
	thread.start(Callable(self, "_load_chunk_in_thread").bindv([chunk_x, chunk_y]))
	pending_threads.append({
		"thread": thread,
		"chunk_x": chunk_x,
		"chunk_y": chunk_y
	})
	return thread


func unload_chunk(chunk_data: ChunkData) -> void:
	"""Unload chunk and clean up objects.

	Args:
		chunk_data: ChunkData to unload
	"""
	# Remove all object instances from scene
	for obj in chunk_data.object_instances:
		if obj and is_instance_valid(obj):
			obj.queue_free()

	chunk_data.object_instances.clear()
	chunk_data.is_loaded = false


func get_loaded_chunks() -> Array[ChunkData]:
	"""Get all currently loaded chunks.

	Returns:
		Array of loaded ChunkData
	"""
	var result: Array[ChunkData] = []
	for chunk in loaded_chunks.values():
		result.append(chunk)
	return result


func get_pending_chunks() -> Array:
	"""Get pending async load operations.

	Returns:
		Array of pending operations
	"""
	return pending_threads.duplicate()


# ============================================
# CHUNK PERSISTENCE
# ============================================

func save_chunk(chunk_data: ChunkData) -> bool:
	"""Save a single chunk to disk (only if modified).

	Args:
		chunk_data: ChunkData to save

	Returns:
		True if saved, false if skipped or failed
	"""
	# Skip unmodified chunks
	if not chunk_data.is_modified:
		return false

	# Ensure save directory exists
	var save_dir = "user://saves/chunks/"
	if not DirAccess.dir_exists_absolute(save_dir):
		DirAccess.make_dir_absolute(save_dir)

	# Save chunk as .tres resource
	var chunk_path = "%s%d_%d.tres" % [save_dir, chunk_data.chunk_x, chunk_data.chunk_y]

	var error = ResourceSaver.save(chunk_data, chunk_path)
	if error != OK:
		push_error("ChunkManager: Failed to save chunk (%d, %d): %s" % [
			chunk_data.chunk_x, chunk_data.chunk_y, error_string(error)
		])
		return false

	chunk_data.is_modified = false
	return true


func save_all_chunks() -> int:
	"""Save all modified chunks to disk.

	Returns:
		Number of chunks saved
	"""
	var saved_count = 0

	for chunk in loaded_chunks.values():
		if save_chunk(chunk):
			saved_count += 1

	return saved_count


# ============================================
# CHUNK SEEDING
# ============================================

func get_chunk_seed(chunk_x: int, chunk_y: int) -> int:
	"""Generate deterministic seed for chunk.

	Args:
		chunk_x: Chunk grid X coordinate
		chunk_y: Chunk grid Y coordinate

	Returns:
		Deterministic seed value
	"""
	return base_seed ^ (chunk_x << 16) ^ chunk_y


# ============================================
# PRIVATE METHODS
# ============================================

func _load_chunk_in_thread(chunk_x: int, chunk_y: int) -> ChunkData:
	"""Load chunk from disk in background thread (generation happens on main thread).

	Args:
		chunk_x: Chunk grid X coordinate
		chunk_y: Chunk grid Y coordinate

	Returns:
		ChunkData loaded from disk, or empty if not found (will be generated on main thread)
	"""
	var chunk_seed = get_chunk_seed(chunk_x, chunk_y)
	var chunk_data = ChunkData.new()
	chunk_data.chunk_x = chunk_x
	chunk_data.chunk_y = chunk_y
	chunk_data.chunk_seed = chunk_seed

	# Background thread: only load from disk, never generate
	var chunk_path = "user://saves/chunks/%d_%d.tres" % [chunk_x, chunk_y]
	if ResourceLoader.exists(chunk_path):
		chunk_data = ResourceLoader.load(chunk_path)
		chunk_data.mark_loaded()
		return chunk_data

	# Not on disk - return empty, will generate on main thread
	return chunk_data


func _process_pending_threads() -> void:
	"""Check pending threads and add completed chunks to scene.

	Threads only load from disk. If chunk not found, generate on main thread.
	"""
	var completed = []

	for i in range(pending_threads.size()):
		var pending = pending_threads[i]
		var thread = pending["thread"]

		if not thread.is_alive():
			var chunk_data = thread.wait_to_finish()
			var coord = Vector2i(pending["chunk_x"], pending["chunk_y"])

			if chunk_data and coord not in loaded_chunks:
				# If chunk was not loaded from disk, generate it on main thread
				if not chunk_data.is_loaded:
					_generate_chunk_from_seed(chunk_data)
					chunk_data.mark_loaded()

				loaded_chunks[coord] = chunk_data
				_instantiate_chunk(chunk_data)

			completed.append(i)

	# Remove completed threads in reverse order
	completed.reverse()
	for i in completed:
		pending_threads.remove_at(i)


func _generate_chunk_from_seed(chunk_data: ChunkData) -> void:
	"""Generate chunk from seed using integrated systems.

	Args:
		chunk_data: ChunkData to populate with generated content

	Note: Must be called from main thread or cached generators won't be available
	"""
	# Step 1: Get cached TerrainGenerator reference (must be cached on main thread)
	if not terrain_generator:
		terrain_generator = _get_terrain_generator()
		if not terrain_generator:
			push_error("ChunkManager: Cannot find TerrainGenerator")
			return

	# Step 2: Generate heightmap
	var heightmap = terrain_generator.generate_heightmap(
		chunk_data.chunk_x, chunk_data.chunk_y, base_seed
	)
	chunk_data.set_heightmap(heightmap)

	# Step 3: Assign biome from heightmap using BiomeGenerator (Story 2.1)
	var biome_type = biome_generator.assign_biome_for_chunk(heightmap, chunk_data.chunk_x, chunk_data.chunk_y, base_seed)
	chunk_data.set_biome_type(biome_type)

	# Step 4: Spawn objects via BiomeResourceSpawner (static call - thread-safe)
	var spawned_objects = BiomeResourceSpawner.spawn_resources_for_chunk(
		chunk_data.chunk_x, chunk_data.chunk_y, chunk_data.chunk_seed, biome_type
	)

	# Step 5: Add objects to chunk data
	for obj in spawned_objects:
		chunk_data.add_object(obj.object_type, obj.position)
		chunk_data.add_instance(obj)


func _instantiate_chunk(chunk_data: ChunkData) -> void:
	"""Instantiate chunk in scene tree.

	Args:
		chunk_data: ChunkData with objects to instantiate
	"""
	# Add objects to scene tree
	for obj in chunk_data.object_instances:
		if obj and is_instance_valid(obj):
			add_child(obj)


func _get_terrain_generator() -> Node:
	"""Get TerrainGenerator from world or parent nodes.

	Returns:
		TerrainGenerator node or null
	"""
	# Search up the tree for TerrainGenerator
	var node = get_parent()
	while node:
		if node.has_method("generate_heightmap"):
			return node
		if node.has_node("TerrainGenerator"):
			return node.get_node("TerrainGenerator")
		node = node.get_parent()

	# Search all nodes as fallback
	for n in get_tree().get_nodes_in_group("terrain_generator"):
		if n.has_method("generate_heightmap"):
			return n

	return null


static func _assign_biome_from_heightmap(heightmap: PackedFloat32Array) -> String:
	"""Assign biome type based on heightmap characteristics.

	Args:
		heightmap: Heightmap array

	Returns:
		Biome type string
	"""
	if heightmap.is_empty():
		return "temperate_forest"

	# Calculate average height
	var sum = 0.0
	for height in heightmap:
		sum += height

	var avg_height = sum / float(heightmap.size())

	# Assign biome based on average height
	if avg_height < 0.3:
		return "coastal_beach"
	elif avg_height < 0.5:
		return "grassland"
	elif avg_height < 0.7:
		return "temperate_forest"
	else:
		return "mountain_range"
