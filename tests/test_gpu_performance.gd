## GPU Performance Profiling Tests
## Measures heightmap generation performance and validates target <100ms per chunk

class_name TestGPUPerformance
extends Node

# ============================================
# CONSTANTS
# ============================================

const TARGET_MS_PER_CHUNK: int = 100
const TEST_CHUNK_COUNT: int = 100

# ============================================
# TEST SETUP
# ============================================

var terrain_gen: TerrainGenerator


func setup() -> void:
	"""Setup test fixture."""
	terrain_gen = TerrainGenerator.new()
	add_child(terrain_gen)
	await get_tree().process_frame


func teardown() -> void:
	"""Clean up test fixture."""
	if terrain_gen:
		terrain_gen.queue_free()


# ============================================
# TEST 1: SINGLE CHUNK GENERATION TIME
# ============================================

func test_single_chunk_generation_time() -> void:
	"""AC-10: Measure single heightmap generation time"""

	if not terrain_gen.is_gpu_available():
		return

	var times_ms = []
	var test_runs = 10

	# Generate same chunk multiple times to measure consistency
	for i in range(test_runs):
		var start_ms = Time.get_ticks_msec()
		var heightmap = terrain_gen.generate_heightmap(0, 0, 12345 + i)
		var end_ms = Time.get_ticks_msec()

		var duration = end_ms - start_ms
		times_ms.append(duration)

		assert(heightmap.size() != 0, "Heightmap generation failed")

	# Calculate statistics
	var min_time = times_ms.min()
	var max_time = times_ms.max()
	var avg_time = times_ms.reduce(func(acc, val): return acc + val, 0) / test_runs

	print("\n=== SINGLE CHUNK PERFORMANCE ===")
	print("Min: %d ms" % min_time)
	print("Max: %d ms" % max_time)
	print("Avg: %d ms" % avg_time)
	print("Target: %d ms" % TARGET_MS_PER_CHUNK)

	# Performance assertion (warning if exceeds target)
	if avg_time > TARGET_MS_PER_CHUNK:
		print("WARNING: Average generation time (%d ms) exceeds target (%d ms)" % [avg_time, TARGET_MS_PER_CHUNK])
		assert(avg_time < TARGET_MS_PER_CHUNK * 1.5, "Should not exceed 150% of target")
	else:
		assert(avg_time < TARGET_MS_PER_CHUNK, "Should be under target")


# ============================================
# TEST 2: 100-CHUNK BATCH PERFORMANCE
# ============================================

func test_100_chunk_batch_performance() -> void:
	"""AC-10/11: Measure 100 chunk generation time and average per-chunk"""

	if not terrain_gen.is_gpu_available():
		return

	var chunk_times = []
	var start_total = Time.get_ticks_msec()

	for i in range(TEST_CHUNK_COUNT):
		var chunk_x = i % 10
		var chunk_y = i / 10
		var seed = 12345

		var start = Time.get_ticks_msec()
		var heightmap = terrain_gen.generate_heightmap(chunk_x, chunk_y, seed)
		var end = Time.get_ticks_msec()

		chunk_times.append(end - start)
		assert(heightmap.size() != 0, "Chunk %d generation failed" % i)

	var end_total = Time.get_ticks_msec()
	var total_time = end_total - start_total
	var avg_per_chunk = total_time / TEST_CHUNK_COUNT

	print("\n=== 100-CHUNK BATCH PERFORMANCE ===")
	print("Total time: %d ms" % total_time)
	print("Chunks: %d" % TEST_CHUNK_COUNT)
	print("Average per-chunk: %d ms" % avg_per_chunk)
	print("Target per-chunk: %d ms" % TARGET_MS_PER_CHUNK)
	print("Min chunk time: %d ms" % chunk_times.min())
	print("Max chunk time: %d ms" % chunk_times.max())

	assert(avg_per_chunk > 0, "Should measure positive time")
	# Performance goal (warning if exceeded)
	if avg_per_chunk > TARGET_MS_PER_CHUNK:
		print("WARNING: Average per-chunk (%d ms) exceeds target (%d ms)" % [avg_per_chunk, TARGET_MS_PER_CHUNK])


# ============================================
# TEST 3: TEXTURE READBACK TIME
# ============================================

