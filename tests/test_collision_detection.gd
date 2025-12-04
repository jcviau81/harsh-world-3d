## Collision Detection Tests
## Validates collision system integration between WorldObjects and player

class_name TestCollisionDetection
extends Node

# ============================================
# CONSTANTS
# ============================================

const WORLD_OBJECT_LAYER: int = 2  # terrain_objects
const WORLD_OBJECT_MASK: int = 1   # collides with player
const PLAYER_LAYER: int = 1
const PLAYER_MASK: int = 2         # collides with terrain_objects


# ============================================
# TEST SETUP
# ============================================

var world_objects: Array[WorldObject] = []
var test_player: CharacterBody3D


func setup() -> void:
	"""Setup test fixture."""
	world_objects.clear()
	test_player = null
	await get_tree().process_frame


func teardown() -> void:
	"""Clean up test fixture."""
	for obj in world_objects:
		if obj:
			obj.queue_free()
	world_objects.clear()

	if test_player:
		test_player.queue_free()
		test_player = null


# ============================================
# TEST 1: COLLISION SHAPE TYPES
# ============================================

func test_collision_shapes_configured() -> void:
	"""AC-11: CollisionShape3D uses configured shapes"""

	var obj = WorldObject.new()
	add_child(obj)
	await get_tree().process_frame

	var collision_shape = obj.get_collision_shape()
	assert(collision_shape != null, "CollisionShape3D should exist")
	assert(collision_shape.shape != null, "CollisionShape3D should have a shape")

	# Default is BoxShape3D
	assert(collision_shape.shape is BoxShape3D,
		"Default collision shape should be BoxShape3D")

	world_objects.append(obj)
	print("✓ TEST 1 PASSED: Collision shapes are configured")


# ============================================
# TEST 2: COLLISION LAYER CONFIGURATION
# ============================================

func test_collision_layer_values() -> void:
	"""AC-12: Collision layers and masks configured correctly"""

	var obj = WorldObject.new()
	add_child(obj)
	await get_tree().process_frame

	# Verify collision layer value is stored
	assert(obj.collision_layer_value == WORLD_OBJECT_LAYER,
		"Collision layer should be 2 (terrain_objects)")
	assert(obj.collision_mask_value == WORLD_OBJECT_MASK,
		"Collision mask should be 1 (player)")

	world_objects.append(obj)
	print("✓ TEST 2 PASSED: Collision layer values are configured")


# ============================================
# TEST 3: MULTIPLE COLLISION SHAPES
# ============================================

func test_multiple_object_collision_shapes() -> void:
	"""AC-15: Multiple objects have proper collision shapes"""

	for i in range(5):
		var obj = WorldObject.new()
		obj.position = Vector3(i * 5, 0, 0)
		add_child(obj)
		await get_tree().process_frame

		var collision_shape = obj.get_collision_shape()
		assert(collision_shape != null and collision_shape.shape != null,
			"Object %d should have collision shape" % i)

		world_objects.append(obj)

	assert(world_objects.size() == 5,
		"All 5 objects should be created with collision shapes")

	print("✓ TEST 3 PASSED: Multiple objects have proper collision shapes")


# ============================================
# TEST 4: COLLISION SHAPE SIZES
# ============================================

func test_collision_shape_sizing() -> void:
	"""AC-16: Collision shapes are appropriately sized"""

	var obj = WorldObject.new()
	obj.collision_shape_type = "box"
	add_child(obj)
	await get_tree().process_frame

	var collision_shape = obj.get_collision_shape()
	assert(collision_shape.shape is BoxShape3D, "Should be BoxShape3D")

	var box_shape = collision_shape.shape as BoxShape3D
	assert(box_shape.size != Vector3.ZERO, "Box shape should have non-zero size")
	assert(box_shape.size.x > 0 and box_shape.size.y > 0 and box_shape.size.z > 0,
		"All dimensions should be positive")

	world_objects.append(obj)
	print("✓ TEST 4 PASSED: Collision shapes are properly sized")


# ============================================
# TEST 5: CAPSULE COLLISION SHAPE
# ============================================

func test_capsule_collision_shape() -> void:
	"""AC-11: Capsule shape can be configured"""

	var obj = WorldObject.new()
	obj.collision_shape_type = "capsule"
	add_child(obj)
	await get_tree().process_frame

	var collision_shape = obj.get_collision_shape()
	assert(collision_shape.shape is CapsuleShape3D,
		"Should create CapsuleShape3D when configured")

	var capsule = collision_shape.shape as CapsuleShape3D
	assert(capsule.radius > 0, "Capsule radius should be positive")
	assert(capsule.height > 0, "Capsule height should be positive")

	world_objects.append(obj)
	print("✓ TEST 5 PASSED: Capsule collision shape works")


# ============================================
# TEST 6: SPHERE COLLISION SHAPE
# ============================================

func test_sphere_collision_shape() -> void:
	"""AC-11: Sphere shape can be configured"""

	var obj = WorldObject.new()
	obj.collision_shape_type = "sphere"
	add_child(obj)
	await get_tree().process_frame

	var collision_shape = obj.get_collision_shape()
	assert(collision_shape.shape is SphereShape3D,
		"Should create SphereShape3D when configured")

	var sphere = collision_shape.shape as SphereShape3D
	assert(sphere.radius > 0, "Sphere radius should be positive")

	world_objects.append(obj)
	print("✓ TEST 6 PASSED: Sphere collision shape works")


# ============================================
# TEST 7: UNKNOWN SHAPE TYPE FALLBACK
# ============================================

func test_unknown_shape_type_fallback() -> void:
	"""AC-11: Unknown shape type defaults to BoxShape3D"""

	var obj = WorldObject.new()
	obj.collision_shape_type = "unknown_type"
	add_child(obj)
	await get_tree().process_frame

	var collision_shape = obj.get_collision_shape()
	assert(collision_shape.shape is BoxShape3D,
		"Unknown shape type should fallback to BoxShape3D")

	world_objects.append(obj)
	print("✓ TEST 7 PASSED: Unknown shape type falls back correctly")


# ============================================
# TEST 8: COLLISION GROUP CONSISTENCY
# ============================================

func test_collision_group_consistency() -> void:
	"""AC-12/13: All objects have consistent collision configuration"""

	for i in range(10):
		var obj = WorldObject.new()
		add_child(obj)
		await get_tree().process_frame

		# All objects should have same layer/mask configuration
		assert(obj.collision_layer_value == WORLD_OBJECT_LAYER,
			"Object %d: layer should be 2" % i)
		assert(obj.collision_mask_value == WORLD_OBJECT_MASK,
			"Object %d: mask should be 1" % i)

		world_objects.append(obj)

	print("✓ TEST 8 PASSED: All objects have consistent collision configuration")
