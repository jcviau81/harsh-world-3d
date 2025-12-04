## RockObject - Example WorldObject subtype
## Represents rocks and stone resources (for mining/gathering in Story 3.2+)

class_name RockObject
extends WorldObject

# ============================================
# PROPERTIES
# ============================================

@export var rock_type: String = "granite"  # granite, limestone, basalt, etc.
@export var resource_health: int = 100     # durability (0-100)
@export var harvest_tool_required: String = "pickaxe"  # tool needed to harvest

# ============================================
# INTERNAL VARIABLES
# ============================================

var _harvest_count: int = 0
var _total_harvests_before_depletion: int = 3  # Rocks yield 3 harvests before breaking


# ============================================
# LIFECYCLE
# ============================================

func _ready() -> void:
	"""Initialize rock object with sprite and properties."""

	object_type = "rock"
	collision_shape_type = "box"

	super._ready()  # Call parent initialization

	# Set default rock sprite
	_setup_sprite()


# ============================================
# PUBLIC METHODS
# ============================================

func try_harvest(tool_quality: int = 0) -> Dictionary:
	"""
	Attempt to harvest from this rock.

	Args:
		tool_quality: Quality level of harvesting tool (affects yield)

	Returns:
		Dictionary with {success, resource_type, quantity, durability_lost, message}
	"""

	# Check if rock is already depleted
	if _harvest_count >= _total_harvests_before_depletion:
		return {
			"success": false,
			"message": "This rock is completely depleted."
		}

	# Perform harvest
	_harvest_count += 1
	resource_health -= 25 + (tool_quality * 5)

	var harvest_amount = 1 + tool_quality

	return {
		"success": true,
		"resource_type": _get_resource_type(),
		"quantity": harvest_amount,
		"durability_lost": 25 + (tool_quality * 5),
		"depleted": _harvest_count >= _total_harvests_before_depletion,
		"message": "Harvested %d %s from %s rock" % [harvest_amount, _get_resource_type(), rock_type]
	}


func can_harvest() -> bool:
	"""Check if rock still has resources."""
	return _harvest_count < _total_harvests_before_depletion


func get_depletion_percentage() -> float:
	"""Get how depleted this rock is (0-100%)."""
	return float(_harvest_count) / float(_total_harvests_before_depletion) * 100.0


# ============================================
# PRIVATE METHODS
# ============================================

func _setup_sprite() -> void:
	"""Configure sprite for this rock type."""

	# In a real implementation, load texture based on rock_type
	var sprite_path = "res://assets/sprites/objects/rocks/%s.png" % rock_type

	var texture = load(sprite_path)
	if texture != null:
		set_sprite_texture(texture)
	else:
		# Fallback: create placeholder colored box
		var placeholder = Image.create(16, 16, false, Image.FORMAT_RGB8)
		placeholder.fill(Color.GRAY)
		var placeholder_texture = ImageTexture.create_from_image(placeholder)
		set_sprite_texture(placeholder_texture)


func _get_resource_type() -> String:
	"""Get resource type based on rock type (stub)."""

	var resources = {
		"granite": "stone",
		"limestone": "limestone",
		"basalt": "iron_ore",
		"quartz": "crystal",
	}

	return resources.get(rock_type, "generic_stone")
