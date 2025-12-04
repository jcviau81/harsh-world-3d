## Object Factory Tests
## Validates WorldObjectFactory creates correct object types

class_name TestObjectFactory
extends Node

# ============================================
# TEST SETUP
# ============================================

var created_objects: Array[WorldObject] = []


func setup() -> void:
	"""Setup test fixture."""
	created_objects.clear()
	await get_tree().process_frame


func teardown() -> void:
	"""Clean up test fixture."""
	for obj in created_objects:
		if obj:
			obj.queue_free()
	created_objects.clear()


# ============================================
# TEST 1: TREE OBJECT CREATION
# ============================================

func test_create_tree_object() -> void:
	"""AC-17/19: Factory creates TreeObject for 'tree' type"""

	var tree = WorldObjectFactory.create("tree", Vector3(5, 0, 5))
	assert(tree is TreeObject, "Should create TreeObject for 'tree' type")
	assert(tree.object_type == "tree", "object_type should be 'tree'")

	add_child(tree)
	await get_tree().process_frame

	created_objects.append(tree)
	print("✓ TEST 1 PASSED: TreeObject created correctly")


# ============================================
# TEST 2: ROCK OBJECT CREATION
# ============================================

func test_create_rock_object() -> void:
	"""AC-17/19: Factory creates RockObject for 'rock' type"""

	var rock = WorldObjectFactory.create("rock", Vector3(10, 0, 10))
	assert(rock is RockObject, "Should create RockObject for 'rock' type")
	assert(rock.object_type == "rock", "object_type should be 'rock'")

	add_child(rock)
	await get_tree().process_frame

	created_objects.append(rock)
	print("✓ TEST 2 PASSED: RockObject created correctly")


# ============================================
# TEST 3: STRUCTURE OBJECT CREATION
# ============================================

func test_create_structure_object() -> void:
	"""AC-19: Factory creates StructureObject for 'structure' type"""

	var structure = WorldObjectFactory.create("structure", Vector3(15, 0, 15))
	assert(structure is StructureObject, "Should create StructureObject for 'structure' type")
	assert(structure.object_type == "structure", "object_type should be 'structure'")

	add_child(structure)
	await get_tree().process_frame

	created_objects.append(structure)
	print("✓ TEST 3 PASSED: StructureObject created correctly")


# ============================================
# TEST 4: RESOURCE NODE OBJECT CREATION
# ============================================

func test_create_resource_node_object() -> void:
	"""AC-19: Factory creates ResourceNodeObject for 'resource_node' type"""

	var resource = WorldObjectFactory.create("resource_node", Vector3(20, 0, 20))
	assert(resource is ResourceNodeObject, "Should create ResourceNodeObject for 'resource_node' type")
	assert(resource.object_type == "resource_node", "object_type should be 'resource_node'")

	add_child(resource)
	await get_tree().process_frame

	created_objects.append(resource)
	print("✓ TEST 4 PASSED: ResourceNodeObject created correctly")


# ============================================
# TEST 5: UNKNOWN TYPE FALLBACK
# ============================================

func test_unknown_type_fallback() -> void:
	"""AC-19: Factory handles unknown types gracefully"""

	var unknown = WorldObjectFactory.create("unknown_type", Vector3(0, 0, 0))
	assert(unknown is WorldObject, "Should create generic WorldObject for unknown type")
	assert(unknown.object_type == "unknown_type", "object_type should match requested type")

	add_child(unknown)
	await get_tree().process_frame

	created_objects.append(unknown)
	print("✓ TEST 5 PASSED: Unknown type creates generic WorldObject")


# ============================================
# TEST 6: POSITION ASSIGNMENT
# ============================================

func test_position_assignment() -> void:
	"""AC-18: Factory assigns correct positions to created objects"""

	var positions = [
		Vector3(5, 0, 5),
		Vector3(10, 0, 10),
		Vector3(-5, 0, -5),
	]

	for pos in positions:
		var obj = WorldObjectFactory.create("tree", pos)
		add_child(obj)
		await get_tree().process_frame

		# Position should be snapped to grid
		var snapped = GridHelper.snap_to_grid(pos)
		assert(obj.position == snapped, "Position should be snapped to grid")

		created_objects.append(obj)

	print("✓ TEST 6 PASSED: Positions assigned correctly")


