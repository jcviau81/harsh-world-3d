class_name BiomeGenerator
extends Node

## Biome generator for deterministic world generation
## Uses 2D Perlin noise + heightmap elevation to assign biome types
## Determinism guaranteed: same seed + chunk_x/y → identical biome

## Noise parameters
@export var noise_scale: float = 0.1  # Large scale for broad biome zones
@export var elevation_influence: float = 0.5  # Balance between noise and elevation

## Biome list for generation
var biome_list: Array[String] = [
	"coastal_atlantic",
	"temperate_forest",
	"deciduous_forest",
	"grasslands",
	"appalachian_mountains",
	"boreal_forest",
	"wetlands"
]

## Initialize biome generator
func _ready() -> void:
	# Biome definitions are now created programmatically in BiomeDefinitions
	pass

## Main biome assignment function - deterministic per chunk
## Returns biome_id string (e.g., "temperate_forest")
func assign_biome_for_chunk(heightmap: PackedFloat32Array, chunk_x: int, chunk_y: int, world_seed: int) -> String:
	# Create seeded noise for this chunk
	var noise = FastNoiseLite.new()
	noise.seed = world_seed ^ (chunk_x << 16) ^ chunk_y  # Deterministic seed
	noise.noise_type = FastNoiseLite.TYPE_PERLIN
	noise.frequency = noise_scale

	# Get broad biome zone from noise at chunk center
	var chunk_center_x = float(chunk_x) * 32.0 + 16.0
	var chunk_center_y = float(chunk_y) * 32.0 + 16.0
	var noise_value = noise.get_noise_2d(chunk_center_x / 1000.0, chunk_center_y / 1000.0)  # Normalized coordinates

	# Get average elevation for this chunk
	var avg_elevation = 0.0
	for height in heightmap:
		avg_elevation += height
	avg_elevation /= max(heightmap.size(), 1)

	# Determine biome from combined noise + elevation
	return _select_biome_from_noise_and_elevation(noise_value, avg_elevation)

## Assign terrain type within a biome based on local height variation
func get_terrain_type_for_tile(biome_id: String, local_height: float) -> String:
	if not BiomeDefinitions.is_valid_biome(biome_id):
		return "default"

	var biome = BiomeDefinitions.get_biome_definition(biome_id)
	if not biome or biome.terrain_types.is_empty():
		return "default"

	# Select terrain type based on height within the biome
	match biome_id:
		"coastal_atlantic":
			if local_height < 0.2:
				return "sandy_beach"
			elif local_height < 0.4:
				return "rocky_shore"
			else:
				return "kelp_forest"

		"temperate_forest":
			if local_height < 0.3:
				return "clearing"
			elif local_height < 0.7:
				return "sparse_forest"
			else:
				return "dense_forest"

		"deciduous_forest":
			if local_height < 0.3:
				return "understory"
			elif local_height < 0.6:
				return "aspen_grove"
			else:
				return "dense_birch"

		"grasslands":
			if local_height < 0.4:
				return "tall_grass"
			elif local_height < 0.7:
				return "short_grass"
			else:
				return "scattered_trees"

		"appalachian_mountains":
			if local_height < 0.5:
				return "alpine_meadow"
			elif local_height < 0.8:
				return "mountain_forest"
			else:
				return "rocky_peak"

		"boreal_forest":
			if local_height < 0.3:
				return "lichen_ground"
			elif local_height < 0.7:
				return "spruce_stand"
			else:
				return "dense_taiga"

		"wetlands":
			if local_height < 0.3:
				return "deep_marsh"
			elif local_height < 0.6:
				return "shallow_water"
			else:
				return "bog_ground"

	return biome.terrain_types[0] if not biome.terrain_types.is_empty() else "default"

## Get movement speed modifier for terrain type
func get_speed_modifier(biome_id: String, terrain_type: String) -> float:
	return BiomeDefinitions.get_speed_multiplier(biome_id, terrain_type)

## Internal: Select biome based on combined noise + elevation
## Noise ranges from -1 to 1, elevation from 0 to 1
func _select_biome_from_noise_and_elevation(noise_value: float, elevation: float) -> String:
	# Elevation-based primary assignment
	if elevation < 0.2:
		return "coastal_atlantic"
	elif elevation < 0.4:
		# Mid-low elevation: forests or grasslands based on noise
		if noise_value < -0.3:
			return "deciduous_forest"
		elif noise_value < 0.3:
			return "temperate_forest"
		else:
			return "grasslands"
	elif elevation < 0.7:
		# Mid elevation: temperate or boreal
		if noise_value < 0.0:
			return "temperate_forest"
		elif noise_value < 0.4:
			return "boreal_forest"
		else:
			return "grasslands"
	else:
		# High elevation: mountains or boreal
		if noise_value < -0.2:
			return "appalachian_mountains"
		elif noise_value < 0.2:
			return "boreal_forest"
		else:
			return "appalachian_mountains"

## Get biome definition resource
func get_biome_definition(biome_id: String) -> BiomeDefinition:
	return BiomeDefinitions.get_biome_definition(biome_id)

## Get info about biome for debugging
func get_biome_info(biome_id: String) -> String:
	var biome = get_biome_definition(biome_id)
	if biome:
		return biome.get_info_string()
	return "Unknown biome: %s" % biome_id

## Validate determinism by testing same inputs produce same output
func validate_determinism(world_seed: int, test_count: int = 10) -> bool:
	var _results: Dictionary = {}

	for i in range(test_count):
		var chunk_x = randi() % 100
		var chunk_y = randi() % 100

		# Create test heightmap
		var heightmap = PackedFloat32Array()
		for j in range(32 * 32):
			heightmap.append(randf())

		# Test multiple times with same inputs
		for attempt in range(3):
			var biome1 = assign_biome_for_chunk(heightmap, chunk_x, chunk_y, world_seed)
			var biome2 = assign_biome_for_chunk(heightmap, chunk_x, chunk_y, world_seed)

			if biome1 != biome2:
				push_error("Determinism violation at chunk (%d, %d): %s != %s" % [chunk_x, chunk_y, biome1, biome2])
				return false

	return true
