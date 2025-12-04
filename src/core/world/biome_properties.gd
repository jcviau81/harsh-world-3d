## BiomeProperties - Handles biome-specific gameplay mechanics
## Manages movement speed modifiers, temperature effects, difficulty adjustments

class_name BiomeProperties
extends RefCounted

## Get movement speed multiplier for current biome and terrain
static func get_movement_speed_modifier(biome_id: String, terrain_type: String) -> float:
	return BiomeDefinitions.get_speed_multiplier(biome_id, terrain_type)

## Get base temperature adjustment for biome
static func get_temperature_adjustment(biome_id: String) -> float:
	return BiomeDefinitions.get_base_temperature(biome_id)

## Get difficulty tier for biome
static func get_difficulty_tier(biome_id: String) -> String:
	return BiomeDefinitions.get_difficulty(biome_id)

## Apply biome movement speed modifier to player
## Call this in Player._process() when moving
static func apply_movement_modifier(_player: Node, biome_id: String, terrain_type: String) -> float:
	var modifier = get_movement_speed_modifier(biome_id, terrain_type)
	return modifier

## Get temperature effects on stamina regeneration
## Cold biomes reduce stamina regen, warm biomes increase it
static func get_stamina_regen_modifier(biome_id: String) -> float:
	var temp = get_temperature_adjustment(biome_id)
	# Temperature -10°C → 0.5x regen (slow)
	# Temperature +10°C → 1.5x regen (fast)
	# Formula: 1.0 + (temp / 20.0)
	return max(0.5, 1.0 + (temp / 20.0))

## Get temperature effects on health drain
## Cold biomes drain more health (hunger/hypothermia)
static func get_health_drain_modifier(biome_id: String) -> float:
	var temp = get_temperature_adjustment(biome_id)
	# Cold increases drain, heat decreases it
	# Formula: 1.0 - (temp / 30.0) clamped to 0.5-1.5
	return clamp(1.0 - (temp / 30.0), 0.5, 1.5)

## Get difficulty-based resource scarcity
## Hard biomes have fewer resources
static func get_resource_scarcity_modifier(biome_id: String) -> float:
	var difficulty = get_difficulty_tier(biome_id)
	match difficulty:
		"easy":
			return 0.8  # 20% resource reduction (abundance)
		"moderate":
			return 1.0  # No modification
		"hard":
			return 1.3  # 30% resource reduction (scarcity)
	return 1.0

## Get danger level for this biome (affects enemy spawn rates, etc)
static func get_danger_level(biome_id: String) -> int:
	var difficulty = get_difficulty_tier(biome_id)
	match difficulty:
		"easy":
			return 1
		"moderate":
			return 2
		"hard":
			return 3
	return 2

## Check if biome has water navigation available
static func has_water_navigation(biome_id: String) -> bool:
	return biome_id in ["coastal_atlantic", "wetlands"]

## Get visibility range modifier (weather/fog effects)
## Mountains and dense forests reduce visibility
static func get_visibility_modifier(biome_id: String) -> float:
	match biome_id:
		"coastal_atlantic":
			return 1.0  # Clear visibility
		"temperate_forest":
			return 0.8  # Trees obscure vision
		"deciduous_forest":
			return 0.75  # Dense forest
		"grasslands":
			return 1.2  # Enhanced visibility
		"appalachian_mountains":
			return 0.7  # Peaks, obscured valleys
		"boreal_forest":
			return 0.6  # Very dense
		"wetlands":
			return 0.8  # Fog/mist
	return 1.0

## Get list of danger types in this biome (for future enemy/hazard systems)
static func get_danger_types(biome_id: String) -> Array[String]:
	match biome_id:
		"coastal_atlantic":
			return ["drowning", "cold"]
		"temperate_forest":
			return ["wildlife", "disorientation"]
		"deciduous_forest":
			return ["wildlife", "cold"]
		"grasslands":
			return ["exposure", "dehydration"]
		"appalachian_mountains":
			return ["falls", "cold", "avalanche"]
		"boreal_forest":
			return ["cold", "wildlife"]
		"wetlands":
			return ["drowning", "hypothermia", "disease"]
	return []

## Debug info for biome
static func get_biome_info(biome_id: String) -> String:
	var tier = get_difficulty_tier(biome_id)
	var temp = get_temperature_adjustment(biome_id)
	var danger = get_danger_level(biome_id)

	return "[%s] Difficulty: %s, Temp: %+.1f°C, Danger: %d" % [biome_id, tier, temp, danger]
