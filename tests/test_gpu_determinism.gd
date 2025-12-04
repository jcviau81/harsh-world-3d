## GPU Determinism Validation Tests
## Validates that GPU heightmap generation is deterministic and seamless

class_name TestGPUDeterminism
extends Node

# ============================================
# TEST SETUP
# ============================================

var terrain_gen: TerrainGenerator
var test_seed: int = 12345


func setup() -> void:
	"""Setup test fixture."""
	# Create a temporary TerrainGenerator for testing
	terrain_gen = TerrainGenerator.new()
	add_child(terrain_gen)
	await get_tree().process_frame


func teardown() -> void:
	"""Clean up test fixture."""
	if terrain_gen:
		terrain_gen.queue_free()


# ============================================
# TEST 1: SINGLE CHUNK DETERMINISM (AC-6)
# ============================================

func test_same_seed_produces_identical_heightmap() -> void:
	"""AC-6: First test chunk generates from seed (seed=12345 produces same heightmap every run)"""

	if not terrain_gen.is_gpu_available():
		return

	# Generate same chunk 3 times with same seed
	var heightmap1 = terrain_gen.generate_heightmap(0, 0, test_seed)
	var heightmap2 = terrain_gen.generate_heightmap(0, 0, test_seed)
	var heightmap3 = terrain_gen.generate_heightmap(0, 0, test_seed)

	# Validate all three are identical
	assert(heightmap1.size() == 1024, "Heightmap should be 1024 pixels (32x32)")
	assert(heightmap2.size() == 1024, "Heightmap should be 1024 pixels (32x32)")
	assert(heightmap3.size() == 1024, "Heightmap should be 1024 pixels (32x32)")

	# Compare byte-for-byte
	for i in range(heightmap1.size()):
		assert(heightmap1[i] == heightmap2[i], "Pixel %d mismatch between run 1 and 2" % i)
		assert(heightmap1[i] == heightmap3[i], "Pixel %d mismatch between run 1 and 3" % i)

	print("✓ TEST 1 PASSED: Same seed produces identical heightmap")


# ============================================
# TEST 2: 100-CHUNK DETERMINISM (AC-7)
# ============================================

func test_100_chunks_same_seed_identical() -> void:
	"""AC-7: 100 chunks with same seed produce identical results"""

	if not terrain_gen.is_gpu_available():
		return

	# Generate 100 random chunks
	var chunk_results = {}
	var chunk_count = 0

	for x in range(10):
		for y in range(10):
			var heightmap = terrain_gen.generate_heightmap(x, y, test_seed)
			assert(heightmap.size() == 1024, "Chunk (%d, %d) should produce 1024-pixel heightmap" % [x, y])
			chunk_results["%d_%d" % [x, y]] = heightmap
			chunk_count += 1

	# Regenerate same chunks and verify identical
	for x in range(10):
		for y in range(10):
			var key = "%d_%d" % [x, y]
			var heightmap2 = terrain_gen.generate_heightmap(x, y, test_seed)

			for i in range(1024):
				assert(chunk_results[key][i] == heightmap2[i], "Chunk (%d, %d) pixel %d differs on re-generation" % [x, y, i])

	print("✓ TEST 2 PASSED: 100 chunks generate consistently with same seed")


# ============================================
# TEST 3: HORIZONTAL SEAMING (AC-8)
# ============================================

func test_horizontal_chunk_seaming() -> void:
	"""AC-8: Adjacent chunks share identical pixels at boundaries (horizontal)"""

	if not terrain_gen.is_gpu_available():
		return

	# Generate adjacent chunks horizontally
	var chunk_00 = terrain_gen.generate_heightmap(0, 0, test_seed)
	var chunk_10 = terrain_gen.generate_heightmap(1, 0, test_seed)

	# Extract boundaries
	var right_edge_00 = PackedFloat32Array()
	var left_edge_10 = PackedFloat32Array()

	for y in range(32):
		# Right edge of chunk (0,0) is at x=31
		right_edge_00.append(chunk_00[y * 32 + 31])
		# Left edge of chunk (1,0) is at x=0
		left_edge_10.append(chunk_10[y * 32 + 0])

	# Compare boundaries
	for y in range(32):
		assert(right_edge_00[y] == left_edge_10[y], "Horizontal seam at y=%d: (0,0) right != (1,0) left" % y)

	print("✓ TEST 3a PASSED: Horizontal seaming verified")


