## BiomeDefinitions utility class
## Provides access to biome configuration data and spawn rates
## Works with pre-loaded BiomeDefinition resources

class_name BiomeDefinitions
extends RefCounted

# Preloaded biome definitions
static var _biomes: Dictionary = {}
static var _initialized: bool = false

# Biome configuration constants
const BIOME_CONFIGS = {
	"coastal_atlantic": {
		"base_temperature": 2.0,
		"difficulty": "moderate",
		"density": 0.7
	},
	"temperate_forest": {
		"base_temperature": 0.0,
		"difficulty": "easy",
		"density": 0.85
	},
	"deciduous_forest": {
		"base_temperature": -1.0,
		"difficulty": "easy",
		"density": 0.8
	},
	"grasslands": {
		"base_temperature": 1.0,
		"difficulty": "easy",
		"density": 0.6
	},
	"appalachian_mountains": {
		"base_temperature": -5.0,
		"difficulty": "hard",
		"density": 0.5
	},
	"boreal_forest": {
		"base_temperature": -8.0,
		"difficulty": "hard",
		"density": 0.65
	},
	"wetlands": {
		"base_temperature": -2.0,
		"difficulty": "moderate",
		"density": 0.75
	}
}

## Initialize biome definitions (call once at startup)
static func initialize() -> void:
	if _initialized:
		return

	# Create biome definitions from builtin data
	_create_biomes()
	_initialized = true

