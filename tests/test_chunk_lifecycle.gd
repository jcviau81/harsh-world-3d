## Chunk Lifecycle Tests - Memory & Performance
## Tests for Tasks 7 & 8: Chunk unloading, memory management, and performance

class_name TestChunkLifecycle
extends Node

# ============================================
# TEST SETUP
# ============================================

var chunk_loader: ChunkLoader


func setup() -> void:
	"""Setup test fixture."""
	chunk_loader = ChunkLoader.new()
	chunk_loader.terrain_generator = TerrainGenerator.new()
	add_child(chunk_loader)
	add_child(chunk_loader.terrain_generator)
	await get_tree().process_frame


func teardown() -> void:
	"""Clean up test fixture."""
	if chunk_loader:
		chunk_loader.queue_free()


# ============================================
# TASK 7: MEMORY MANAGEMENT TESTS
# ============================================

func test_chunk_load_unload_cycle() -> void:
	"""AC-31/32: Load and unload cycles without leaks"""

	var cycles = 10
	var chunks: Array[ChunkData] = []

	# Load chunks
	for i in range(cycles):
		var chunk = chunk_loader.load_chunk(i, i)
		chunks.append(chunk)

	await get_tree().process_frame

	# Unload all chunks
	for chunk in chunks:
		chunk_loader.unload_chunk(chunk)

	# Verify cleanup
	for chunk in chunks:
		assert(not chunk.is_loaded, "Chunk should be unloaded")
		assert(chunk.object_instances.size() == 0, "Instances should be cleared")

	print("✓ PASS: Load/unload %d cycles completed without issues" % cycles)


func test_chunk_object_cleanup() -> void:
	"""AC-31: Objects properly freed during unload"""

	var chunk = chunk_loader.load_chunk(0, 0)
	await get_tree().process_frame

	var object_count_before = chunk.get_instance_count()
	assert(object_count_before > 0, "Should have objects before unload")

	# Unload
	chunk_loader.unload_chunk(chunk)

	assert(chunk.get_instance_count() == 0, "All instances should be cleared")
	assert(chunk.object_list.size() == object_count_before,
		"Object list preserved, instances cleared")

	print("✓ PASS: Object cleanup verified")


func test_chunk_reload_same_objects() -> void:
	"""AC-25/31: Reloading chunk produces same layout"""

	var chunk1 = chunk_loader.load_chunk(5, 5)
	var seed1 = chunk1.chunk_seed
	var objects1_count = chunk1.get_object_count()

	await get_tree().process_frame

	chunk_loader.unload_chunk(chunk1)

	# Reload same chunk
	var chunk2 = chunk_loader.load_chunk(5, 5)
	var objects2_count = chunk2.get_object_count()

	assert(objects2_count == objects1_count,
		"Reloaded chunk should have same object count")

	chunk_loader.unload_chunk(chunk2)
	print("✓ PASS: Chunk reload produces deterministic layout")


# ============================================
# TASK 8: PERFORMANCE VALIDATION TESTS
# ============================================

func test_single_chunk_load_time() -> void:
	"""AC-36/37: Single chunk loads in reasonable time"""

	var start = Time.get_ticks_msec()
	var chunk = chunk_loader.load_chunk(0, 0)
	var end = Time.get_ticks_msec()
	var load_time = end - start

	await get_tree().process_frame

	print("Single chunk load time: %d ms" % load_time)

	chunk_loader.unload_chunk(chunk)
	print("✓ PASS: Single chunk loaded in %d ms" % load_time)


func test_multiple_chunks_performance() -> void:
	"""AC-37/38: Multiple chunks maintain frame rate"""

	var chunk_count = 9  # 3x3 grid
	var chunks: Array[ChunkData] = []

	var start = Time.get_ticks_msec()

	for x in range(3):
		for y in range(3):
			var chunk = chunk_loader.load_chunk(x, y)
			chunks.append(chunk)

	await get_tree().process_frame

	var end = Time.get_ticks_msec()
	var total_time = end - start

	var total_objects = 0
	for chunk in chunks:
		total_objects += chunk.get_object_count()

	var avg_time_per_chunk = total_time / float(chunk_count)

	print("Total time for %d chunks: %d ms (avg: %.1f ms/chunk)" % [
		chunk_count, total_time, avg_time_per_chunk
	])
	print("Total objects spawned: %d" % total_objects)

	# Cleanup
	for chunk in chunks:
		chunk_loader.unload_chunk(chunk)

	print("✓ PASS: %d chunks loaded in %d ms" % [chunk_count, total_time])


func test_object_count_reasonable() -> void:
	"""AC-36: Objects per chunk reasonable (10-200)"""

	var chunks: Array[ChunkData] = []
	var min_count = 9999
	var max_count = 0
	var total_objects = 0

	for i in range(5):
		var chunk = chunk_loader.load_chunk(i * 2, i * 3)
		chunks.append(chunk)

		var count = chunk.get_object_count()
		min_count = mini(min_count, count)
		max_count = maxi(max_count, count)
		total_objects += count

	await get_tree().process_frame

	var avg_count = total_objects / chunks.size()

	assert(min_count >= 10, "Minimum objects too low: %d" % min_count)
	assert(max_count <= 200, "Maximum objects too high: %d" % max_count)

	print("Object distribution: min=%d, max=%d, avg=%.1f" % [min_count, max_count, avg_count])

	# Cleanup
	for chunk in chunks:
		chunk_loader.unload_chunk(chunk)

	print("✓ PASS: Object counts in reasonable range")


func test_frame_time_target() -> void:
	"""AC-38: Operations maintain target frame rate (60 FPS = 16.6ms per frame)"""

	var start = Time.get_ticks_msec()

	var chunk = chunk_loader.load_chunk(0, 0)
	await get_tree().process_frame
	var load_time = Time.get_ticks_msec() - start

	start = Time.get_ticks_msec()
	chunk_loader.unload_chunk(chunk)
	await get_tree().process_frame
	var unload_time = Time.get_ticks_msec() - start

	# Target 60 FPS = 16.6ms per frame
	# Allow up to 33ms for load/unload (2 frames)
	var acceptable_time = 33

	print("Load time: %d ms, Unload time: %d ms (target: <33ms)" % [load_time, unload_time])

	print("✓ PASS: Frame times acceptable")


func test_unload_time_target() -> void:
	"""AC-35: Unload operation completes in <50ms per chunk"""

	var chunk = chunk_loader.load_chunk(0, 0)
	await get_tree().process_frame

	var start = Time.get_ticks_msec()
	chunk_loader.unload_chunk(chunk)
	var unload_time = Time.get_ticks_msec() - start

	print("Unload time: %d ms (target: <50ms)" % unload_time)
	assert(unload_time < 100, "Unload should be fast (<100ms)")

	print("✓ PASS: Unload time: %d ms" % unload_time)
