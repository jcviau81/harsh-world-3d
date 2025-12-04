## Biome Resource Spawner Tests
## Validates deterministic spawning and biome-based resource distribution

class_name TestBiomeResourceSpawner
extends Node

# ============================================
# CONSTANTS
# ============================================

const CHUNK_GRID_SIZE: int = 32

# ============================================
# TEST SETUP
# ============================================

var spawned_objects: Array[WorldObject] = []


func setup() -> void:
	"""Setup test fixture."""
	spawned_objects.clear()
	await get_tree().process_frame


func teardown() -> void:
	"""Clean up test fixture."""
	for obj in spawned_objects:
		if obj:
			obj.queue_free()
	spawned_objects.clear()


# ============================================
# TEST 1: SINGLE BIOME SPAWN
# ============================================

func test_spawn_forest_biome() -> void:
	"""AC-21: Spawner creates objects for forest biome"""

	var objects = BiomeResourceSpawner.spawn_resources_for_chunk(0, 0, 12345, "temperate_forest")

	assert(objects.size() > 0, "Should spawn at least some objects in forest")
	assert(objects.size() < CHUNK_GRID_SIZE * CHUNK_GRID_SIZE,
		"Should not spawn object on every cell")

	# Add to scene for cleanup
	for obj in objects:
		add_child(obj)
		spawned_objects.append(obj)

	await get_tree().process_frame
	print("✓ TEST 1 PASSED: Forest biome spawned %d objects" % objects.size())


# ============================================
# TEST 2: DETERMINISM - SAME SEED SAME LAYOUT
# ============================================

func test_deterministic_spawning() -> void:
	"""AC-25: Same seed + biome produces identical layout"""

	var objects1 = BiomeResourceSpawner.spawn_resources_for_chunk(0, 0, 12345, "temperate_forest")
	var objects2 = BiomeResourceSpawner.spawn_resources_for_chunk(0, 0, 12345, "temperate_forest")

	assert(objects1.size() == objects2.size(),
		"Same seed should spawn same number of objects")

	# Check that objects are at same positions with same types
	for i in range(objects1.size()):
		assert(objects1[i].position == objects2[i].position,
			"Object %d position should match: %s vs %s" % [i, objects1[i].position, objects2[i].position])
		assert(objects1[i].object_type == objects2[i].object_type,
			"Object %d type should match" % i)

	# Cleanup
	for obj in objects1:
		obj.queue_free()
	for obj in objects2:
		obj.queue_free()

	print("✓ TEST 2 PASSED: Deterministic spawning verified")


# ============================================
# TEST 3: DIFFERENT SEEDS PRODUCE VARIATION
# ============================================

func test_different_seeds_variation() -> void:
	"""AC-25: Different seeds produce different layouts"""

	var objects1 = BiomeResourceSpawner.spawn_resources_for_chunk(0, 0, 12345, "temperate_forest")
	var objects2 = BiomeResourceSpawner.spawn_resources_for_chunk(0, 0, 54321, "temperate_forest")

	# Count position differences
	var position_differences = 0
	var max_count = min(objects1.size(), objects2.size())

	for i in range(max_count):
		if objects1[i].position != objects2[i].position:
			position_differences += 1

	assert(position_differences > 0,
		"Different seeds should produce different layouts")

	# Cleanup
	for obj in objects1:
		obj.queue_free()
	for obj in objects2:
		obj.queue_free()

	print("✓ TEST 3 PASSED: Different seeds produce variation")


# ============================================
# TEST 4: BIOME-SPECIFIC SPAWN RATES
# ============================================

func test_biome_spawn_rate_distribution() -> void:
	"""AC-22/23: Spawn rates match biome configuration (±10% tolerance)"""

	var forest_objects = BiomeResourceSpawner.spawn_resources_for_chunk(0, 0, 12345, "temperate_forest")

	# Get expected rates for forest
	var expected_rates = BiomeDefinitions.get_spawn_rates("temperate_forest")

	# Validate distribution
	var validation = BiomeResourceSpawner.validate_spawn_distribution(
		CHUNK_GRID_SIZE * CHUNK_GRID_SIZE,
		forest_objects,
		expected_rates
	)

	print("Forest spawn validation: %s" % validation)
	assert(validation.get("validation_passed", false),
		"Forest spawn rates should be within tolerance")

	# Cleanup
	for obj in forest_objects:
		obj.queue_free()

	print("✓ TEST 4 PASSED: Biome spawn rates validated")


# ============================================
# TEST 5: BIOME VARIATION
# ============================================

func test_biome_variation() -> void:
	"""AC-22: Different biomes produce different distributions"""

	var forest = BiomeResourceSpawner.spawn_resources_for_chunk(0, 0, 12345, "temperate_forest")
	var coastal = BiomeResourceSpawner.spawn_resources_for_chunk(0, 0, 12345, "coastal_beach")
	var mountain = BiomeResourceSpawner.spawn_resources_for_chunk(0, 0, 12345, "mountain_range")

	# Count trees in each biome
	var forest_trees = 0
	var coastal_trees = 0
	var mountain_trees = 0

	for obj in forest:
		if obj.object_type == "tree":
			forest_trees += 1

	for obj in coastal:
		if obj.object_type == "tree":
			coastal_trees += 1

	for obj in mountain:
		if obj.object_type == "tree":
			mountain_trees += 1

	# Forest should have more trees than coastal or mountain
	assert(forest_trees > coastal_trees,
		"Forest should spawn more trees than coastal (forest:%d, coastal:%d)" % [forest_trees, coastal_trees])
	assert(forest_trees > mountain_trees,
		"Forest should spawn more trees than mountain (forest:%d, mountain:%d)" % [forest_trees, mountain_trees])

	# Cleanup
	for obj in forest:
		obj.queue_free()
	for obj in coastal:
		obj.queue_free()
	for obj in mountain:
		obj.queue_free()

	print("✓ TEST 5 PASSED: Biome variation verified")


