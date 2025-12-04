class_name BiomeDefinition
extends Resource

## Base biome identification and metadata
@export var biome_id: String = "temperate_forest"
@export var display_name: String = "Temperate Forest"
@export var description: String = "Moderate climate with diverse flora"

## Environmental properties
@export var base_temperature: float = 0.0  # Celsius adjustment from baseline
@export var difficulty_tier: String = "moderate"  # easy, moderate, hard

## Terrain classification
@export var terrain_types: Array[String] = ["dense_forest", "sparse_forest", "clearing"]
@export var terrain_speed_multipliers: Dictionary = {
	"dense_forest": 0.8,
	"sparse_forest": 1.0,
	"clearing": 1.2
}

## Resource distribution
@export var spawn_rates: Dictionary = {
	"maple_tree": 0.3,
	"oak_tree": 0.25,
	"mushroom": 0.15,
	"berry_bush": 0.2,
	"rock": 0.1
}

## Biome-specific resources and animals
@export var forage_items: Array[String] = ["berries", "mushrooms", "roots", "seeds"]
@export var huntable_animals: Array[String] = ["deer", "rabbit", "bird"]

## Visual and audio
@export var ambient_sound: String = "res://assets/sounds/ambient/forest.ogg"
@export var primary_color: Color = Color.GREEN  # For debug visualization
@export var tree_sprite_prefix: String = "tree_temperate"  # Sprite naming convention
@export var water_sprite: String = "water_river_brown"

## Metadata
@export var seasonal_variations: Dictionary = {
	"spring": {"spawn_modifier": 1.5, "visual_variant": "spring"},
	"summer": {"spawn_modifier": 1.5, "visual_variant": "summer"},
	"fall": {"spawn_modifier": 0.8, "visual_variant": "fall"},
	"winter": {"spawn_modifier": 0.3, "visual_variant": "winter"}
}

## Get spawn rate for specific resource type with optional modifiers
func get_spawn_rate(resource_type: String, season_modifier: float = 1.0) -> float:
	if resource_type in spawn_rates:
		return spawn_rates[resource_type] * season_modifier
	return 0.0

## Get terrain type speed multiplier
func get_speed_multiplier(terrain_type: String) -> float:
	if terrain_type in terrain_speed_multipliers:
		return terrain_speed_multipliers[terrain_type]
	return 1.0  # Default no modifier

## Get all forage items available in this biome
func get_forage_items() -> Array[String]:
	return forage_items.duplicate()

## Get all huntable animals in this biome
func get_huntable_animals() -> Array[String]:
	return huntable_animals.duplicate()

## Get visual variant for given season
func get_season_variant(season: String) -> Dictionary:
	if season in seasonal_variations:
		return seasonal_variations[season]
	return {"spawn_modifier": 1.0, "visual_variant": "default"}

## Generate info string for debugging
func get_info_string() -> String:
	return "[%s] %s - Tier: %s, Temp: %+.1f°C, Forage: %d items, Animals: %d types" % [
		biome_id, display_name, difficulty_tier, base_temperature,
		forage_items.size(), huntable_animals.size()
	]
