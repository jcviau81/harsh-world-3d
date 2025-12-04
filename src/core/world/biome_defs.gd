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

	for biome_id in BIOME_CONFIGS.keys():
		var path = "res://assets/biome_definitions/%s.tres" % biome_id
		if ResourceLoader.exists(path):
			_biomes[biome_id] = ResourceLoader.load(path)
		else:
			push_warning("Failed to load biome: %s" % biome_id)

	_initialized = true

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

## Get raw biome definition resource
static func get_biome_definition(biome_type: String) -> BiomeDefinition:
	_ensure_initialized()
	if biome_type in _biomes:
		return _biomes[biome_type]
	return null
