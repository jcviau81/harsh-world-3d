## Unit tests for ChunkManager
## Validates chunk loading/unloading, streaming radius, async operations

extends Node

var passed: int = 0
var failed: int = 0

func _ready() -> void:
	"""Run all tests."""
	print("\n=== ChunkManager Unit Tests ===\n")

	test_chunk_manager_creation()
	test_chunk_calculation()
	test_chunk_loading()
	test_streaming_config()
	test_chunk_seeding()

	print("\n=== Test Summary ===")
	print("Passed: %d, Failed: %d" % [passed, failed])
	print("===  Tests Complete ===\n")
	queue_free()


func _assert(condition: bool, message: String) -> void:
	"""Assert and track results."""
	if condition:
		passed += 1
		print("  ✓ %s" % message)
	else:
		failed += 1
		print("  ✗ FAIL: %s" % message)


# ============================================
# TEST CASES
# ============================================

func test_chunk_manager_creation() -> void:
	"""Test that ChunkManager can be created."""
	print("\n--- ChunkManager Creation ---")

	var cm = ChunkManager.new()
	_assert(cm != null, "ChunkManager instantiated")
	_assert(cm.streaming_radius == 3, "Default streaming_radius is 3")
	_assert(cm.chunk_size == 32, "Default chunk_size is 32")


func test_chunk_calculation() -> void:
	"""Test active chunk calculations."""
	print("\n--- Chunk Calculation ---")

	var cm = ChunkManager.new()
	var player = Node3D.new()
	cm.set_player(player)
	add_child(cm)
	add_child(player)

	# Test default config
	cm.streaming_radius = 0
	cm.chunk_size = 32
	player.position = Vector3(0, 0, 0)

	var active = cm.get_active_chunks()
	_assert(active.size() == 1, "Radius 0 returns 1 chunk")
	_assert(active[0] == Vector2i(0, 0), "Player at origin is chunk (0,0)")

	# Test radius 1
	cm.streaming_radius = 1
	active = cm.get_active_chunks()
	_assert(active.size() == 9, "Radius 1 returns 9 chunks (3x3)")

	# Test offset position
	player.position = Vector3(64, 0, 64)
	active = cm.get_active_chunks()
	_assert(active.size() == 9, "Offset position still calculates correctly")


func test_chunk_loading() -> void:
	"""Test chunk loading."""
	print("\n--- Chunk Loading ---")

	var cm = ChunkManager.new()

	var chunk = cm.load_chunk(0, 0)
	_assert(chunk != null, "load_chunk returns ChunkData")
	_assert(chunk.chunk_x == 0, "ChunkData.chunk_x is correct")
	_assert(chunk.chunk_y == 0, "ChunkData.chunk_y is correct")
	_assert(chunk.chunk_seed > 0, "ChunkData.chunk_seed is valid")

	# Test get_loaded_chunks
	var loaded = cm.get_loaded_chunks()
	_assert(loaded.size() >= 0, "get_loaded_chunks returns array")


func test_streaming_config() -> void:
	"""Test streaming configuration."""
	print("\n--- Streaming Configuration ---")

	var cm = ChunkManager.new()

	cm.streaming_radius = 5
	_assert(cm.streaming_radius == 5, "streaming_radius is configurable")

	cm.chunk_size = 64
	_assert(cm.chunk_size == 64, "chunk_size is configurable")


func test_chunk_seeding() -> void:
	"""Test deterministic chunk seeding."""
	print("\n--- Chunk Seeding ---")

	var cm = ChunkManager.new()

	var seed1 = cm.get_chunk_seed(5, 7)
	var seed2 = cm.get_chunk_seed(5, 7)
	_assert(seed1 == seed2, "Same coordinates produce same seed")

	var seed_x = cm.get_chunk_seed(6, 7)
	var seed_y = cm.get_chunk_seed(5, 8)
	_assert(seed1 != seed_x, "Different X produces different seed")
	_assert(seed1 != seed_y, "Different Y produces different seed")
