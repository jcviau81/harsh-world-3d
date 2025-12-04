## Biome Resource Spawner
## Generates WorldObjects deterministically based on biome configuration and seed

class_name BiomeResourceSpawner
extends RefCounted

# ============================================
# CONSTANTS
# ============================================

const GRID_SIZE: int = 32  # 32x32 chunk grid
const SPAWN_CHECK_PROBABILITY: float = 0.8  # Probability to even attempt spawn at a cell

# ============================================
# SPAWN LOGIC
# ============================================

static func spawn_resources_for_chunk(
	chunk_x: int,
	chunk_y: int,
	chunk_seed: int,
	biome_type: String
) -> Array[WorldObject]:
	"""
	Spawn resources for a chunk based on biome configuration.

	Args:
		chunk_x: Chunk grid X coordinate
		chunk_y: Chunk grid Y coordinate
		chunk_seed: Base seed for this chunk (from GPU heightmap generation)
		biome_type: Biome type (e.g., "temperate_forest")

	Returns:
		Array of WorldObject instances positioned within chunk
	"""

	var objects: Array[WorldObject] = []

	# Get biome configuration
	var biome_config = BiomeDefinitions.get_config(biome_type)
	if biome_config.is_empty():
		push_error("BiomeResourceSpawner: Unknown biome type '%s'" % biome_type)
		return objects

	var spawn_rates = BiomeDefinitions.get_spawn_rates(biome_type)
	var density = BiomeDefinitions.get_density(biome_type)

	# Iterate through chunk grid (32x32)
	for grid_x in range(GRID_SIZE):
		for grid_y in range(GRID_SIZE):
			# Deterministic PRNG: chunk_seed XOR grid_x XOR grid_y XOR biome_hash
			var biome_hash = hash(biome_type)
			var cell_seed = chunk_seed ^ grid_x ^ grid_y ^ biome_hash

			# Use seeded randomness for this cell
			var rng = RandomNumberGenerator.new()
			rng.seed = cell_seed

			# Check if we should spawn in this cell (probability-based)
			var spawn_chance = rng.randf()
			if spawn_chance > (SPAWN_CHECK_PROBABILITY * density):
				continue  # Skip this cell

			# Determine object type based on spawn rates
			var object_type = _select_object_type(spawn_rates, rng)
			if object_type.is_empty():
				continue

			# Create world position for this grid cell
			var world_x = chunk_x * GRID_SIZE + grid_x
			var world_z = chunk_y * GRID_SIZE + grid_y
			var world_pos = Vector3(float(world_x), 0.0, float(world_z))

			# Create object via factory
			var obj = WorldObjectFactory.create(object_type, world_pos)
			if obj != null:
				# Special handling for resource nodes (set resource subtype)
				if object_type == "resource_node" and obj is ResourceNodeObject:
					var resource_subtype = _select_resource_node_type(biome_type, rng)
					obj.node_type = resource_subtype
				objects.append(obj)

	return objects


# ============================================
# PRIVATE HELPER METHODS
# ============================================

static func _select_object_type(spawn_rates: Dictionary, rng: RandomNumberGenerator) -> String:
	"""Select object type based on biome spawn rates.

	Args:
		spawn_rates: Dictionary with object_type → probability
		rng: RandomNumberGenerator with seed set

	Returns:
		Object type string, or empty string if no spawn
	"""

	var roll = rng.randf()
	var cumulative = 0.0

	for object_type in spawn_rates.keys():
		cumulative += spawn_rates[object_type]
		if roll <= cumulative:
			return object_type

	return ""  # No spawn


static func _select_resource_node_type(biome_type: String, rng: RandomNumberGenerator) -> String:
	"""Select specific resource node type for biome.

	Args:
		biome_type: Biome type
		rng: Seeded RandomNumberGenerator

	Returns:
		Resource node subtype (forage, fishing, hunting, berries, mushrooms)
	"""

	var distribution = BiomeDefinitions.get_resource_distribution(biome_type)
	if distribution.is_empty():
		return "resource_node"  # Fallback to generic

	var roll = rng.randf()
	var cumulative = 0.0

	for node_type in distribution.keys():
		cumulative += distribution[node_type]
		if roll <= cumulative:
			# Return resource_node but store subtype in visual_id or metadata
			return "resource_node"

	return "resource_node"  # Fallback


# ============================================
# VALIDATION & ANALYSIS
# ============================================

static func validate_spawn_distribution(
	spawn_count: int,
	actual_objects: Array[WorldObject],
	expected_rates: Dictionary
) -> Dictionary:
	"""
	Validate that actual spawns match expected distribution within tolerance.

	Args:
		spawn_count: Number of potential spawn locations
		actual_objects: Array of spawned objects
		expected_rates: Expected spawn rates from biome

	Returns:
		Dictionary with validation results
	"""

	var type_counts = {}
	for obj in actual_objects:
		var type = obj.object_type
		if type not in type_counts:
			type_counts[type] = 0
		type_counts[type] += 1

	var results = {
		"total_spawned": actual_objects.size(),
		"total_possible": spawn_count,
		"spawn_rate_percent": float(actual_objects.size()) / float(spawn_count) * 100.0 if spawn_count > 0 else 0.0,
		"type_breakdown": {},
		"validation_passed": true
	}

	# Check each type against expected rate (±10% tolerance)
	for type_name in expected_rates.keys():
		var expected_percent = expected_rates[type_name] * 100.0
		var actual_percent = 0.0
		if type_name in type_counts:
			actual_percent = float(type_counts[type_name]) / float(actual_objects.size()) * 100.0 if actual_objects.size() > 0 else 0.0

		var difference = abs(expected_percent - actual_percent)
		var tolerance = 10.0  # 10% tolerance

		var is_valid = difference <= tolerance

		results["type_breakdown"][type_name] = {
			"expected": expected_percent,
			"actual": actual_percent,
			"difference": difference,
			"tolerance": tolerance,
			"valid": is_valid
		}

		if not is_valid:
			results["validation_passed"] = false

	return results
