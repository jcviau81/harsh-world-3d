## ChunkLoader - Loads chunks with heightmaps, assigns biomes, and spawns objects
## Demonstrates integration of TerrainGenerator, BiomeResourceSpawner, and WorldObject

class_name ChunkLoader
extends Node

# ============================================
# EXPORTED PROPERTIES
# ============================================

@export var terrain_generator: TerrainGenerator
@export var base_seed: int = 12345

# ============================================
# PUBLIC METHODS
# ============================================

func load_chunk(chunk_x: int, chunk_y: int) -> ChunkData:
	"""
	Load a complete chunk with heightmap, biome assignment, and object spawning.

	Args:
		chunk_x: Chunk grid X coordinate
		chunk_y: Chunk grid Y coordinate

	Returns:
		ChunkData with loaded heightmap, biome, and spawned objects
	"""

	# Create chunk data container with unique per-chunk seed
	var chunk_seed = base_seed ^ chunk_x ^ chunk_y
	var chunk_data = ChunkData.new(chunk_x, chunk_y, chunk_seed)

	# Step 1: Generate heightmap from GPU
	if terrain_generator == null:
		push_error("ChunkLoader: terrain_generator not assigned")
		return chunk_data

	var heightmap = terrain_generator.generate_heightmap(chunk_x, chunk_y, base_seed)
	if heightmap.is_empty():
		push_error("ChunkLoader: Failed to generate heightmap for chunk (%d, %d)" % [chunk_x, chunk_y])
		return chunk_data

	chunk_data.set_heightmap(heightmap)

	# Step 2: Assign biome type based on heightmap
	var biome_type = _assign_biome_from_heightmap(heightmap)
	chunk_data.set_biome_type(biome_type)

	# Step 3: Spawn objects via BiomeResourceSpawner
	var spawned_objects = BiomeResourceSpawner.spawn_resources_for_chunk(
		chunk_x, chunk_y, base_seed, biome_type
	)

	# Step 4: Add objects to chunk data and add to scene
	for obj in spawned_objects:
		chunk_data.add_object(obj.object_type, obj.position)
		chunk_data.add_instance(obj)
		add_child(obj)  # Add to scene tree

	# Step 5: Mark chunk as loaded
	chunk_data.mark_loaded()

	print("ChunkLoader: Loaded chunk (%d,%d) with %d objects (Biome: %s)" % [
		chunk_x, chunk_y, spawned_objects.size(), biome_type
	])

	return chunk_data


func unload_chunk(chunk_data: ChunkData) -> void:
	"""
	Unload chunk and clean up objects.

	Args:
		chunk_data: ChunkData to unload
	"""

	# Remove all object instances
	for obj in chunk_data.object_instances:
		if obj and is_instance_valid(obj):
			obj.queue_free()

	chunk_data.object_instances.clear()
	chunk_data.is_loaded = false

	print("ChunkLoader: Unloaded chunk (%d,%d)" % [chunk_data.chunk_x, chunk_data.chunk_y])


# ============================================
# PRIVATE HELPER METHODS
# ============================================

static func _assign_biome_from_heightmap(heightmap: PackedFloat32Array) -> String:
	"""
	Assign biome type based on heightmap characteristics.

	Simple algorithm:
	- Low heights (0.0-0.3) → coastal_beach
	- Medium-low (0.3-0.5) → grassland
	- Medium-high (0.5-0.7) → temperate_forest
	- High (0.7+) → mountain_range

	Args:
		heightmap: Heightmap array

	Returns:
		Biome type string
	"""

	if heightmap.is_empty():
		return "temperate_forest"  # Default

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
