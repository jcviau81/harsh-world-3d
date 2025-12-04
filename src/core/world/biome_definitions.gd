## Biome Resource Definitions
## Defines biome types and their resource spawning configurations

class_name BiomeDefinitions
extends RefCounted

# ============================================
# BIOME TYPE ENUM
# ============================================

enum BiomeType {
	TEMPERATE_FOREST = 0,
	COASTAL_BEACH = 1,
	MOUNTAIN_RANGE = 2,
	GRASSLAND = 3,
}

# ============================================
# BIOME SPAWN CONFIGURATIONS
# ============================================

const BIOME_CONFIGS = {
	"temperate_forest": {
		"enum": BiomeType.TEMPERATE_FOREST,
		"display_name": "Temperate Forest",
		"spawn_rates": {
			"tree": 0.50,           # 50% trees
			"rock": 0.25,           # 25% rocks
			"resource_node": 0.15,  # 15% forage nodes
			"structure": 0.05,      # 5% ruins
		},
		"resource_distribution": {
			"forage": 0.40,         # 40% of resource nodes are forage
			"fishing": 0.30,        # 30% are fishing spots
			"hunting": 0.20,        # 20% are hunting areas
			"berries": 0.10,        # 10% are berry patches
		},
		"density": 1.0,             # Standard density multiplier
		"description": "Dense forest with trees, rocks, and forage opportunities"
	},

	"coastal_beach": {
		"enum": BiomeType.COASTAL_BEACH,
		"display_name": "Coastal Beach",
		"spawn_rates": {
			"tree": 0.20,           # 20% trees (fewer due to sandy soil)
			"rock": 0.15,           # 15% rocks (scattered boulders)
			"resource_node": 0.45,  # 45% resource nodes (fishing/forage heavy)
			"structure": 0.10,      # 10% ruins (old coastal structures)
		},
		"resource_distribution": {
			"forage": 0.20,         # 20% forage (seaweed, shellfish gathering)
			"fishing": 0.60,        # 60% fishing spots (primary resource)
			"hunting": 0.10,        # 10% hunting (seabirds)
			"berries": 0.10,        # 10% berries (beach plants)
		},
		"density": 0.8,             # Slightly lower density
		"description": "Sandy beaches with fishing opportunities and scattered resources"
	},

	"mountain_range": {
		"enum": BiomeType.MOUNTAIN_RANGE,
		"display_name": "Mountain Range",
		"spawn_rates": {
			"tree": 0.25,           # 25% trees (sparse at high altitude)
			"rock": 0.45,           # 45% rocks (rocky terrain)
			"resource_node": 0.20,  # 20% resource nodes (hunting/minerals)
			"structure": 0.10,      # 10% ruins (mountain settlements)
		},
		"resource_distribution": {
			"forage": 0.10,         # 10% forage (alpine plants)
			"fishing": 0.20,        # 20% fishing (mountain streams)
			"hunting": 0.60,        # 60% hunting (game animals)
			"mushrooms": 0.10,      # 10% mushrooms (shade in caves)
		},
		"density": 0.6,             # Lower density due to altitude
		"description": "Rocky mountains with hunting opportunities and mineral resources"
	},

	"grassland": {
		"enum": BiomeType.GRASSLAND,
		"display_name": "Grassland",
		"spawn_rates": {
			"tree": 0.15,           # 15% trees (scattered)
			"rock": 0.10,           # 10% rocks (sparse)
			"resource_node": 0.55,  # 55% resource nodes (forage/hunting heavy)
			"structure": 0.20,      # 20% structures (settlements)
		},
		"resource_distribution": {
			"forage": 0.50,         # 50% forage (abundant plants)
			"fishing": 0.10,        # 10% fishing (streams/ponds)
			"hunting": 0.35,        # 35% hunting (grassland game)
			"berries": 0.05,        # 5% berries
		},
		"density": 0.7,             # Moderate density
		"description": "Open grasslands with abundant forage and hunting"
	},
}

# ============================================
# STATIC HELPER METHODS
# ============================================

static func get_config(biome_type: String) -> Dictionary:
	"""Get configuration for biome type.

	Args:
		biome_type: Type name (e.g., "temperate_forest")

	Returns:
		Configuration dictionary or empty dict if not found
	"""
	return BIOME_CONFIGS.get(biome_type, {})


static func get_spawn_rates(biome_type: String) -> Dictionary:
	"""Get spawn rates for biome type.

	Args:
		biome_type: Type name

	Returns:
		Dictionary with spawn_rates for each object type
	"""
	var config = BIOME_CONFIGS.get(biome_type, {})
	return config.get("spawn_rates", {})


static func get_resource_distribution(biome_type: String) -> Dictionary:
	"""Get resource node type distribution for biome.

	Args:
		biome_type: Type name

	Returns:
		Dictionary with probability for each resource node type
	"""
	var config = BIOME_CONFIGS.get(biome_type, {})
	return config.get("resource_distribution", {})


static func get_density(biome_type: String) -> float:
	"""Get density multiplier for biome.

	Args:
		biome_type: Type name

	Returns:
		Density multiplier (0.5-1.5)
	"""
	var config = BIOME_CONFIGS.get(biome_type, {})
	return config.get("density", 1.0)


static func get_display_name(biome_type: String) -> String:
	"""Get human-readable display name.

	Args:
		biome_type: Type name

	Returns:
		Display name
	"""
	var config = BIOME_CONFIGS.get(biome_type, {})
	return config.get("display_name", biome_type.capitalize())


static func get_all_biomes() -> Array[String]:
	"""Get array of all available biome types.

	Returns:
		Array of biome names
	"""
	return Array(BIOME_CONFIGS.keys())


static func is_valid_biome(biome_type: String) -> bool:
	"""Check if biome type is valid.

	Args:
		biome_type: Type name

	Returns:
		true if biome exists
	"""
	return biome_type in BIOME_CONFIGS
