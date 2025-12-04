## WorldObject Factory
## Creates WorldObject instances of the appropriate type based on configuration

class_name WorldObjectFactory
extends RefCounted

# ============================================
# STATIC FACTORY METHODS
# ============================================

static func create(object_type: String, position: Vector3) -> WorldObject:
	"""Create a WorldObject of the specified type.

	Args:
		object_type: Type name (e.g., "tree", "rock", "structure", "resource_node")
		position: World position where object should be placed

	Returns:
		WorldObject instance of correct type, or generic WorldObject if type unknown
	"""

	var config = ObjectTypes.get_config(object_type)

	# If type not found, create generic WorldObject with fallback
	if config.is_empty():
		push_warning("WorldObjectFactory: Unknown type '%s', creating generic WorldObject" % object_type)
		return _create_generic(object_type, position)

	# Create appropriate subtype based on object_type
	var obj: WorldObject
	match object_type:
		"tree":
			obj = TreeObject.new()
		"rock":
			obj = RockObject.new()
		"structure":
			obj = StructureObject.new()
		"resource_node":
			obj = ResourceNodeObject.new()
		_:
			obj = WorldObject.new()

	# Apply common configuration
	_apply_configuration(obj, object_type, config, position)

	return obj


static func create_from_enum(object_enum: ObjectTypes.ObjectType, position: Vector3) -> WorldObject:
	"""Create a WorldObject using enum instead of string.

	Args:
		object_enum: ObjectTypes.ObjectType enum value
		position: World position

	Returns:
		WorldObject instance
	"""
	var type_name = ObjectTypes.TYPE_NAMES.get(object_enum, "tree")
	return create(type_name, position)


# ============================================
# PRIVATE HELPER METHODS
# ============================================

static func _create_generic(object_type: String, position: Vector3) -> WorldObject:
	"""Create a generic WorldObject with fallback configuration.

	Args:
		object_type: Type name (for object_type property)
		position: World position

	Returns:
		Generic WorldObject
	"""
	var obj = WorldObject.new()
	obj.object_type = object_type
	obj.position = position
	obj.grid_size = 1
	obj.collision_shape_type = "box"
	return obj


static func _apply_configuration(obj: WorldObject, object_type: String, config: Dictionary, position: Vector3) -> void:
	"""Apply type configuration to WorldObject instance.

	Args:
		obj: WorldObject to configure
		object_type: Type name
		config: Configuration dictionary from ObjectTypes
		position: World position
	"""

	# Set basic properties
	obj.object_type = object_type
	obj.position = position
	obj.grid_size = 1

	# Set collision configuration
	if "collision_shape" in config:
		obj.collision_shape_type = config["collision_shape"]

	# Try to load sprite if path exists
	if "sprite_path" in config:
		var sprite_path = config["sprite_path"]
		var sprite_texture = load(sprite_path)
		if sprite_texture != null:
			obj.set_sprite_texture(sprite_texture)
		# else: fallback to default/placeholder handled in WorldObject

	# Set health if applicable (for subtypes)
	if "health" in config and obj.has_meta("health"):
		obj.set_meta("health", config["health"])


# ============================================
# BATCH CREATION HELPER
# ============================================

static func create_batch(object_types: Array[String], positions: Array[Vector3]) -> Array[WorldObject]:
	"""Create multiple objects at once.

	Args:
		object_types: Array of type names
		positions: Array of positions (must match size of object_types)

	Returns:
		Array of created WorldObjects
	"""

	var objects: Array[WorldObject] = []

	if object_types.size() != positions.size():
		push_error("WorldObjectFactory: object_types and positions arrays must be same size")
		return objects

	for i in range(object_types.size()):
		var obj = create(object_types[i], positions[i])
		objects.append(obj)

	return objects
