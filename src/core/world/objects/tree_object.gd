## TreeObject - Example WorldObject subtype
## Represents trees with forage functionality (for Story 3.2)

class_name TreeObject
extends WorldObject

# ============================================
# PROPERTIES
# ============================================

@export var tree_type: String = "maple"  # maple, oak, birch, pine, etc.
@export var health: int = 100            # tree health (0-100)
@export var forage_respawn_time: float = 172800.0  # 2 in-game days in seconds

# ============================================
# INTERNAL VARIABLES
# ============================================

var _last_foraged: float = -forage_respawn_time  # Allow immediate harvest on spawn
var _available_for_forage: bool = true


# ============================================
# LIFECYCLE
# ============================================

func _ready() -> void:
	"""Initialize tree object with sprite and properties."""

	object_type = "tree"
	collision_shape_type = "box"

	super._ready()  # Call parent initialization

	# Set default tree sprite (would be replaced with actual texture)
	_setup_sprite()


# ============================================
# PUBLIC METHODS
# ============================================

func try_forage() -> Dictionary:
	"""
	Attempt to forage from this tree.

	Returns:
		Dictionary with {success, item_type, quantity, message}
	"""

	if not _available_for_forage:
		return {
			"success": false,
			"message": "This tree has been recently foraged. Come back later."
		}

	# Record forage time
	_last_foraged = Time.get_ticks_msec() / 1000.0
	_available_for_forage = false

	# Return forage item based on tree type
	var forage_item = _get_forage_item()

	return {
		"success": true,
		"item_type": forage_item["type"],
		"quantity": forage_item["quantity"],
		"message": "Foraged %d %s from %s tree" % [forage_item["quantity"], forage_item["type"], tree_type]
	}


func can_forage() -> bool:
	"""Check if tree is available for foraging."""
	return _available_for_forage


func check_forage_respawn(current_time: float) -> void:
	"""Check if forage respawn timer has elapsed."""

	if not _available_for_forage:
		var time_since_forage = current_time - _last_foraged
		if time_since_forage >= forage_respawn_time:
			_available_for_forage = true


# ============================================
# PRIVATE METHODS
# ============================================

func _setup_sprite() -> void:
	"""Configure sprite for this tree type."""

	# In a real implementation, load texture based on tree_type
	# For now, use placeholder
	var sprite_path = "res://assets/sprites/objects/trees/%s.png" % tree_type

	var texture = load(sprite_path)
	if texture != null:
		set_sprite_texture(texture)
	else:
		# Fallback: create placeholder colored box
		var placeholder = Image.create(16, 16, false, Image.FORMAT_RGB8)
		placeholder.fill(Color.GREEN)
		var placeholder_texture = ImageTexture.create_from_image(placeholder)
		set_sprite_texture(placeholder_texture)


func _get_forage_item() -> Dictionary:
	"""Get forage item based on tree type (stub for Story 3.2)."""

	# Stub implementation - will be expanded in Story 3.2
	var items = {
		"maple": {"type": "maple_seeds", "quantity": 1},
		"oak": {"type": "acorns", "quantity": 2},
		"birch": {"type": "birch_bark", "quantity": 1},
		"pine": {"type": "pine_nuts", "quantity": 1},
	}

	return items.get(tree_type, {"type": "generic_seeds", "quantity": 1})