## Create biome definition instances with all data
static func _create_biomes() -> void:
	var biome_data = [
		{
			"id": "coastal_atlantic",
			"name": "Coastal Atlantic",
			"desc": "Rocky coastline with kelp forests and marine resources",
			"temp": 2.0,
			"tier": "moderate",
			"terrain": ["rocky_shore", "kelp_forest", "sandy_beach"],
			"speed": {"rocky_shore": 0.6, "kelp_forest": 0.4, "sandy_beach": 0.9},
			"spawn": {"willow_tree": 0.15, "kelp": 0.4, "shells": 0.25, "sea_grass": 0.2, "rock": 0.15, "seal": 0.05},
			"forage": ["kelp", "shells", "sea_grass", "crabs", "fish", "salt"],
			"animals": ["seal", "bird", "crab"],
			"color": Color(0, 1, 1, 1),
			"audio": "res://assets/sounds/ambient/ocean_waves.ogg"
		},
		{
			"id": "temperate_forest",
			"name": "Temperate Forest",
			"desc": "Mixed deciduous and coniferous forest with abundant wildlife",
			"temp": 0.0,
			"tier": "easy",
			"terrain": ["dense_forest", "sparse_forest", "clearing"],
			"speed": {"dense_forest": 0.8, "sparse_forest": 1.0, "clearing": 1.2},
			"spawn": {"maple_tree": 0.3, "oak_tree": 0.25, "mushroom": 0.15, "berry_bush": 0.2, "rock": 0.1},
			"forage": ["berries", "mushrooms", "roots", "seeds", "nuts", "herbs"],
			"animals": ["deer", "rabbit", "bird"],
			"color": Color.GREEN,
			"audio": "res://assets/sounds/ambient/forest_birds.ogg"
		},
		{
			"id": "deciduous_forest",
			"name": "Deciduous Forest",
			"desc": "Forests dominated by trees that lose leaves seasonally",
			"temp": -1.0,
			"tier": "easy",
			"terrain": ["dense_forest", "forest_floor", "clearing"],
			"speed": {"dense_forest": 0.75, "forest_floor": 1.0, "clearing": 1.2},
			"spawn": {"oak_tree": 0.35, "beech_tree": 0.25, "mushroom": 0.2, "berry_bush": 0.15, "rock": 0.05},
			"forage": ["acorns", "mushrooms", "roots", "seeds", "nuts", "herbs"],
			"animals": ["deer", "boar", "bird"],
			"color": Color(0.2, 0.6, 0.2, 1),
			"audio": "res://assets/sounds/ambient/forest_wind.ogg"
		},
		{
			"id": "grasslands",
			"name": "Grasslands",
			"desc": "Open plains with sparse trees and abundant grazing animals",
			"temp": 1.0,
			"tier": "easy",
			"terrain": ["tall_grass", "short_grass", "scattered_trees"],
			"speed": {"tall_grass": 0.9, "short_grass": 1.1, "scattered_trees": 1.0},
			"spawn": {"oak_tree": 0.1, "pine_tree": 0.08, "grass": 0.4, "wildflower": 0.2, "rock": 0.12, "bison": 0.1},
			"forage": ["grains", "wildflowers", "roots", "seeds", "berries"],
			"animals": ["bison", "deer", "bird"],
			"color": Color.YELLOW,
			"audio": "res://assets/sounds/ambient/wind_grass.ogg"
		},
		{
			"id": "appalachian_mountains",
			"name": "Appalachian Mountains",
			"desc": "Ancient eroded mountains with rocky terrain and sparse vegetation",
			"temp": -5.0,
			"tier": "hard",
			"terrain": ["rocky_slope", "cliff_face", "mountain_plateau"],
			"speed": {"rocky_slope": 0.5, "cliff_face": 0.3, "mountain_plateau": 0.8},
			"spawn": {"pine_tree": 0.2, "birch_tree": 0.15, "scrub": 0.25, "lichen": 0.2, "rock": 0.2},
			"forage": ["pine_nuts", "berries", "roots", "medicinal_herbs", "stone"],
			"animals": ["mountain_goat", "eagle", "rabbit"],
			"color": Color(0.6, 0.6, 0.6, 1),
			"audio": "res://assets/sounds/ambient/mountain_wind.ogg"
		},
		{
			"id": "boreal_forest",
			"name": "Boreal Forest",
			"desc": "Subarctic coniferous forest with long winters and short summers",
			"temp": -8.0,
			"tier": "hard",
			"terrain": ["dense_evergreen", "sparse_evergreen", "boreal_clearing"],
			"speed": {"dense_evergreen": 0.7, "sparse_evergreen": 0.95, "boreal_clearing": 1.1},
			"spawn": {"spruce_tree": 0.35, "pine_tree": 0.3, "lichen": 0.2, "berry_bush": 0.1, "rock": 0.05},
			"forage": ["pine_nuts", "lingonberries", "roots", "mushrooms", "moss"],
			"animals": ["moose", "wolf", "bird"],
			"color": Color(0.1, 0.3, 0.1, 1),
			"audio": "res://assets/sounds/ambient/boreal_wind.ogg"
		},
		{
			"id": "wetlands",
			"name": "Wetlands",
			"desc": "Marshes and swamps with water-adapted vegetation and wildlife",
			"temp": -2.0,
			"tier": "moderate",
			"terrain": ["deep_marsh", "shallow_water", "bog_ground"],
			"speed": {"deep_marsh": 0.4, "shallow_water": 0.6, "bog_ground": 0.7},
			"spawn": {"willow_tree": 0.15, "cattails": 0.3, "water_plants": 0.25, "marsh_berry": 0.2, "rock": 0.1},
			"forage": ["cattails", "reeds", "water_plants", "marsh_berries", "fish"],
			"animals": ["beaver", "bird", "fish"],
			"color": Color(0.2, 0.6, 0.4, 1),
			"audio": "res://assets/sounds/ambient/marsh_water.ogg"
		}
	]

	for biome_info in biome_data:
		var biome = BiomeDefinition.new()
		biome.biome_id = biome_info["id"]
		biome.display_name = biome_info["name"]
		biome.description = biome_info["desc"]
		biome.base_temperature = biome_info["temp"]
		biome.difficulty_tier = biome_info["tier"]

		# Convert arrays to proper Array[String] type
		var terrain_arr: Array[String] = []
		for item in biome_info["terrain"]:
			terrain_arr.append(item)
		biome.terrain_types = terrain_arr

		biome.terrain_speed_multipliers = biome_info["speed"]
		biome.spawn_rates = biome_info["spawn"]

		var forage_arr: Array[String] = []
		for item in biome_info["forage"]:
			forage_arr.append(item)
		biome.forage_items = forage_arr

		var animals_arr: Array[String] = []
		for item in biome_info["animals"]:
			animals_arr.append(item)
		biome.huntable_animals = animals_arr

		biome.primary_color = biome_info["color"]
		biome.ambient_sound = biome_info["audio"]
		biome.tree_sprite_prefix = "tree_default"
		biome.water_sprite = "water_default"
		# Default seasonal variations
		biome.seasonal_variations = {
			"spring": {"spawn_modifier": 1.3, "visual_variant": "spring"},
			"summer": {"spawn_modifier": 1.4, "visual_variant": "summer"},
			"fall": {"spawn_modifier": 0.9, "visual_variant": "fall"},
			"winter": {"spawn_modifier": 0.4, "visual_variant": "winter"}
		}
		_biomes[biome_info["id"]] = biome

