## ChunkData - Container for chunk information
## Stores heightmap, biome, objects, and allows serialization
## Extends Resource for .tres persistence

class_name ChunkData
extends Resource

# ============================================
# PROPERTIES
# ============================================

@export var chunk_x: int = 0
@export var chunk_y: int = 0
@export var chunk_seed: int = 0

@export var heightmap: PackedFloat32Array = PackedFloat32Array()
@export var biome_type: String = "temperate_forest"

@export var object_list: Array[Dictionary] = []  # Array of {type, position, visual_id, health, ...}
var object_instances: Array[WorldObject] = []  # Runtime instances (not exported)

@export var is_loaded: bool = false
@export var is_modified: bool = false
@export var load_timestamp: float = 0.0


# ============================================
# LIFECYCLE
# ============================================

func _init(p_chunk_x: int = 0, p_chunk_y: int = 0, p_seed: int = 0) -> void:
	"""Initialize ChunkData.

	Args:
		p_chunk_x: Chunk grid X coordinate
		p_chunk_y: Chunk grid Y coordinate
		p_seed: Seed for this chunk
	"""
	chunk_x = p_chunk_x
	chunk_y = p_chunk_y
	chunk_seed = p_seed
	load_timestamp = Time.get_ticks_msec() / 1000.0


# ============================================
# HEIGHTMAP MANAGEMENT
# ============================================

func set_heightmap(hm: PackedFloat32Array) -> void:
	"""Set the heightmap for this chunk.

	Args:
		hm: Heightmap array (should be 1024 floats for 32x32 chunk)

	Note: Heightmap is immutable (generated from seed), does not mark chunk modified
	"""
	heightmap = hm


func get_heightmap() -> PackedFloat32Array:
	"""Get the heightmap."""
	return heightmap


func get_height_at_position(grid_x: int, grid_y: int) -> float:
	"""Get height at specific grid position.

	Args:
		grid_x: Grid X (0-31)
		grid_y: Grid Y (0-31)

	Returns:
		Height value (0.0-1.0)
	"""
	if grid_x < 0 or grid_x >= 32 or grid_y < 0 or grid_y >= 32:
		return 0.0

	var index = grid_y * 32 + grid_x
	if index < 0 or index >= heightmap.size():
		return 0.0

	return heightmap[index]


# ============================================
# BIOME MANAGEMENT
# ============================================

func set_biome_type(biome: String) -> void:
	"""Set the biome type for this chunk.

	Args:
		biome: Biome type string (e.g., "temperate_forest")

	Note: Biome is immutable (determined from heightmap seed), does not mark chunk modified
	"""
	if BiomeDefinitions.is_valid_biome(biome):
		biome_type = biome
	else:
		push_error("ChunkData: Invalid biome type '%s'" % biome)


func get_biome_type() -> String:
	"""Get the biome type."""
	return biome_type


# ============================================
# OBJECT MANAGEMENT
# ============================================

func add_object(object_type: String, position: Vector3, visual_id: int = 0) -> void:
	"""Add object definition to chunk data.

	Args:
		object_type: Object type (e.g., "tree", "rock")
		position: World position
		visual_id: Sprite variant ID
	"""
	var obj_data = {
		"type": object_type,
		"position": position,
		"visual_id": visual_id,
		"health": 100,
	}
	object_list.append(obj_data)
	is_modified = true


func clear_objects() -> void:
	"""Clear all object definitions from chunk data."""
	object_list.clear()
	object_instances.clear()
	is_modified = true


func add_instance(obj: WorldObject) -> void:
	"""Add runtime instance to chunk.

	Args:
		obj: WorldObject instance
	"""
	object_instances.append(obj)


func get_object_count() -> int:
	"""Get number of objects in chunk.

	Returns:
		Total object count
	"""
	return object_list.size()


func get_instance_count() -> int:
	"""Get number of instantiated objects.

	Returns:
		Runtime instance count
	"""
	return object_instances.size()


# ============================================
# SERIALIZATION (STUB FOR Story 5)
# ============================================

func to_dict() -> Dictionary:
	"""Serialize chunk data to dictionary.

	Returns:
		Dictionary representation of chunk data
	"""
	return {
		"chunk_x": chunk_x,
		"chunk_y": chunk_y,
		"chunk_seed": chunk_seed,
		"heightmap": heightmap.to_byte_array().hex_encode(),  # Store heightmap as hex-encoded bytes
		"biome_type": biome_type,
		"object_count": object_list.size(),
		"is_loaded": is_loaded,
		"load_timestamp": load_timestamp,
	}


func from_dict(data: Dictionary) -> void:
	"""Load chunk data from dictionary.

	Args:
		data: Dictionary with chunk data
	"""
	chunk_x = data.get("chunk_x", 0)
	chunk_y = data.get("chunk_y", 0)
	chunk_seed = data.get("chunk_seed", 0)
	biome_type = data.get("biome_type", "temperate_forest")
	is_loaded = data.get("is_loaded", false)
	load_timestamp = data.get("load_timestamp", 0.0)

	# Restore heightmap from hex-encoded bytes
	var heightmap_hex = data.get("heightmap", "")
	if heightmap_hex != "":
		var heightmap_bytes = heightmap_hex.hex_decode()
		# Properly convert bytes back to PackedFloat32Array
		heightmap = PackedFloat32Array()
		heightmap.resize(heightmap_bytes.size() / 4)
		for i in range(heightmap_bytes.size() / 4):
			var offset = i * 4
			var float_bytes = heightmap_bytes.slice(offset, offset + 4)
			heightmap[i] = float_bytes.decode_u32(0)


# ============================================
# UTILITY METHODS
# ============================================

func mark_loaded() -> void:
	"""Mark chunk as loaded."""
	is_loaded = true
	is_modified = false


func get_info_string() -> String:
	"""Get debug info string.

	Returns:
		Summary of chunk data
	"""
	return "Chunk(%d,%d) Biome:%s Objects:%d Instances:%d Loaded:%s" % [
		chunk_x, chunk_y, biome_type, get_object_count(), get_instance_count(), is_loaded
	]