# ============================================
# TEST 7: COLLISION CONFIGURATION
# ============================================

func test_collision_configuration() -> void:
	"""AC-18: Factory applies correct collision configuration per type"""

	var tree = WorldObjectFactory.create("tree", Vector3(0, 0, 0))
	var rock = WorldObjectFactory.create("rock", Vector3(10, 0, 0))
	var resource = WorldObjectFactory.create("resource_node", Vector3(20, 0, 0))

	add_child(tree)
	add_child(rock)
	add_child(resource)
	await get_tree().process_frame

	# Verify collision shapes exist
	assert(tree.get_collision_shape() != null, "Tree should have collision shape")
	assert(rock.get_collision_shape() != null, "Rock should have collision shape")
	assert(resource.get_collision_shape() != null, "Resource should have collision shape")

	# Trees and rocks typically use box, resources use sphere
	assert(tree.get_collision_shape().shape is BoxShape3D, "Tree should use BoxShape3D")
	assert(rock.get_collision_shape().shape is BoxShape3D, "Rock should use BoxShape3D")
	assert(resource.get_collision_shape().shape is SphereShape3D, "Resource should use SphereShape3D")

	created_objects.append(tree)
	created_objects.append(rock)
	created_objects.append(resource)

	print("✓ TEST 7 PASSED: Collision configuration is correct per type")


# ============================================
# TEST 8: BATCH CREATION
# ============================================

func test_batch_creation() -> void:
	"""AC-20: Factory can create multiple objects at once"""

	var types = ["tree", "rock", "structure", "resource_node"]
	var positions = [
		Vector3(0, 0, 0),
		Vector3(5, 0, 5),
		Vector3(10, 0, 10),
		Vector3(15, 0, 15),
	]

	var objects = WorldObjectFactory.create_batch(types, positions)

	assert(objects.size() == 4, "Should create 4 objects")

	for i in range(objects.size()):
		add_child(objects[i])
		await get_tree().process_frame
		created_objects.append(objects[i])

	# Verify types
	assert(objects[0] is TreeObject, "First should be TreeObject")
	assert(objects[1] is RockObject, "Second should be RockObject")
	assert(objects[2] is StructureObject, "Third should be StructureObject")
	assert(objects[3] is ResourceNodeObject, "Fourth should be ResourceNodeObject")

	print("✓ TEST 8 PASSED: Batch creation works correctly")


# ============================================
# TEST 9: OBJECT TYPE CONFIGURATION
# ============================================

func test_object_type_configuration() -> void:
	"""AC-18: ObjectTypes configuration is complete"""

	assert(ObjectTypes.is_valid_type("tree"), "'tree' should be valid type")
	assert(ObjectTypes.is_valid_type("rock"), "'rock' should be valid type")
	assert(ObjectTypes.is_valid_type("structure"), "'structure' should be valid type")
	assert(ObjectTypes.is_valid_type("resource_node"), "'resource_node' should be valid type")

	# Get all types
	var all_types = ObjectTypes.get_all_types()
	assert(all_types.size() == 4, "Should have 4 types configured")
	assert("tree" in all_types, "'tree' should be in all_types")
	assert("rock" in all_types, "'rock' should be in all_types")
	assert("structure" in all_types, "'structure' should be in all_types")
	assert("resource_node" in all_types, "'resource_node' should be in all_types")

	print("✓ TEST 9 PASSED: ObjectTypes configuration is complete")


# ============================================
# TEST 10: TYPE DISPLAY NAMES
# ============================================

func test_type_display_names() -> void:
	"""AC-18: ObjectTypes provides readable display names"""

	assert(ObjectTypes.get_display_name("tree") == "Tree", "Tree display name")
	assert(ObjectTypes.get_display_name("rock") == "Rock", "Rock display name")
	assert(ObjectTypes.get_display_name("structure") == "Structure", "Structure display name")
	assert(ObjectTypes.get_display_name("resource_node") == "Resource Node", "Resource node display name")

	print("✓ TEST 10 PASSED: Type display names are correct")