func test_vertical_chunk_seaming() -> void:
	"""AC-8: Adjacent chunks share identical pixels at boundaries (vertical)"""

	if not terrain_gen.is_gpu_available():
		return

	# Generate adjacent chunks vertically
	var chunk_00 = terrain_gen.generate_heightmap(0, 0, test_seed)
	var chunk_01 = terrain_gen.generate_heightmap(0, 1, test_seed)

	# Extract boundaries
	var bottom_edge_00 = PackedFloat32Array()
	var top_edge_01 = PackedFloat32Array()

	for x in range(32):
		# Bottom edge of chunk (0,0) is at y=31
		bottom_edge_00.append(chunk_00[31 * 32 + x])
		# Top edge of chunk (0,1) is at y=0
		top_edge_01.append(chunk_01[0 * 32 + x])

	# Compare boundaries
	for x in range(32):
		assert(bottom_edge_00[x] == top_edge_01[x], "Vertical seam at x=%d: (0,0) bottom != (0,1) top" % x)

	print("✓ TEST 3b PASSED: Vertical seaming verified")


# ============================================
# TEST 4: ISLAND + OCEAN CONSISTENCY (AC-9)
# ============================================

func test_ocean_consistency() -> void:
	"""AC-9: Ocean border chunks generate consistently with land chunks"""

	if not terrain_gen.is_gpu_available():
		return

	# Generate ocean chunks at consistent positions
	var ocean_chunks = {}

	# Create a 3x3 grid of "ocean" around island
	for x in range(-1, 2):
		for y in range(-1, 2):
			if x == 0 and y == 0:
				continue  # Skip center (island)

			var heightmap = terrain_gen.generate_heightmap(x, y, test_seed)
			ocean_chunks["%d_%d" % [x, y]] = heightmap

	# Verify ocean chunks have consistent height (they should all sample similar ocean-like heights)
	# Ocean height should be lower than island, but consistent across ocean chunks
	var ocean_height_avg = []

	for key in ocean_chunks.keys():
		var chunk = ocean_chunks[key]
		var avg_height = 0.0
		for pixel in chunk:
			avg_height += pixel

		avg_height /= 1024.0
		ocean_height_avg.append(avg_height)

	# All ocean chunks should have similar average height (within 10% variance)
	var first_avg = ocean_height_avg[0]
	for i in range(1, ocean_height_avg.size()):
		var diff = abs(ocean_height_avg[i] - first_avg)
		assert(diff < 0.1, "Ocean chunk %d has inconsistent average height (%.2f vs %.2f)" % [i, ocean_height_avg[i], first_avg])

	print("✓ TEST 4 PASSED: Ocean chunks generate consistently")


# ============================================
# TEST 5: 100-CHUNK RUN WITHOUT FAILURES (AC-7)
# ============================================

func test_100_chunk_run_no_failures() -> void:
	"""AC-7: Generate 100 random chunks, verify no shader failures"""

	if not terrain_gen.is_gpu_available():
		return

	var chunk_count = 0
	var errors = 0

	for i in range(100):
		var chunk_x = randi() % 100
		var chunk_y = randi() % 100
		var seed = randi()

		var heightmap = terrain_gen.generate_heightmap(chunk_x, chunk_y, seed)

		if heightmap.size() != 1024:
			errors += 1
			print("ERROR: Chunk (%d, %d) generated wrong size" % [chunk_x, chunk_y])

		chunk_count += 1

	assert(errors == 0, "100-chunk run should complete without errors")
	print("✓ TEST 5 PASSED: 100 chunks generated without failures")


# ============================================
# TEST 6: HEIGHTMAP VALIDITY (AC-14)
# ============================================

func test_heightmap_validity() -> void:
	"""AC-14: GPU heightmap outputs correctly to texture readable by CPU"""

	if not terrain_gen.is_gpu_available():
		return

	var heightmap = terrain_gen.generate_heightmap(0, 0, test_seed)

	# Validate size
	assert(heightmap.size() == 1024, "Heightmap must be 1024 pixels")

	# Validate range
	for i in range(heightmap.size()):
		var pixel = heightmap[i]
		assert(pixel >= 0.0, "Pixel %d below 0.0: %.6f" % [i, pixel])
		assert(pixel <= 1.0, "Pixel %d above 1.0: %.6f" % [i, pixel])

		# Check for NaN or Inf
		var is_valid = not (is_nan(pixel) or is_inf(pixel))
		assert(is_valid, "Pixel %d is NaN or Inf" % i)

	print("✓ TEST 6 PASSED: Heightmap validity verified")


# ============================================
# TEST 7: SEED VARIATION (AC-4)
# ============================================

func test_different_seeds_produce_different_output() -> void:
	"""AC-4: Different seeds produce different heightmaps"""

	if not terrain_gen.is_gpu_available():
		return

	var heightmap1 = terrain_gen.generate_heightmap(0, 0, 12345)
	var heightmap2 = terrain_gen.generate_heightmap(0, 0, 54321)

	# Count differences
	var differences = 0
	for i in range(1024):
		if abs(heightmap1[i] - heightmap2[i]) > 0.001:
			differences += 1

	# Expect majority of pixels to be different
	assert(differences > 500, "Different seeds should produce different heightmaps")

	print("✓ TEST 7 PASSED: Different seeds produce variation")
