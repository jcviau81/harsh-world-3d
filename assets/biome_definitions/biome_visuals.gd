## Biome Visual Configuration
## Maps biomes to sprite sets and visual properties

class_name BiomeVisuals
extends RefCounted

# Sprite path templates for each biome
const BIOME_SPRITES = {
	"coastal_atlantic": {
		"trees": ["willow_tree"],
		"water": "water_ocean_blue",
		"rocks": "rock_coastal",
		"color_overlay": Color.CYAN,
		"ambient_brightness": 1.0
	},
	"temperate_forest": {
		"trees": ["maple_tree", "oak_tree"],
		"water": "water_river_brown",
		"rocks": "rock_forest",
		"color_overlay": Color.GREEN,
		"ambient_brightness": 0.95
	},
	"deciduous_forest": {
		"trees": ["birch_tree", "aspen_tree"],
		"water": "water_stream_blue",
		"rocks": "rock_forest",
		"color_overlay": Color(0.8, 0.6, 0.2),
		"ambient_brightness": 0.9
	},
	"grasslands": {
		"trees": ["oak_tree"],  # Sparse
		"water": "water_lake_blue",
		"rocks": "rock_plains",
		"color_overlay": Color.YELLOW,
		"ambient_brightness": 1.1
	},
	"appalachian_mountains": {
		"trees": ["pine_tree"],
		"water": "water_mountain_stream",
		"rocks": "rock_mountain",
		"color_overlay": Color(0.7, 0.7, 0.7),
		"ambient_brightness": 0.85
	},
	"boreal_forest": {
		"trees": ["spruce_tree", "fir_tree"],
		"water": "water_frozen_lake",
		"rocks": "rock_mountain",
		"color_overlay": Color.DARK_GREEN,
		"ambient_brightness": 0.8
	},
	"wetlands": {
		"trees": ["willow_tree"],
		"water": "water_marsh_green",
		"rocks": "rock_wetland",
		"color_overlay": Color(0.2, 0.6, 0.4),
		"ambient_brightness": 0.9
	}
}

# Seasonal sprite variants
const SEASONAL_VARIANTS = {
	"spring": {
		"color_tint": Color.GREEN,
		"brightness_mod": 1.1,
		"variant_suffix": "_spring"
	},
	"summer": {
		"color_tint": Color.GREEN,
		"brightness_mod": 1.2,
		"variant_suffix": "_summer"
	},
	"fall": {
		"color_tint": Color(1.0, 0.8, 0.2),
		"brightness_mod": 1.0,
		"variant_suffix": "_fall"
	},
	"winter": {
		"color_tint": Color.WHITE,
		"brightness_mod": 0.8,
		"variant_suffix": "_winter"
	}
}

## Get sprite path for object in biome
static func get_sprite_path(biome_id: String, object_type: String) -> String:
	if biome_id not in BIOME_SPRITES:
		return "res://assets/sprites/objects/default.png"

	var biome_data = BIOME_SPRITES[biome_id]

	match object_type:
		"tree":
			var trees = biome_data.get("trees", ["oak_tree"])
			return "res://assets/sprites/objects/trees/%s.png" % trees[0]
		"water":
			return "res://assets/sprites/water/%s.png" % biome_data.get("water", "water_blue")
		"rock":
			return "res://assets/sprites/objects/rocks/%s.png" % biome_data.get("rocks", "rock_generic")
		_:
			return "res://assets/sprites/objects/default.png"

## Get color overlay for biome
static func get_biome_color(biome_id: String) -> Color:
	if biome_id in BIOME_SPRITES:
		return BIOME_SPRITES[biome_id].get("color_overlay", Color.WHITE)
	return Color.WHITE

## Get ambient lighting adjustment for biome
static func get_ambient_brightness(biome_id: String) -> float:
	if biome_id in BIOME_SPRITES:
		return BIOME_SPRITES[biome_id].get("ambient_brightness", 1.0)
	return 1.0

## Get seasonal variant properties
static func get_seasonal_variant(season: String) -> Dictionary:
	if season in SEASONAL_VARIANTS:
		return SEASONAL_VARIANTS[season]
	return {
		"color_tint": Color.WHITE,
		"brightness_mod": 1.0,
		"variant_suffix": ""
	}

## Get sprite with seasonal tint applied
static func get_seasonal_sprite(biome_id: String, object_type: String, season: String) -> Dictionary:
	var base_sprite = get_sprite_path(biome_id, object_type)
	var base_color = get_biome_color(biome_id)
	var seasonal = get_seasonal_variant(season)

	# Blend colors
	var tinted_color = base_color
	tinted_color = tinted_color.lerp(seasonal.get("color_tint", Color.WHITE), 0.3)

	return {
		"sprite_path": base_sprite,
		"color_tint": tinted_color,
		"brightness": get_ambient_brightness(biome_id) * seasonal.get("brightness_mod", 1.0),
		"season": season
	}

## Get all tree types available in biome
static func get_tree_types(biome_id: String) -> Array[String]:
	if biome_id in BIOME_SPRITES:
		return BIOME_SPRITES[biome_id].get("trees", [])
	return []

## Get water sprite for biome
static func get_water_sprite(biome_id: String) -> String:
	if biome_id in BIOME_SPRITES:
		return BIOME_SPRITES[biome_id].get("water", "water_generic")
	return "water_generic"