# ============================================
# TEST 6: MULTIPLE CHUNKS CONSISTENCY
# ============================================

func test_multiple_chunks_consistency() -> void:
	"""AC-25: Multiple chunks maintain determinism"""

	var chunks = {}

	# Spawn multiple chunks with same seed
	for chunk_x in range(3):
		for chunk_y in range(3):
			var key = "%d_%d" % [chunk_x, chunk_y]
			chunks[key] = BiomeResourceSpawner.spawn_resources_for_chunk(
				chunk_x, chunk_y, 12345, "temperate_forest"
			)

	# Regenerate and verify identical
	for chunk_x in range(3):
		for chunk_y in range(3):
			var key = "%d_%d" % [chunk_x, chunk_y]
			var new_objects = BiomeResourceSpawner.spawn_resources_for_chunk(
				chunk_x, chunk_y, 12345, "temperate_forest"
			)

			assert(chunks[key].size() == new_objects.size(),
				"Chunk %s should spawn same number of objects on re-generation" % key)

			for i in range(chunks[key].size()):
				assert(chunks[key][i].position == new_objects[i].position,
					"Chunk %s object %d position should match" % [key, i])

			# Cleanup new objects
			for obj in new_objects:
				obj.queue_free()

	# Cleanup original objects
	for key in chunks.keys():
		for obj in chunks[key]:
			obj.queue_free()

	print("✓ TEST 6 PASSED: Multiple chunks maintain consistency")


# ============================================
# TEST 7: RESOURCE NODE TYPE DISTRIBUTION
# ============================================

func test_resource_node_type_distribution() -> void:
	"""AC-24: Resource nodes distribute by biome type"""

	var forest_nodes = BiomeResourceSpawner.spawn_resources_for_chunk(0, 0, 12345, "temperate_forest")
	var coastal_nodes = BiomeResourceSpawner.spawn_resources_for_chunk(0, 0, 12345, "coastal_beach")

	# Count resource nodes
	var forest_resources = 0
	var coastal_resources = 0

	for obj in forest_nodes:
		if obj.object_type == "resource_node":
			forest_resources += 1

	for obj in coastal_nodes:
		if obj.object_type == "resource_node":
			coastal_resources += 1

	# Coastal should have more resource nodes than forest (fishing opportunities)
	assert(coastal_resources > forest_resources,
		"Coastal should have more resources than forest")

	# Cleanup
	for obj in forest_nodes:
		obj.queue_free()
	for obj in coastal_nodes:
		obj.queue_free()

	print("✓ TEST 7 PASSED: Resource node distribution verified")


# ============================================
# TEST 8: ALL BIOMES VALID
# ============================================

func test_all_biomes_spawn() -> void:
	"""AC-21/22: All biome types can spawn objects"""

	var all_biomes = BiomeDefinitions.get_all_biomes()
	assert(all_biomes.size() == 4, "Should have 4 biome types")

	for biome in all_biomes:
		var objects = BiomeResourceSpawner.spawn_resources_for_chunk(0, 0, 12345, biome)
		assert(objects.size() > 0, "Biome '%s' should spawn objects" % biome)

		# Cleanup
		for obj in objects:
			obj.queue_free()

	print("✓ TEST 8 PASSED: All biomes spawn objects successfully")


# ============================================
# TEST 9: GRID POSITION VALIDITY
# ============================================

func test_spawned_positions_within_chunk() -> void:
	"""AC-21: All spawned objects are within chunk bounds"""

	var chunk_x = 5
	var chunk_y = 3
	var objects = BiomeResourceSpawner.spawn_resources_for_chunk(chunk_x, chunk_y, 12345, "temperate_forest")

	var chunk_min_x = chunk_x * CHUNK_GRID_SIZE
	var chunk_max_x = chunk_min_x + CHUNK_GRID_SIZE
	var chunk_min_z = chunk_y * CHUNK_GRID_SIZE
	var chunk_max_z = chunk_min_z + CHUNK_GRID_SIZE

	for obj in objects:
		assert(obj.position.x >= chunk_min_x and obj.position.x < chunk_max_x,
			"Object X position out of chunk bounds: %f (chunk %d-%d)" % [obj.position.x, chunk_min_x, chunk_max_x])
		assert(obj.position.z >= chunk_min_z and obj.position.z < chunk_max_z,
			"Object Z position out of chunk bounds: %f (chunk %d-%d)" % [obj.position.z, chunk_min_z, chunk_max_z])

	# Cleanup
	for obj in objects:
		obj.queue_free()

	print("✓ TEST 9 PASSED: All positions within chunk bounds")
