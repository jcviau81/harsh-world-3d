## StructureObject - Example WorldObject subtype
## Represents structures/ruins (placeholder for Story 4 buildings)

class_name StructureObject
extends WorldObject

# ============================================
# PROPERTIES
# ============================================

@export var structure_type: String = "ruin"  # ruin, shelter, watchtower, etc.
@export var structure_health: int = 200      # durability (0-200)
@export var is_enterable: bool = false       # Can player enter (for Story 4)

# ============================================
# INTERNAL VARIABLES
# ============================================

var _damage_count: int = 0
var _max_durability: int = 200


# ============================================
# LIFECYCLE
# ============================================

func _ready() -> void:
	"""Initialize structure object with sprite and properties."""

	object_type = "structure"
	collision_shape_type = "box"

	super._ready()  # Call parent initialization

	# Set default structure sprite
	_setup_sprite()


# ============================================
# PUBLIC METHODS
# ============================================

func damage(amount: int = 10) -> Dictionary:
	"""
	Apply damage to this structure.

	Args:
		amount: Damage amount (affects structure health)

	Returns:
		Dictionary with {success, health_remaining, is_destroyed, message}
	"""

	if structure_health <= 0:
		return {
			"success": false,
			"message": "This structure is already destroyed."
		}

	structure_health = max(0, structure_health - amount)
	_damage_count += 1

	var destroyed = structure_health <= 0

	return {
		"success": true,
		"health_remaining": structure_health,
		"damage_applied": amount,
		"is_destroyed": destroyed,
		"message": "Structure damaged: %d HP remaining" % [structure_health] if not destroyed else "Structure destroyed"
	}


func is_destroyed() -> bool:
	"""Check if structure is destroyed."""
	return structure_health <= 0


func get_structure_info() -> Dictionary:
	"""Get information about this structure."""
	return {
		"type": structure_type,
		"health": structure_health,
		"max_health": _max_durability,
		"damage_count": _damage_count,
		"enterable": is_enterable,
	}


# ============================================
# PRIVATE METHODS
# ============================================

func _setup_sprite() -> void:
	"""Configure sprite for this structure type."""

	# In a real implementation, load texture based on structure_type
	var sprite_path = "res://assets/sprites/objects/structures/%s.png" % structure_type

	var texture = load(sprite_path)
	if texture != null:
		set_sprite_texture(texture)
	else:
		# Fallback: create placeholder colored box for ruin
		var placeholder = Image.create(32, 32, false, Image.FORMAT_RGB8)
		placeholder.fill(Color(0.6, 0.5, 0.4))  # Brown/ruin color
		var placeholder_texture = ImageTexture.create_from_image(placeholder)
		set_sprite_texture(placeholder_texture)
