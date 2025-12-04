## Grid utility functions for snapping and coordinate conversion
## Provides world ↔ grid coordinate transformation

class_name GridHelper
extends RefCounted

# ============================================
# STATIC METHODS
# ============================================

static func snap_to_grid(world_position: Vector3, grid_size: int = 1) -> Vector3:
	"""
	Snap world position to nearest grid cell.

	Args:
		world_position: Position in world coordinates
		grid_size: Size of each grid cell (default: 1 unit)

	Returns:
		Snapped position aligned to grid

	Example:
		snap_to_grid(Vector3(1.7, 0, 2.3)) → Vector3(2, 0, 2)
	"""

	if grid_size <= 0:
		push_error("GridHelper: grid_size must be > 0")
		return world_position

	var snapped = Vector3(
		round(world_position.x / grid_size) * grid_size,
		world_position.y,  # Don't snap Y (height is continuous)
		round(world_position.z / grid_size) * grid_size
	)

	return snapped


static func world_to_grid(world_position: Vector3, grid_size: int = 1) -> Vector2i:
	"""
	Convert world coordinates to grid coordinates.

	Args:
		world_position: Position in world coordinates (x, z)
		grid_size: Size of each grid cell (default: 1 unit)

	Returns:
		Grid coordinates as Vector2i (grid_x, grid_z)

	Note:
		Ignores Y coordinate (height); only uses X and Z for grid
	"""

	if grid_size <= 0:
		push_error("GridHelper: grid_size must be > 0")
		return Vector2i(0, 0)

	return Vector2i(
		int(round(world_position.x / grid_size)),
		int(round(world_position.z / grid_size))
	)


static func grid_to_world(grid_position: Vector2i, grid_size: int = 1, y: float = 0.0) -> Vector3:
	"""
	Convert grid coordinates to world coordinates.

	Args:
		grid_position: Grid coordinates (grid_x, grid_z)
		grid_size: Size of each grid cell (default: 1 unit)
		y: Height (Y coordinate) for the world position

	Returns:
		World position as Vector3

	Example:
		grid_to_world(Vector2i(2, 2)) → Vector3(2, 0, 2)
	"""

	return Vector3(
		float(grid_position.x) * grid_size,
		y,
		float(grid_position.y) * grid_size
	)


static func get_adjacent_grid_cells(grid_position: Vector2i) -> Array[Vector2i]:
	"""
	Get the 8 adjacent grid cells around a position (3x3 grid).

	Returns:
		Array of Vector2i for adjacent cells (includes diagonals)
	"""

	var adjacent: Array[Vector2i] = []

	for x in range(-1, 2):
		for z in range(-1, 2):
			if x == 0 and z == 0:
				continue  # Skip center (self)

			adjacent.append(Vector2i(grid_position.x + x, grid_position.y + z))

	return adjacent


static func distance_grid_cells(grid_pos1: Vector2i, grid_pos2: Vector2i) -> int:
	"""
	Calculate Manhattan distance between two grid cells.

	Useful for spawn rate calculations and proximity checks.
	"""

	return abs(grid_pos1.x - grid_pos2.x) + abs(grid_pos1.y - grid_pos2.y)
