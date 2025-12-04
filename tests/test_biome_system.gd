## Unit Tests for Biome System
## Tests biome assignment, determinism, spawn rates, and properties

extends GDScriptTestCase

const TEST_WORLD_SEED = 12345
const TEST_CHUNK_SIZE = 32

## Test biome assignment correctness
func test_biome_assignment():
	var generator = BiomeGenerator.new()
	generator._ready()

	# Create test heightmap (mostly temperate height)
	var heightmap = PackedFloat32Array()
	for i in range(32 * 32):
		heightmap.append(0.5)  # Mid-range elevation

	# Test multiple chunks
	var biome = generator.assign_biome_for_chunk(heightmap, 0, 0, TEST_WORLD_SEED)
	assert_not_empty(biome, "Biome assignment should return valid biome")
	assert_true(biome in ["coastal_atlantic", "temperate_forest", "deciduous_forest", "grasslands", "appalachian_mountains", "boreal_forest", "wetlands"],
		"Biome should be one of 7 valid biomes")

## Test biome determinism (same inputs → same outputs)
func test_biome_determinism():
	var generator = BiomeGenerator.new()
	generator._ready()

	# Create test heightmap
	var heightmap = PackedFloat32Array()
	for i in range(32 * 32):
		heightmap.append(randf())

	var chunk_x = 5
	var chunk_y = 10
	var world_seed = TEST_WORLD_SEED

	# Test determinism: same inputs multiple times
	var biome1 = generator.assign_biome_for_chunk(heightmap, chunk_x, chunk_y, world_seed)
	var biome2 = generator.assign_biome_for_chunk(heightmap, chunk_x, chunk_y, world_seed)
	var biome3 = generator.assign_biome_for_chunk(heightmap, chunk_x, chunk_y, world_seed)

	assert_equal(biome1, biome2, "Determinism test 1: Same inputs should produce same biome")
	assert_equal(biome2, biome3, "Determinism test 2: Same inputs should produce same biome")

## Test terrain type assignment per biome
func test_terrain_type_assignment():
	var generator = BiomeGenerator.new()
	generator._ready()

	# Test different height values produce different terrain types
	for biome_id in ["temperate_forest", "appalachian_mountains", "grasslands"]:
		var terrain_low = generator.get_terrain_type_for_tile(biome_id, 0.2)
		var terrain_high = generator.get_terrain_type_for_tile(biome_id, 0.8)

		assert_not_empty(terrain_low, "Should assign terrain for low height in %s" % biome_id)
		assert_not_empty(terrain_high, "Should assign terrain for high height in %s" % biome_id)

## Test movement speed modifiers
func test_movement_speed_modifiers():
	var generator = BiomeGenerator.new()
	generator._ready()

	# Mountains should be slower than grasslands
	var mountain_speed = generator.get_speed_modifier("appalachian_mountains", "rocky_peak")
	var grassland_speed = generator.get_speed_modifier("grasslands", "short_grass")

	assert_less(mountain_speed, grassland_speed, "Mountains should be slower than grasslands")
	assert_less_equal(mountain_speed, 1.0, "Mountain speed modifier should be <= 1.0")
	assert_greater_equal(grassland_speed, 0.8, "Grassland speed should be reasonable")

## Test biome definition loading
func test_biome_definitions_loaded():
	BiomeDefinitions.initialize()

	for biome_id in ["coastal_atlantic", "temperate_forest", "deciduous_forest", "grasslands", "appalachian_mountains", "boreal_forest", "wetlands"]:
		var definition = BiomeDefinitions.get_biome_definition(biome_id)
		assert_not_null(definition, "Biome definition should exist for %s" % biome_id)
		assert_not_empty(definition.spawn_rates, "Biome should have spawn rates")
		assert_not_empty(definition.forage_items, "Biome should have forage items")

