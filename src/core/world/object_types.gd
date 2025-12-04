## Object Type Definitions & Configuration
## Defines all object types, their properties, and default configurations

class_name ObjectTypes
extends RefCounted

# ============================================
# OBJECT TYPE ENUMS
# ============================================

enum ObjectType {
	TREE = 0,
	ROCK = 1,
	STRUCTURE = 2,
	RESOURCE_NODE = 3,
}

# ============================================
# TYPE CONFIGURATION CONSTANTS
# ============================================

const TYPE_NAMES = {
	ObjectType.TREE: "tree",
	ObjectType.ROCK: "rock",
	ObjectType.STRUCTURE: "structure",
	ObjectType.RESOURCE_NODE: "resource_node",
}

# Configuration dictionary for each type
# Format: type_name → {sprite, shape, size, health, description}
const TYPE_CONFIGS = {
	"tree": {
		"enum": ObjectType.TREE,
		"display_name": "Tree",
		"sprite_path": "res://assets/sprites/objects/trees/maple.png",
		"collision_shape": "box",
		"collision_size": Vector3(1.0, 2.0, 1.0),
		"health": 100,
		"description": "Forage source - trees yield seeds and nuts"
	},
	"rock": {
		"enum": ObjectType.ROCK,
		"display_name": "Rock",
		"sprite_path": "res://assets/sprites/objects/rocks/granite.png",
		"collision_shape": "box",
		"collision_size": Vector3(1.2, 1.0, 1.2),
		"health": 150,
		"description": "Mining source - rocks yield stone and ore"
	},
	"structure": {
		"enum": ObjectType.STRUCTURE,
		"display_name": "Structure",
		"sprite_path": "res://assets/sprites/objects/structures/ruin.png",
		"collision_shape": "box",
		"collision_size": Vector3(2.0, 2.5, 2.0),
		"health": 200,
		"description": "Shelter/ruin - placeholder for Story 4 buildings"
	},
	"resource_node": {
		"enum": ObjectType.RESOURCE_NODE,
		"display_name": "Resource Node",
		"sprite_path": "res://assets/sprites/objects/resources/forage.png",
		"collision_shape": "sphere",
		"collision_size": Vector3(0.75, 0.75, 0.75),
		"health": 50,
		"description": "Forage/fishing/hunting node - temporary resource source"
	},
}

# ============================================
# STATIC HELPER METHODS
# ============================================

static func get_config(object_type: String) -> Dictionary:
	"""Get configuration for object type.

	Args:
		object_type: Type name (e.g., "tree", "rock")

	Returns:
		Configuration dictionary or empty dict if not found
	"""
	return TYPE_CONFIGS.get(object_type, {})


static func get_type_enum(object_type: String) -> ObjectType:
	"""Get enum value for object type string.

	Args:
		object_type: Type name (e.g., "tree")

	Returns:
		ObjectType enum value
	"""
	var config = TYPE_CONFIGS.get(object_type, {})
	if "enum" in config:
		return config["enum"]
	return ObjectType.TREE  # Default fallback


static func get_display_name(object_type: String) -> String:
	"""Get human-readable display name for type.

	Args:
		object_type: Type name (e.g., "tree")

	Returns:
		Display name (e.g., "Tree")
	"""
	var config = TYPE_CONFIGS.get(object_type, {})
	return config.get("display_name", object_type.capitalize())


static func get_all_types() -> Array[String]:
	"""Get array of all available object types.

	Returns:
		Array of type names: ["tree", "rock", "structure", "resource_node"]
	"""
	return Array(TYPE_CONFIGS.keys())


static func is_valid_type(object_type: String) -> bool:
	"""Check if type is valid.

	Args:
		object_type: Type name

	Returns:
		true if type exists in configuration
	"""
	return object_type in TYPE_CONFIGS
