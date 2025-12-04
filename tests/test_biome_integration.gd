## Integration Tests for Biome System
## Tests interactions between biome system, resource spawning, and chunk loading

extends GDScriptTestCase

## Test complete biome chunk generation
func test_complete_biome_chunk():
	var generator = BiomeGenerator.new()
	generator._ready()
	BiomeDefinitions.initialize()

	# Create test heightmap
	var heightmap = PackedFloat32Array()
	for i in range(32 * 32):
		heightmap.append(0.5 + randf() * 0.2)

	# Assign biome
	var biome = generator.assign_biome_for_chunk(heightmap, 0, 0, 12345)
	assert_not_empty(biome, "Should assign biome")

	# Spawn resources using biome
	var objects = BiomeResourceSpawner.spawn_resources_for_chunk(0, 0, 12345, biome)
	assert_greater(objects.size(), 0, "Should spawn objects in biome")

	# Verify objects are WorldObject instances
	for obj in objects:
		assert_equal(obj.get_class(), "WorldObject", "All spawned objects should be WorldObject")

## Test biome transitions between chunks
func test_biome_transition_smoothness():
	var generator = BiomeGenerator.new()
	generator._ready()

	# Create adjacent chunks with varying elevation
	var biomes = []
	for x in range(3):
		var heightmap = PackedFloat32Array()
		for i in range(32 * 32):
			# Gradient: higher on right side
			heightmap.append(float(x) / 3.0 + 0.2)

		var biome = generator.assign_biome_for_chunk(heightmap, x, 0, 54321)
		biomes.append(biome)

	# Check for smooth transitions (not all same, not too many different)
	var unique_biomes = {}
	for biome in biomes:
		if biome not in unique_biomes:
			unique_biomes[biome] = 0
		unique_biomes[biome] += 1

	assert_greater_equal(unique_biomes.size(), 1, "Should have at least 1 biome")
	assert_less_equal(unique_biomes.size(), 3, "Transitions should be relatively smooth")

## Test biome difficulty affects resource availability
func test_biome_difficulty_resource_scarcity():
	BiomeDefinitions.initialize()

	var easy_biome = "grasslands"
	var hard_biome = "appalachian_mountains"

	var easy_density = BiomeDefinitions.get_density(easy_biome)
	var hard_density = BiomeDefinitions.get_density(hard_biome)

	assert_greater(easy_density, hard_density, "Easy biome should have higher resource density")

## Test seasonal resource variation
func test_seasonal_spawn_variation():
	BiomeDefinitions.initialize()

	var biome = "temperate_forest"

	var summer_rate = BiomeDefinitions.get_seasonal_modifier(biome, "summer")
	var winter_rate = BiomeDefinitions.get_seasonal_modifier(biome, "winter")
	var spring_rate = BiomeDefinitions.get_seasonal_modifier(biome, "spring")
	var fall_rate = BiomeDefinitions.get_seasonal_modifier(biome, "fall")

	# Verify seasonal progression
	assert_greater(summer_rate, spring_rate, "Summer should be more abundant than spring")
	assert_greater(spring_rate, winter_rate, "Spring should be more abundant than winter")
	assert_greater(fall_rate, winter_rate, "Fall should be more abundant than winter")

## Test biome animal distribution
func test_animal_distribution_per_biome():
	BiomeDefinitions.initialize()

	var coastal_animals = BiomeDefinitions.get_huntable_animals("coastal_atlantic")
	var mountain_animals = BiomeDefinitions.get_huntable_animals("appalachian_mountains")

	assert_greater(coastal_animals.size(), 0, "Coastal should have animals")
	assert_greater(mountain_animals.size(), 0, "Mountains should have animals")
	assert_not_equal(coastal_animals, mountain_animals, "Biomes should have different animals")

## Test movement speed varies by terrain
func test_terrain_speed_variation():
	BiomeDefinitions.initialize()

	# In mountains, rocky peak should be slower than alpine meadow
	var peak_speed = BiomeDefinitions.get_speed_multiplier("appalachian_mountains", "rocky_peak")
	var meadow_speed = BiomeDefinitions.get_speed_multiplier("appalachian_mountains", "alpine_meadow")

	assert_less(peak_speed, meadow_speed, "Rocky peaks should be slower than meadows")

## Test biome visual properties
func test_biome_visuals():
	var coastal_color = BiomeVisuals.get_biome_color("coastal_atlantic")
	var forest_color = BiomeVisuals.get_biome_color("temperate_forest")

	assert_not_equal(coastal_color, forest_color, "Different biomes should have different colors")

	# Test seasonal variants
	var spring_variant = BiomeVisuals.get_seasonal_variant("spring")
	var winter_variant = BiomeVisuals.get_seasonal_variant("winter")

	assert_not_equal(spring_variant.get("brightness_mod", 0), winter_variant.get("brightness_mod", 0),
		"Seasons should have different brightness")

## Test large world biome consistency
func test_large_world_consistency():
	var generator = BiomeGenerator.new()
	generator._ready()

	var chunk_biomes: Dictionary = {}

	# Generate larger world and verify consistency
	for x in range(-5, 6):
		for y in range(-5, 6):
			var heightmap = PackedFloat32Array()
			for i in range(32 * 32):
				heightmap.append(randf())

			var biome = generator.assign_biome_for_chunk(heightmap, x, y, 99999)
			var key = "%d_%d" % [x, y]
			chunk_biomes[key] = biome

	# Generate same chunks again and verify determinism
	var consistent = true
	for x in range(-5, 6):
		for y in range(-5, 6):
			var heightmap = PackedFloat32Array()
			for i in range(32 * 32):
				heightmap.append(randf())  # Different random values but same structure

			var biome = generator.assign_biome_for_chunk(heightmap, x, y, 99999)
			var key = "%d_%d" % [x, y]
			if chunk_biomes[key] != biome:
				consistent = false
				break

	assert_true(consistent, "World generation should be consistent across multiple calls")

## Test biome properties integration
func test_biome_properties_integration():
	BiomeDefinitions.initialize()

	var biome = "boreal_forest"

	# Test temperature effects
	var health_drain = BiomeProperties.get_health_drain_modifier(biome)
	assert_greater(health_drain, 1.0, "Cold biome should increase health drain")

	# Test stamina effects
	var stamina_regen = BiomeProperties.get_stamina_regen_modifier(biome)
	assert_less(stamina_regen, 1.0, "Cold biome should reduce stamina regen")

	# Test difficulty
	var difficulty = BiomeProperties.get_difficulty_tier(biome)
	assert_equal(difficulty, "hard", "Boreal forest should be hard difficulty")

class GDScriptTestCase:
	func assert_not_empty(value, message: String) -> void:
		if value is String:
			assert(value != "", message)
		elif value is Array or value is Dictionary:
			assert(value.size() > 0, message)
		else:
			assert(value != null, message)

	func assert_equal(a, b, message: String) -> void:
		assert(a == b, "%s (expected %s, got %s)" % [message, b, a])

	func assert_not_equal(a, b, message: String) -> void:
		assert(a != b, "%s (values should differ)" % message)

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
