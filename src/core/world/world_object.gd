## Base class for all world objects (terrain features, structures, resources)
## Provides Sprite3D rendering with CollisionShape3D for interaction
## Supports grid-snapping and biome-based spawning

class_name WorldObject
extends StaticBody3D

# ============================================
# CONSTANTS
# ============================================

const DEFAULT_SPRITE_SCALE: float = 1.0
const DEFAULT_COLLISION_LAYER: int = 2  # terrain_objects layer
const DEFAULT_COLLISION_MASK: int = 1   # collide with player (layer 1)

# ============================================
# PROPERTIES
# ============================================

@export var object_type: String = "generic"  # tree, rock, structure, resource_node
@export var visual_id: int = 0               # sprite variant selection
@export var grid_size: int = 1               # grid cell size (1 = 1x1 units)
@export var sprite_scale: float = 1.0        # scale for rendering
@export var collision_shape_type: String = "box"  # box, capsule, sphere
@export var collision_layer_value: int = DEFAULT_COLLISION_LAYER
@export var collision_mask_value: int = DEFAULT_COLLISION_MASK

# ============================================
# INTERNAL VARIABLES
# ============================================

var _sprite: Sprite3D
var _collision_shape: CollisionShape3D
var _grid_position: Vector2i  # grid coordinates (x, y)

# ============================================
# LIFECYCLE
# ============================================

func _ready() -> void:
	"""Initialize WorldObject with Sprite3D and CollisionShape3D."""

	# Create and configure Sprite3D child
	_sprite = Sprite3D.new()
	_sprite.centered = true
	_sprite.pixel_size = 1.0 / sprite_scale
	add_child(_sprite)

	# Create and configure CollisionShape3D child
	_collision_shape = CollisionShape3D.new()
	_setup_collision_shape()
	add_child(_collision_shape)

	# Configure collision layers
	_setup_collision_layers()

	# Snap position to grid
	_snap_to_grid()

	# Store grid position
	_grid_position = GridHelper.world_to_grid(position, grid_size)


# ============================================
# PUBLIC METHODS
# ============================================

func set_sprite_texture(texture: Texture2D) -> void:
	"""Set the sprite texture for this object."""
	if _sprite != null and texture != null:
		_sprite.texture = texture


func get_grid_position() -> Vector2i:
	"""Get the grid coordinates of this object."""
	return _grid_position


func set_grid_position(grid_pos: Vector2i) -> void:
	"""Move object to grid position."""
	_grid_position = grid_pos
	position = GridHelper.grid_to_world(grid_pos, grid_size)


func get_collision_shape() -> CollisionShape3D:
	"""Get reference to collision shape (for custom configuration)."""
	return _collision_shape


# ============================================
# PRIVATE METHODS
# ============================================

func _snap_to_grid() -> void:
	"""Snap object position to grid."""
	position = GridHelper.snap_to_grid(position, grid_size)


func _setup_collision_shape() -> void:
	"""Create and configure collision shape based on object type."""

	var shape: Shape3D

	match collision_shape_type:
		"box":
			shape = BoxShape3D.new()
			shape.size = Vector3(1.0, 2.0, 1.0)  # Default tree-like proportions
		"capsule":
			shape = CapsuleShape3D.new()
			shape.radius = 0.5
			shape.height = 2.0
		"sphere":
			shape = SphereShape3D.new()
			shape.radius = 0.75
		_:
			shape = BoxShape3D.new()
			shape.size = Vector3(1.0, 1.0, 1.0)

	_collision_shape.shape = shape


func _setup_collision_layers() -> void:
	"""Configure collision layers and masks for this object.

	Sets:
	- collision_layer = 2 (terrain_objects layer)
	- collision_mask = 1 (collides with player layer)
	"""

	# Note: CollisionShape3D inherits layer/mask from parent PhysicsBody3D
	# These values should be set on the parent node when WorldObject is added to scene
	# For now, document the configuration in properties
	# Layer 2: terrain_objects
	# Mask 1: player (this object collides with player)

	# Store in properties for later parent setup
	collision_layer_value = 2  # Terrain objects layer
	collision_mask_value = 1   # Collide with player layer


# ============================================
# DEBUGGING
# ============================================

func _get_debug_string() -> String:
	"""Return debug info string."""
	return "WorldObject[%s] @ grid(%d, %d) pos(%.1f, %.1f, %.1f)" % [
		object_type,
		_grid_position.x,
		_grid_position.y,
		position.x,
		position.y,
		position.z
	]
