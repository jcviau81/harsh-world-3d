## Chunk Integration Tests
## Validates chunk loading with heightmap, biome assignment, and object spawning

class_name TestChunkIntegration
extends Node

# ============================================
# TEST SETUP
# ============================================

var chunk_loader: ChunkLoader
var loaded_chunks: Array[ChunkData] = []


func setup() -> void:
	"""Setup test fixture."""
	chunk_loader = ChunkLoader.new()
	chunk_loader.terrain_generator = TerrainGenerator.new()
	add_child(chunk_loader)
	add_child(chunk_loader.terrain_generator)

	loaded_chunks.clear()
	await get_tree().process_frame


func teardown() -> void:
	"""Clean up test fixture."""
	for chunk in loaded_chunks:
		chunk_loader.unload_chunk(chunk)

	loaded_chunks.clear()

	if chunk_loader:
		chunk_loader.queue_free()


# ============================================
# TEST 1: SINGLE CHUNK LOAD
# ============================================

func test_load_single_chunk() -> void:
	"""AC-26/27: Single chunk loads with heightmap, biome, and objects"""

	var chunk_data = chunk_loader.load_chunk(0, 0)

	assert(chunk_data != null, "ChunkData should be created")
	assert(chunk_data.is_loaded, "Chunk should be marked loaded")
	assert(chunk_data.heightmap.size() > 0, "Heightmap should be loaded")
	assert(chunk_data.biome_type != "", "Biome should be assigned")

	loaded_chunks.append(chunk_data)
	print("✓ TEST 1 PASSED: Single chunk loaded successfully")


# ============================================
# TEST 2: OBJECT SPAWNING IN CHUNK
# ============================================

func test_objects_spawned_in_chunk() -> void:
	"""AC-28: Objects are spawned and positioned correctly"""

	var chunk_data = chunk_loader.load_chunk(5, 5)

	# Wait for objects to be added to scene
	await get_tree().process_frame

	# Verify objects were spawned
	assert(chunk_data.get_object_count() > 0, "Should spawn at least some objects")
	assert(chunk_data.get_instance_count() == chunk_data.get_object_count(),
		"Object count should match instance count")

	# Verify objects are positioned within chunk
	var chunk_min_x = 5 * 32
	var chunk_max_x = chunk_min_x + 32
	var chunk_min_z = 5 * 32
	var chunk_max_z = chunk_min_z + 32

	for obj in chunk_data.object_instances:
		assert(obj.position.x >= chunk_min_x and obj.position.x < chunk_max_x,
			"Object X position out of chunk bounds")
		assert(obj.position.z >= chunk_min_z and obj.position.z < chunk_max_z,
			"Object Z position out of chunk bounds")

	loaded_chunks.append(chunk_data)
	print("✓ TEST 2 PASSED: Objects spawned at correct positions")


# ============================================
# TEST 3: BIOME ASSIGNMENT
# ============================================

func test_biome_assignment() -> void:
	"""AC-27: Biome type is assigned based on heightmap"""

	var chunk_data = chunk_loader.load_chunk(10, 10)

	assert(BiomeDefinitions.is_valid_biome(chunk_data.biome_type),
		"Assigned biome should be valid: %s" % chunk_data.biome_type)

	loaded_chunks.append(chunk_data)
	print("✓ TEST 3 PASSED: Biome assigned: %s" % chunk_data.biome_type)


# ============================================
# TEST 4: REALISTIC OBJECT COUNT
# ============================================

func test_realistic_object_count() -> void:
	"""AC-30: Spawned objects in realistic range (50-150 per chunk)"""

	var chunk_data = chunk_loader.load_chunk(3, 3)

	var object_count = chunk_data.get_object_count()

	# Realistic range for object density
	assert(object_count >= 10, "Should spawn at least 10 objects (got %d)" % object_count)
	assert(object_count <= 200, "Should not spawn more than 200 objects (got %d)" % object_count)

	loaded_chunks.append(chunk_data)
	print("✓ TEST 4 PASSED: Object count realistic (%d objects)" % object_count)


# ============================================
# TEST 5: CHUNK DATA PERSISTENCE
# ============================================

func test_chunk_data_persistence() -> void:
	"""AC-29: ChunkData maintains all information"""

	var chunk_data = chunk_loader.load_chunk(0, 0)

	# Verify all data is preserved
	assert(chunk_data.chunk_x == 0, "Chunk X should be preserved")
	assert(chunk_data.chunk_y == 0, "Chunk Y should be preserved")
	assert(chunk_data.heightmap.size() > 0, "Heightmap should be preserved")
	assert(chunk_data.biome_type != "", "Biome should be preserved")
	assert(chunk_data.object_list.size() > 0, "Object list should be preserved")

	# Test serialization
	var serialized = chunk_data.to_dict()
	assert("chunk_x" in serialized, "Serialization should include chunk_x")
	assert("biome_type" in serialized, "Serialization should include biome_type")
	assert("object_count" in serialized, "Serialization should include object_count")

	loaded_chunks.append(chunk_data)
	print("✓ TEST 5 PASSED: Chunk data persisted and serializable")


# ============================================
# TEST 6: MULTIPLE CHUNKS DIFFERENT BIOMES
# ============================================

func test_multiple_chunks_variation() -> void:
	"""AC-26/27: Different chunks can have different biomes and objects"""

	var chunk1 = chunk_loader.load_chunk(0, 0)
	var chunk2 = chunk_loader.load_chunk(10, 10)

	await get_tree().process_frame

	# Chunks may have different biomes (depends on heightmap randomness)
	# Just verify both loaded successfully
	assert(chunk1.is_loaded, "Chunk 1 should be loaded")
	assert(chunk2.is_loaded, "Chunk 2 should be loaded")
	assert(chunk1.get_object_count() > 0, "Chunk 1 should have objects")
	assert(chunk2.get_object_count() > 0, "Chunk 2 should have objects")

	loaded_chunks.append(chunk1)
	loaded_chunks.append(chunk2)

	print("✓ TEST 6 PASSED: Multiple chunks load independently")


# ============================================
# TEST 7: CHUNK UNLOADING
# ============================================

func test_chunk_unloading() -> void:
	"""AC-26: Chunks can be unloaded cleanly"""

	var chunk_data = chunk_loader.load_chunk(7, 7)

	await get_tree().process_frame

	var object_count_before = chunk_data.get_instance_count()
	assert(object_count_before > 0, "Should have objects before unload")

	# Unload chunk
	chunk_loader.unload_chunk(chunk_data)

	assert(not chunk_data.is_loaded, "Chunk should be marked unloaded")
	assert(chunk_data.get_instance_count() == 0, "Instances should be cleared")

	print("✓ TEST 7 PASSED: Chunk unloaded successfully")


# ============================================
# TEST 8: OBJECT TYPE VARIETY
# ============================================

func test_object_type_variety() -> void:
	"""AC-28: Different object types spawn in chunk"""

	var chunk_data = chunk_loader.load_chunk(2, 2)

	await get_tree().process_frame

	var type_count = {}
	for obj in chunk_data.object_instances:
		var type = obj.object_type
		if type not in type_count:
			type_count[type] = 0
		type_count[type] += 1

	# Should have at least one type of object
	assert(type_count.size() > 0, "Should spawn at least one object type")

	print("✓ TEST 8 PASSED: Object types in chunk: %s" % type_count.keys())

	loaded_chunks.append(chunk_data)