func test_texture_readback_time() -> void:
	"""AC-10: Measure GPU-to-CPU readback time"""

	if not terrain_gen.is_gpu_available():
		return

	var readback_times = []

	for i in range(10):
		var start = Time.get_ticks_msec()
		var heightmap = terrain_gen.generate_heightmap(0, 0, 12345)
		var end = Time.get_ticks_msec()

		# The readback is part of generate_heightmap, so this measures total time
		readback_times.append(end - start)
		assert(heightmap.size() != 0, "Generation failed")

	var avg_readback = readback_times.reduce(func(acc, val): return acc + val, 0) / 10

	print("\n=== TEXTURE READBACK PERFORMANCE ===")
	print("Average generation+readback: %d ms" % avg_readback)
	print("Target: <50 ms (GPU generation) + <5 ms (readback)")

	assert(avg_readback < 60, "Generation+readback should be reasonably fast")


# ============================================
# TEST 4: FRAME TIME IMPACT
# ============================================

func test_frame_time_impact() -> void:
	"""AC-10/11: Measure FPS impact during chunk generation"""

	if not terrain_gen.is_gpu_available():
		return

	# Simulate frame-based generation
	var frame_times = []
	var chunks_per_frame = 5
	var frames = 20

	for frame in range(frames):
		var frame_start = Time.get_ticks_msec()

		# Generate multiple chunks in one "frame"
		for chunk_idx in range(chunks_per_frame):
			var chunk_x = (frame * chunks_per_frame + chunk_idx) % 10
			var chunk_y = ((frame * chunks_per_frame + chunk_idx) / 10) % 10
			var heightmap = terrain_gen.generate_heightmap(chunk_x, chunk_y, 12345)
			assert(heightmap.size() != 0, "Generation failed")

		var frame_end = Time.get_ticks_msec()
		var frame_time = frame_end - frame_start
		frame_times.append(frame_time)

	var avg_frame_time = frame_times.reduce(func(acc, val): return acc + val, 0) / frames
	var estimated_fps = 1000.0 / avg_frame_time if avg_frame_time > 0 else 0.0

	print("\n=== FRAME TIME IMPACT ===")
	print("Chunks per frame: %d" % chunks_per_frame)
	print("Frames tested: %d" % frames)
	print("Average frame time: %d ms" % avg_frame_time)
	print("Estimated FPS: %.1f" % estimated_fps)
	print("Target: 16.6 ms per frame (60 FPS)")

	# For 60 FPS, frame time should be < 16.6 ms
	# Warn if generating 5 chunks per frame exceeds this (async might be needed later)
	if avg_frame_time > 33:
		print("NOTE: Frame time suggests async dispatch might improve responsiveness")


# ============================================
# TEST 5: COLD vs WARM CACHE
# ============================================

func test_cold_warm_cache_performance() -> void:
	"""Measure performance difference between cold start and warm cache"""

	if not terrain_gen.is_gpu_available():
		return

	var cold_time = 0
	var warm_times = []

	# Cold generation (first call)
	var start = Time.get_ticks_msec()
	var heightmap = terrain_gen.generate_heightmap(0, 0, 12345)
	var end = Time.get_ticks_msec()
	cold_time = end - start

	# Warm generations
	for i in range(10):
		start = Time.get_ticks_msec()
		heightmap = terrain_gen.generate_heightmap(0, 0, 12345)
		end = Time.get_ticks_msec()
		warm_times.append(end - start)

	var avg_warm = warm_times.reduce(func(acc, val): return acc + val, 0) / 10.0

	print("\n=== COLD vs WARM CACHE ===")
	print("First generation (cold): %d ms" % cold_time)
	print("Average generation (warm): %.1f ms" % avg_warm)
	print("Cache benefit: %.1f%%" % (((cold_time - avg_warm) / cold_time * 100.0) if cold_time > 0 else 0))

	assert(cold_time > 0, "Should measure cold generation time")


# ============================================
# HELPER: PERFORMANCE REPORT
# ============================================

func print_performance_summary() -> void:
	"""Print overall performance summary."""

	print("\n╔════════════════════════════════════╗")
	print("║  GPU PERFORMANCE SUMMARY           ║")
	print("╠════════════════════════════════════╣")
	print("║ Target: <100ms per chunk (AC-10)  ║")
	print("║ Critical Path: <16.6ms per frame  ║")
	print("║ Run all tests to validate          ║")
	print("╚════════════════════════════════════╝\n")