## Test spawn rates configuration
func test_spawn_rates():
	BiomeDefinitions.initialize()

	for biome_id in ["coastal_atlantic", "temperate_forest", "deciduous_forest"]:
		var spawn_rates = BiomeDefinitions.get_spawn_rates(biome_id)
		assert_not_empty(spawn_rates, "Spawn rates should exist for %s" % biome_id)

		# Verify spawn rates are reasonable (0-1 range)
		var total_rate = 0.0
		for item_type in spawn_rates:
			var rate = spawn_rates[item_type]
			assert_greater_equal(rate, 0.0, "Spawn rate should be >= 0")
			assert_less_equal(rate, 1.0, "Spawn rate should be <= 1.0")
			total_rate += rate

## Test temperature per biome
func test_temperature_per_biome():
	BiomeDefinitions.initialize()

	var cold_biomes = ["appalachian_mountains", "boreal_forest"]
	var warm_biomes = ["coastal_atlantic", "grasslands"]

	for biome_id in cold_biomes:
		var temp = BiomeDefinitions.get_base_temperature(biome_id)
		assert_less(temp, 0.0, "Cold biomes should have negative temperature")

	for biome_id in warm_biomes:
		var temp = BiomeDefinitions.get_base_temperature(biome_id)
		assert_greater_equal(temp, 0.0, "Warm biomes should have non-negative temperature")

## Test seasonal resource variation
func test_seasonal_modifiers():
	BiomeDefinitions.initialize()

	var summer_mod = BiomeDefinitions.get_seasonal_modifier("temperate_forest", "summer")
	var winter_mod = BiomeDefinitions.get_seasonal_modifier("temperate_forest", "winter")

	assert_greater(summer_mod, winter_mod, "Summer should have more resources than winter")
	assert_greater(summer_mod, 1.0, "Summer should increase resources")
	assert_less(winter_mod, 1.0, "Winter should decrease resources")

## Test biome properties difficulty
func test_biome_difficulty():
	BiomeDefinitions.initialize()

	var easy_biome = BiomeDefinitions.get_difficulty("grasslands")
	var hard_biome = BiomeDefinitions.get_difficulty("appalachian_mountains")

	assert_equal(easy_biome, "easy", "Grasslands should be easy")
	assert_equal(hard_biome, "hard", "Mountains should be hard")

## Test large-scale biome diversity
func test_large_world_biome_variety():
	var generator = BiomeGenerator.new()
	generator._ready()

	var biomes_found = {}
	var biome_count = 0

	# Generate 25+ chunks and check biome variety
	for chunk_x in range(-3, 3):
		for chunk_y in range(-3, 3):
			var heightmap = PackedFloat32Array()
			for i in range(32 * 32):
				heightmap.append(randf())

			var biome = generator.assign_biome_for_chunk(heightmap, chunk_x, chunk_y, TEST_WORLD_SEED)
			if biome not in biomes_found:
				biomes_found[biome] = 0
			biomes_found[biome] += 1
			biome_count += 1

	assert_greater_equal(biomes_found.size(), 3, "Should find at least 3 different biomes in 6x6 world")
	print("Biome distribution in 6x6 test world: %s" % biomes_found)

class GDScriptTestCase:
	## Custom assertions
	func assert_not_empty(value, message: String) -> void:
		if value is String:
			assert(value != "", message)
		elif value is Array or value is Dictionary:
			assert(value.size() > 0, message)
		else:
			assert(value != null, message)

	func assert_equal(a, b, message: String) -> void:
		assert(a == b, "%s (expected %s, got %s)" % [message, b, a])

	func assert_not_null(value, message: String) -> void:
		assert(value != null, message)

	func assert_less(a, b, message: String) -> void:
		assert(a < b, "%s (%s < %s)" % [message, a, b])

	func assert_less_equal(a, b, message: String) -> void:
		assert(a <= b, "%s (%s <= %s)" % [message, a, b])

	func assert_greater(a, b, message: String) -> void:
		assert(a > b, "%s (%s > %s)" % [message, a, b])

	func assert_greater_equal(a, b, message: String) -> void:
		assert(a >= b, "%s (%s >= %s)" % [message, a, b])

	func assert_true(condition: bool, message: String) -> void:
		assert(condition, message)