## Get biome configuration dictionary
static func get_config(biome_type: String) -> Dictionary:
	if biome_type in BIOME_CONFIGS:
		return BIOME_CONFIGS[biome_type]
	return {}

## Get spawn rates for biome
static func get_spawn_rates(biome_type: String) -> Dictionary:
	_ensure_initialized()
	if biome_type in _biomes:
		var biome: BiomeDefinition = _biomes[biome_type]
		return biome.spawn_rates
	return {}

## Get biome density (affects spawn probability)
static func get_density(biome_type: String) -> float:
	var config = get_config(biome_type)
	if config.is_empty():
		return 0.5
	return config.get("density", 0.5)

## Get base temperature for biome
static func get_base_temperature(biome_type: String) -> float:
	var config = get_config(biome_type)
	if config.is_empty():
		return 0.0
	return config.get("base_temperature", 0.0)

## Get difficulty tier
static func get_difficulty(biome_type: String) -> String:
	var config = get_config(biome_type)
	if config.is_empty():
		return "moderate"
	return config.get("difficulty", "moderate")

## Get resource distribution for this biome
static func get_resource_distribution(biome_type: String) -> Dictionary:
	_ensure_initialized()
	if biome_type in _biomes:
		var biome: BiomeDefinition = _biomes[biome_type]
		var distribution = {}
		for item in biome.forage_items:
			distribution[item] = 1.0 / biome.forage_items.size()
		return distribution
	return {}

## Get all forage items for biome
static func get_forage_items(biome_type: String) -> Array[String]:
	_ensure_initialized()
	if biome_type in _biomes:
		var biome: BiomeDefinition = _biomes[biome_type]
		return biome.forage_items
	return []

## Get all huntable animals for biome
static func get_huntable_animals(biome_type: String) -> Array[String]:
	_ensure_initialized()
	if biome_type in _biomes:
		var biome: BiomeDefinition = _biomes[biome_type]
		return biome.huntable_animals
	return []

## Get terrain types for biome
static func get_terrain_types(biome_type: String) -> Array[String]:
	_ensure_initialized()
	if biome_type in _biomes:
		var biome: BiomeDefinition = _biomes[biome_type]
		return biome.terrain_types
	return []

## Get movement speed multiplier for terrain
static func get_speed_multiplier(biome_type: String, terrain_type: String) -> float:
	_ensure_initialized()
	if biome_type in _biomes:
		var biome: BiomeDefinition = _biomes[biome_type]
		return biome.get_speed_multiplier(terrain_type)
	return 1.0

## Get seasonal spawn modifier
static func get_seasonal_modifier(biome_type: String, season: String) -> float:
	_ensure_initialized()
	if biome_type in _biomes:
		var biome: BiomeDefinition = _biomes[biome_type]
		var variant = biome.get_season_variant(season)
		return variant.get("spawn_modifier", 1.0)
	return 1.0

## Internal: Ensure definitions are initialized
static func _ensure_initialized() -> void:
	if not _initialized:
		initialize()

## Get all biome IDs
static func get_all_biomes() -> Array[String]:
	_ensure_initialized()
	var biome_ids: Array[String] = []
	for biome_id in _biomes.keys():
		biome_ids.append(biome_id)
	return biome_ids

## Get raw biome definition resource
static func get_biome_definition(biome_type: String) -> BiomeDefinition:
	_ensure_initialized()
	if biome_type in _biomes:
		return _biomes[biome_type]
	return null

## Check if biome type is valid
static func is_valid_biome(biome_type: String) -> bool:
	return biome_type in BIOME_CONFIGS
