## ResourceNodeObject - Example WorldObject subtype
## Represents temporary resource nodes (forage, fishing spots, hunting areas)

class_name ResourceNodeObject
extends WorldObject

# ============================================
# PROPERTIES
# ============================================

@export var node_type: String = "forage"     # forage, fishing, hunting, etc.
@export var resource_amount: int = 50        # Available resources (0-50)
@export var respawn_time: float = 3600.0     # Respawn time in seconds (1 hour default)

# ============================================
# INTERNAL VARIABLES
# ============================================

var _depleted: bool = false
var _respawn_timer: float = 0.0
var _last_harvest_time: float = 0.0


# ============================================
# LIFECYCLE
# ============================================

func _ready() -> void:
	"""Initialize resource node with sprite and properties."""

	object_type = "resource_node"
	collision_shape_type = "sphere"

	super._ready()  # Call parent initialization

	# Set default resource node sprite
	_setup_sprite()


func _process(delta: float) -> void:
	"""Handle respawning."""
	if _depleted:
		_respawn_timer += delta
		if _respawn_timer >= respawn_time:
			_respawn()


# ============================================
# PUBLIC METHODS
# ============================================

func try_harvest(harvest_amount: int = 10) -> Dictionary:
	"""
	Attempt to harvest from this resource node.

	Args:
		harvest_amount: Amount to harvest (default 10)

	Returns:
		Dictionary with {success, resource_type, quantity, depleted, message}
	"""

	if _depleted:
		return {
			"success": false,
			"message": "This resource node is depleted. Check back later.",
			"respawn_time_remaining": respawn_time - _respawn_timer
		}

	var actual_harvest = min(harvest_amount, resource_amount)
	resource_amount -= actual_harvest

	var newly_depleted = resource_amount <= 0
	if newly_depleted:
		_depleted = true
		_last_harvest_time = Time.get_ticks_msec() / 1000.0
		_respawn_timer = 0.0

	return {
		"success": true,
		"resource_type": _get_resource_type(),
		"quantity": actual_harvest,
		"remaining": resource_amount,
		"depleted": newly_depleted,
		"message": "Harvested %d %s from %s node" % [actual_harvest, _get_resource_type(), node_type]
	}


func is_available() -> bool:
	"""Check if node is available for harvesting."""
	return not _depleted


func get_respawn_progress() -> float:
	"""Get respawn progress (0-1, where 1 = fully respawned)."""
	if not _depleted:
		return 1.0
	return _respawn_timer / respawn_time


# ============================================
# PRIVATE METHODS
# ============================================

func _setup_sprite() -> void:
	"""Configure sprite for this resource node type."""

	# In a real implementation, load texture based on node_type
	var sprite_path = "res://assets/sprites/objects/resources/%s.png" % node_type

	var texture = load(sprite_path)
	if texture != null:
		set_sprite_texture(texture)
	else:
		# Fallback: create placeholder colored sphere
		var placeholder = Image.create(16, 16, false, Image.FORMAT_RGB8)
		var color = _get_node_color()
		placeholder.fill(color)
		var placeholder_texture = ImageTexture.create_from_image(placeholder)
		set_sprite_texture(placeholder_texture)


func _get_resource_type() -> String:
	"""Get resource type name based on node_type."""

	var resource_map = {
		"forage": "food",
		"fishing": "fish",
		"hunting": "game",
		"berries": "berries",
		"mushrooms": "mushrooms",
	}

	return resource_map.get(node_type, "generic_resource")


func _get_node_color() -> Color:
	"""Get color for placeholder based on node type."""

	var color_map = {
		"forage": Color(0.4, 0.8, 0.4),      # Green
		"fishing": Color(0.4, 0.6, 0.9),    # Blue
		"hunting": Color(0.8, 0.4, 0.2),    # Brown
		"berries": Color(0.9, 0.4, 0.6),    # Red
		"mushrooms": Color(0.7, 0.5, 0.8),  # Purple
	}

	return color_map.get(node_type, Color.GRAY)


func _respawn() -> void:
	"""Respawn the resource node."""
	_depleted = false
	resource_amount = 50  # Reset to default
	_respawn_timer = 0.0
