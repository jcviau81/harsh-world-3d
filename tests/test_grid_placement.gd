## Grid Placement & Snapping Validation Tests
## Validates that WorldObject grid snapping works correctly

class_name TestGridPlacement
extends Node

# ============================================
# CONSTANTS
# ============================================

const GRID_SIZE: int = 1
const TEST_OBJECT_COUNT: int = 10

# ============================================
# TEST SETUP
# ============================================

var world_objects: Array[WorldObject] = []


func setup() -> void:
	"""Setup test fixture."""
	world_objects.clear()
	await get_tree().process_frame


func teardown() -> void:
	"""Clean up test fixture."""
	for obj in world_objects:
		if obj:
			obj.queue_free()
	world_objects.clear()


# ============================================
# TEST 1: SINGLE OBJECT GRID SNAPPING
# ============================================

func test_single_object_snaps_to_grid() -> void:
	"""AC-6: Object placed at non-grid position snaps correctly"""

	var obj = WorldObject.new()
	obj.position = Vector3(5.3, 0, 7.8)  # Non-grid position
	add_child(obj)
	await get_tree().process_frame

	# After snap, position should be at grid boundary
	var expected = GridHelper.snap_to_grid(Vector3(5.3, 0, 7.8), GRID_SIZE)
	assert(obj.position == expected, "Position should snap to grid boundary")
	assert(obj.position.x == floor(obj.position.x), "X should be integer or half")
	assert(obj.position.z == floor(obj.position.z), "Z should be integer or half")

	print("✓ TEST 1 PASSED: Single object snaps correctly")
	obj.queue_free()


# ============================================
# TEST 2: MULTIPLE OBJECTS GRID SNAPPING
# ============================================

func test_multiple_objects_snap() -> void:
	"""AC-9: Multiple objects all snap correctly"""

	var test_positions = [
		Vector3(2.3, 0, 3.7),
		Vector3(10.1, 0, 5.9),
		Vector3(-3.4, 0, 8.2),
		Vector3(0.5, 0, 0.5),
		Vector3(15.8, 0, 15.9),
	]

	for test_pos in test_positions:
		var obj = WorldObject.new()
		obj.position = test_pos
		add_child(obj)
		await get_tree().process_frame

		var expected = GridHelper.snap_to_grid(test_pos, GRID_SIZE)
		assert(obj.position == expected,
			"Position %s should snap to %s" % [test_pos, expected])

		world_objects.append(obj)

	assert(world_objects.size() == test_positions.size(),
		"All objects should be created")

	print("✓ TEST 2 PASSED: Multiple objects snap correctly")


# ============================================
# TEST 3: GRID POSITION STORAGE
# ============================================

func test_grid_position_storage() -> void:
	"""AC-7: Grid position correctly stored after snapping"""

	var obj = WorldObject.new()
	obj.grid_size = 1
	obj.position = Vector3(7.3, 0, 5.8)
	add_child(obj)
	await get_tree().process_frame

	# Verify grid position is stored
	var grid_pos = obj.get_grid_position()
	assert(grid_pos is Vector2i, "Grid position should be Vector2i")

	# Verify grid position matches snapped world position
	var expected_world = GridHelper.grid_to_world(grid_pos, GRID_SIZE)
	assert(obj.position == expected_world,
		"Grid position should correspond to snapped world position")

	print("✓ TEST 3 PASSED: Grid position correctly stored")
	obj.queue_free()


# ============================================
# TEST 4: GRID POSITION SETTING
# ============================================

func test_set_grid_position() -> void:
	"""AC-8: Setting grid position updates world position correctly"""

	var obj = WorldObject.new()
	add_child(obj)
	await get_tree().process_frame

	# Set grid position
	var target_grid = Vector2i(10, 15)
	obj.set_grid_position(target_grid)

	# Verify grid position updated
	assert(obj.get_grid_position() == target_grid,
		"Grid position should update to target")

	# Verify world position matches grid position
	var expected_world = GridHelper.grid_to_world(target_grid, GRID_SIZE)
	assert(obj.position == expected_world,
		"World position should match grid to world conversion")

	print("✓ TEST 4 PASSED: Grid position setting works correctly")
	obj.queue_free()


# ============================================
# TEST 5: ROUND-TRIP CONVERSION
# ============================================

func test_grid_world_round_trip() -> void:
	"""AC-6: Converting world→grid→world preserves position"""

	var test_positions = [
		Vector3(5, 0, 5),
		Vector3(10, 0, 10),
		Vector3(0, 0, 0),
		Vector3(32, 0, 32),
	]

	for world_pos in test_positions:
		# World → Grid → World
		var grid_pos = GridHelper.world_to_grid(world_pos, GRID_SIZE)
		var back_to_world = GridHelper.grid_to_world(grid_pos, GRID_SIZE)

		assert(back_to_world == world_pos,
			"Round-trip conversion should preserve position")

	print("✓ TEST 5 PASSED: Round-trip conversion preserves position")


# ============================================
# TEST 6: CHUNK BOUNDARY POSITIONS
# ============================================

func test_chunk_boundary_snapping() -> void:
	"""AC-10: Objects at chunk boundaries snap correctly"""

	# Test positions at chunk boundaries (32x32 grid)
	var chunk_edges = [
		Vector3(0, 0, 0),
		Vector3(31, 0, 0),
		Vector3(0, 0, 31),
		Vector3(31, 0, 31),
		Vector3(32, 0, 0),
		Vector3(32, 0, 32),
	]

	for edge_pos in chunk_edges:
		var obj = WorldObject.new()
		obj.position = edge_pos
		add_child(obj)
		await get_tree().process_frame

		# Should snap correctly even at boundaries
		var snapped = GridHelper.snap_to_grid(edge_pos, GRID_SIZE)
		assert(obj.position == snapped,
			"Boundary position should snap correctly")

		world_objects.append(obj)

	assert(world_objects.size() == chunk_edges.size(),
		"All boundary tests should complete")

	print("✓ TEST 6 PASSED: Chunk boundaries snap correctly")


# ============================================
# TEST 7: NEGATIVE COORDINATE SNAPPING
# ============================================

func test_negative_coordinate_snapping() -> void:
	"""AC-6: Negative coordinates snap correctly"""

	var negative_positions = [
		Vector3(-5.3, 0, -7.8),
		Vector3(-10.1, 0, -5.9),
		Vector3(-0.5, 0, -0.5),
		Vector3(-32.4, 0, -32.7),
	]

	for neg_pos in negative_positions:
		var obj = WorldObject.new()
		obj.position = neg_pos
		add_child(obj)
		await get_tree().process_frame

		var snapped = GridHelper.snap_to_grid(neg_pos, GRID_SIZE)
		assert(obj.position == snapped,
			"Negative position %s should snap to %s" % [neg_pos, snapped])

		world_objects.append(obj)

	print("✓ TEST 7 PASSED: Negative coordinates snap correctly")

