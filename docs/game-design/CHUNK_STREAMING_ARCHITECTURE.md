# Chunk Streaming Architecture Documentation

**Updated for Godot 3D Engine (December 2, 2025)**

## Overview

The Chunk Streaming System is a viewport-based dynamic level streaming solution for the Harsh New World Godot 4.5 3D game. It maintains 60 FPS gameplay while continuously loading and unloading chunks based on player position, enabling seamless exploration of massive worlds (1000x scaling). The system integrates with GPU-accelerated procedural generation for efficient chunk creation and uses GridMap-style 3D space for sprite placement.

**Core Principle**: Load what's visible, preload what's adjacent, unload what's far away.

---

## System Architecture

### Component Diagram

```
Player Input
    ↓
    └─→ [Player Node] (global_position)
           ↓
    ┌──────────────────────────────────────────────┐
    │   ChunkStreamingManager (Main Orchestrator)   │
    └──────────────────────────────────────────────┘
           ↓           ↓            ↓
    ┌─────────────┐ ┌──────────┐ ┌─────────────┐
    │  Viewport   │ │Streaming │ │Thread Pool  │
    │  Culling    │ │Manager   │ │ Generator   │
    └─────────────┘ └──────────┘ └─────────────┘
           ↓           ↓            ↓
    ┌────────────────────────────────────┐
    │  Priority Queue (Distance-Based)   │
    │  Heap: closer chunks = higher      │
    │  priority                          │
    └────────────────────────────────────┘
           ↓
    ┌────────────────────────────────────┐
    │  Chunk System (LRU Cache)          │
    │  16 chunk capacity (~8MB base)     │
    │  Thread-safe with Mutex            │
    └────────────────────────────────────┘
           ↓
    ┌────────────────────────────────────┐
    │  GPU Compute / CPU Fallback        │
    │  Chunk Generation Pipeline         │
    └────────────────────────────────────┘
           ↓
    ┌────────────────────────────────────┐
    │  Rendering System                  │
    │  Displays loaded chunks            │
    └────────────────────────────────────┘
```

---

## Component Responsibilities

### 1. ViewportCulling (`src/world/viewport_culling.gd`)

**Purpose**: Detect visible chunks and boundary conditions based on player position.

**Key Responsibilities**:
- Track player world position and determine current chunk coordinate
- Calculate which chunks are visible within viewport radius
- Detect chunk boundary crossings (player entering new chunk)
- Determine which chunks to load (visible + preload buffer)
- Determine which chunks to unload (too far away)
- Calculate distance from player to any chunk (Chebyshev distance)

**Configuration**:
```gdscript
view_radius: int = 3              # Chunks in each direction from player
preload_distance: int = 1         # Buffer of chunks beyond viewport
unload_distance: int = 5          # Distance threshold for unloading
```

**Key Methods**:
- `initialize(chunk_system: ChunkSystem)` - Setup viewport culling
- `update_player_position(world_pos: Vector2)` - Update based on player movement
- `get_visible_chunks() -> Array` - Return array of visible chunk coords
- `is_chunk_visible(chunk_x, chunk_y) -> bool` - Quick visibility check
- `should_preload_chunk(chunk_x, chunk_y) -> bool` - Check if in preload buffer
- `should_unload_chunk(chunk_x, chunk_y) -> bool` - Check if too far away
- `get_chunk_distance(chunk_x, chunk_y) -> int` - Chebyshev distance

**Signals**:
- `viewport_changed(visible_chunks: Array)` - Emitted when viewport changes
- `chunk_boundary_crossed(old_x, old_y, new_x, new_y)` - Emitted when player enters new chunk
- `chunks_to_load(chunks: Array)` - Emitted when chunks need loading
- `chunks_to_unload(chunks: Array)` - Emitted when chunks should unload

**Performance Budget**: <1ms per frame for viewport calculation (typically <0.2ms)

---

### 2. PriorityQueue (`src/world/priority_queue.gd`)

**Purpose**: Min-heap priority queue for distance-based chunk prioritization.

**Key Principle**: Closer chunks have higher priority and are loaded first.

**Implementation Details**:
- **Data Structure**: Binary min-heap (Array-based with O(log n) operations)
- **Priority Model**: `priority = -1 × distance` (higher value = higher priority = closer chunk)
- **Lookup**: O(1) via `_item_index` dictionary mapping "x,y" → heap index
- **Stable Ordering**: Equal priority items ordered FIFO (earlier enqueue first)

**Key Methods**:
- `enqueue(item: Dictionary, priority: int)` - Insert chunk with priority
  - O(log n) time complexity
  - Updates index map for O(1) lookup
  - Maintains heap property via bubble-up

- `dequeue() -> Dictionary` - Remove and return highest priority item
  - O(log n) time complexity
  - Moves last item to root, bubbles down
  - Returns empty dict if queue empty

- `peek() -> Dictionary` - View highest priority without removal
  - O(1) time complexity
  - Useful for inspecting next chunk to load

- `update_priority(item, new_priority)` - Dynamic reprioritization
  - Called when player moves and distances change
  - O(log n) time complexity via selective bubble-up/down

- `contains(item) -> bool` - Check if item in queue
  - O(1) via `_item_index` lookup

- `remove(item) -> bool` - Remove specific item from queue
  - O(log n) time complexity
  - Maintains heap property

- `get_all_sorted() -> Array` - Get all items in priority order
  - O(n) time complexity
  - Returns copy, doesn't modify queue
  - Useful for debugging and monitoring

**Internal Operations**:
- `_bubble_up(index)` - Move item toward root (for insertion/update increase)
- `_bubble_down(index)` - Move item toward leaves (for deletion/update decrease)
- `_has_higher_priority(a, b) -> bool` - Comparator for priority ordering
- `_validate_heap_property() -> bool` - Validation for testing/debugging

---

### 3. ChunkStreamingManager (`src/world/chunk_streaming_manager.gd`)

**Purpose**: Main orchestrator coordinating all streaming subsystems.

**Key Responsibilities**:
- Initialize and connect all subsystems (ViewportCulling, ChunkSystem, ThreadPool)
- Coordinate signal flow between components
- Process preload queue (rate-limited per frame)
- Process unload queue (rate-limited per frame)
- Monitor and track performance metrics
- Detect frame budget violations
- Detect chunk load time violations

**Configuration**:
```gdscript
max_chunks_to_preload_per_frame: int = 2     # Rate limit for preloading
max_chunks_to_unload_per_frame: int = 1      # Rate limit for unloading
enable_performance_tracking: bool = true      # Enable performance monitoring
```

**Key Methods**:
- `initialize(viewport_culling, chunk_system, thread_pool, player_node)` - Setup all subsystems
- `get_metrics() -> Dictionary` - Get current performance metrics
- `get_average_frame_time() -> float` - Get rolling average frame time
- `is_frame_budget_maintained() -> bool` - Check if 60 FPS maintained
- `get_chunks_in_transit_count() -> int` - Number of chunks being generated
- `get_preload_queue_size() -> int` - Size of preload queue
- `get_streaming_state() -> Dictionary` - Debug state information
- `print_streaming_state()` - Print debug information

**Signals**:
- `frame_budget_exceeded(frame_time_ms: float)` - Frame exceeded 16.67ms budget
- `chunk_load_budget_exceeded(chunk_x, chunk_y, load_time_ms)` - Chunk load exceeded 10ms
- `performance_metrics_updated(metrics: Dictionary)` - Metrics updated (every ~60 frames)
- `chunks_preloaded(count: int)` - Chunks preloaded this frame
- `chunks_unloaded(count: int)` - Chunks unloaded this frame

**Metrics Tracked**:
```gdscript
{
  "total_chunks_generated": int,        # Total chunks loaded since start
  "total_chunks_unloaded": int,         # Total chunks unloaded
  "average_frame_time_ms": float,       # Rolling average (60 frames)
  "max_frame_time_ms": float,           # Peak frame time this session
  "min_frame_time_ms": float,           # Minimum frame time
  "frames_over_budget": int,            # Count of frames exceeding budget
  "chunks_over_load_budget": int        # Count of chunks exceeding load budget
}
```

**Performance Budgets**:
- **Frame Time**: 16.67ms (1000/60 FPS)
- **Chunk Load**: 10ms per chunk
- **Viewport Calc**: 1ms per frame

---

### 4. ThreadPoolGenerator (`src/world/thread_pool_generator.gd`)

**Purpose**: Parallel chunk generation using distance-based priority queue with GPU compute shaders.

**Key Responsibilities**:
- Manage pool of worker threads (2-16 auto-scaled)
- Dequeue chunks from priority queue in priority order
- Execute generation EXCLUSIVELY via GPU compute shaders (Godot 4.x RenderingDevice API)
- Leverage all terrain generation and noise calculations on GPU (no CPU fallback)
- Load completed chunks into ChunkSystem
- Track generation progress and performance
- GPU support is required - no CPU-only execution

**Configuration**:
```gdscript
min_workers: int = 2              # Minimum threads
max_workers: int = 16             # Maximum threads (scales with load)
chunk_size: int = 512             # Tiles per chunk
target_fps: int = 60              # Target frame rate
```

**Key Methods**:
- `enqueue_chunk(chunk_x, chunk_y, priority)` - Add chunk to work queue
- `update_chunk_priority(chunk_x, chunk_y, new_priority)` - Change priority
- `get_queue_size() -> int` - Current work queue size
- `get_queue_stats() -> Dictionary` - Priority queue statistics
- `shutdown()` - Clean shutdown of all worker threads

**Threading Model**:
- Each worker thread runs independent loop:
  1. Wait on ConditionVariable for work
  2. Dequeue chunk from PriorityQueue (highest priority first)
  3. Generate chunk data (GPU/CPU)
  4. Load into ChunkSystem (thread-safe)
  5. Emit signal or return to caller
- Mutex protects work queue access
- ConditionVariable signals worker wake-up

**Safety Guarantees**:
- Work queue protected by Mutex
- Per-thread state isolation (no shared mutable state)
- ChunkSystem handles thread-safe chunk insertion
- No deadlocks (proper acquire/release pattern)

---

### 5. ChunkSystem (`src/world/chunk_system.gd`)

**Purpose**: LRU cache for loaded chunks with thread-safe access.

**Key Responsibilities**:
- Maintain bounded cache of active chunks (max 16 chunks)
- Load chunks via priority queue requests
- Evict least-recently-used chunks when capacity reached
- Emit signals on chunk load/unload
- Provide O(1) chunk lookup

**Cache Configuration**:
```gdscript
MAX_ACTIVE_CHUNKS: int = 16       # Maximum chunks in memory (~8MB base)
```

**Key Methods**:
- `request_chunk(chunk_x, chunk_y, priority)` - Queue chunk for generation
- `load_chunk(chunk: ChunkData)` - Add chunk to cache
- `unload_chunk(chunk_x, chunk_y)` - Remove from cache
- `get_chunk(chunk_x, chunk_y) -> ChunkData` - O(1) lookup
- `get_cache_stats() -> Dictionary` - Cache statistics

**Signals**:
- `chunk_loaded(chunk: ChunkData)` - Chunk finished loading
- `chunk_unloaded(chunk_x, chunk_y)` - Chunk unloaded from memory

**Memory Management**:
- **Per-Chunk**: ~0.5MB (512×512 tiles, basic data)
- **Base Overhead**: ~1-2MB (cache structures, bookkeeping)
- **Max Capacity**: ~8MB with 16 chunks
- **Streaming Overhead**: <50MB total including in-flight chunks and buffers

**Thread Safety**:
- Mutex protects all cache operations
- Mark-generating/mark-generated pattern prevents race conditions
- Safe concurrent access from multiple worker threads

---

## Signal Flow and Event Coordination

### 1. Viewport Change Event

```
Player moves to new position
        ↓
_process() calls _update_viewport_and_streaming()
        ↓
ViewportCulling.update_player_position(new_pos)
        ↓
[Viewport changed detection]
        ↓
ViewportCulling.viewport_changed signal
        ↓
ChunkStreamingManager._on_viewport_changed()
        ↓
Initialize preload queue
Emit chunks_to_load signal
```

### 2. Chunk Boundary Crossing

```
Player crosses chunk boundary
        ↓
ViewportCulling detects new chunk_x, chunk_y
        ↓
ViewportCulling.chunk_boundary_crossed signal
        ↓
ChunkStreamingManager._on_chunk_boundary_crossed()
        ↓
[Optional: Dynamic reprioritization of in-flight chunks]
```

### 3. Chunk Load Request Flow

```
Visible chunks identified
        ↓
ViewportCulling.chunks_to_load signal
        ↓
ChunkStreamingManager._on_chunks_to_load(chunks)
        ↓
For each chunk:
  - Calculate distance-based priority
  - ThreadPool.enqueue_chunk(x, y, priority)
  - Track in _chunks_in_transit
```

### 4. Chunk Generation and Loading

```
ThreadPool worker dequeues chunk
        ↓
Generate chunk (GPU/CPU)
        ↓
ChunkSystem.load_chunk(chunk_data)
        ↓
ChunkSystem.chunk_loaded signal
        ↓
ChunkStreamingManager._on_chunk_loaded(chunk)
        ↓
Track load time vs. 10ms budget
Remove from _chunks_in_transit
Add to _active_chunks
Increment metrics
Emit chunks_preloaded signal
```

### 5. Chunk Unload Flow

```
_process() calls _process_unload_queue()
        ↓
For each active chunk:
  - Check ViewportCulling.should_unload_chunk()
  - If unload needed: identify chunk
        ↓
ChunkSystem.unload_chunk(x, y)
        ↓
ChunkSystem.chunk_unloaded signal
        ↓
ChunkStreamingManager._on_chunk_unloaded()
        ↓
Remove from _active_chunks
Increment metrics
Emit chunks_unloaded signal
```

---

## Memory Management Strategy

### Cache Architecture

```
LRU Cache (ChunkSystem)
│
├─ Loaded Chunks: 1-16 active
│  └ Evicted: least-recently-used when new chunk added at capacity
│
├─ Generation Queue
│  └ Chunks waiting to generate (ThreadPool work queue)
│
└─ In-Transit Tracking (ChunkStreamingManager)
   └ Timestamp for each chunk being generated (load time profiling)
```

### Memory Lifecycle

1. **Chunk Requested**: Added to ThreadPool work queue (minimal memory)
2. **Chunk Generating**: Generating state tracked (thread-local memory)
3. **Chunk Loaded**: Inserted into LRU cache (0.5MB per chunk)
4. **Chunk Evicted**: LRU eviction when capacity reached (automatic)
5. **Chunk Unloaded**: Removed from cache via unload signal (frees memory)

### Eviction Policy

- **Trigger**: New chunk loaded and cache at capacity (16 chunks)
- **Victim Selection**: Least-recently-used chunk
- **Graceful Unload**: Unload queue processes one per frame (no frame spikes)
- **Result**: Memory bounded to ~8MB cache + streaming overhead

### Streaming Overhead

- **Work Queue**: O(1) per chunk (negligible)
- **In-Transit Tracking**: O(n) where n = concurrent generations (~10-50 chunks)
- **Frame Times Buffer**: 60 frames × 8 bytes = ~480 bytes
- **Index Maps**: PriorityQueue index map (O(n) with loaded chunks)
- **Total Overhead**: <50MB for typical gameplay (includes preload buffers, frame data)

---

## Performance Targets and Budget Allocation

### Frame Time Budget (16.67ms for 60 FPS)

```
Total Frame Budget: 16.67ms
│
├─ Viewport Update & Streaming: ~3ms
│  ├─ Viewport culling: <1ms
│  ├─ Preload queue processing: ~1ms (2 chunks × 0.5ms)
│  └─ Unload queue processing: ~1ms (1 chunk × 1ms)
│
├─ Performance Tracking: <0.5ms
│  ├─ Frame time recording: <0.1ms
│  ├─ Metrics averaging: <0.1ms
│  └─ Signal emission: <0.3ms
│
├─ Game Logic (Player, Physics, etc): ~10ms
│
├─ Rendering & Screen Update: ~2.5ms
│
└─ OS Overhead & Margin: ~0.67ms
```

**Compliance Strategy**:
- Preload/unload rate-limited to 2 and 1 chunks per frame
- Viewport calculations optimized for O(1) visibility checks
- Performance tracking uses circular buffer (no reallocation)
- Streaming metrics batched (emitted every 60 frames)

### Chunk Load Time Budget

- **Target**: <10ms per chunk
- **Monitoring**: Track load time from request to chunk_loaded signal
- **Action**: Emit chunk_load_budget_exceeded signal if exceeded
- **Typical Performance**: 5-8ms for GPU generation, 8-12ms for CPU fallback

### Load Distribution Across Frames

```
Frame 1: Request chunks A, B, C (set priority based on distance)
Frame 2: ThreadPool generates A in parallel
         Preload chunks D, E (adjacent)
Frame 3: ThreadPool completes A, request next from queue
         ThreadPool generating B, C in parallel
Frame 4: Load A into cache (signal emitted)
         Unload chunk X if far away
Frame 5: Continue streaming cycle
```

---

## Threading Model and Safety Guarantees

### Worker Thread Architecture

```
Main Thread (GameEngine)
│
├─ _process() each frame:
│  ├─ Update viewport (ViewportCulling)
│  ├─ Queue chunks (ThreadPool.enqueue_chunk)
│  ├─ Process preload queue
│  └─ Process unload queue
│
└─ Receive signals from subsystems

Worker Threads (ThreadPool, 2-16 count)
│
├─ Loop:
│  ├─ Wait on ConditionVariable (Mutex locked)
│  ├─ Dequeue chunk from PriorityQueue (highest priority)
│  ├─ Generate chunk (GPU/CPU)
│  ├─ Load into ChunkSystem (thread-safe)
│  └─ Emit chunk_loaded signal
│
└─ Isolated state (no sharing except work queue)
```

### Synchronization Primitives

**Mutex (Work Queue Protection)**:
```gdscript
_work_queue_mutex: Mutex
_work_queue: PriorityQueue

# Protected region:
_work_queue_mutex.lock()
_work_queue.enqueue(chunk, priority)  # or dequeue()
_work_queue_mutex.unlock()
```

**ConditionVariable (Worker Wake-up)**:
```gdscript
_condition: ConditionVariable

# Main thread: signal work available
_condition.notify_one()  # Wake one worker
_condition.notify_all()  # Wake all workers

# Worker thread: wait for work
_condition.wait(_work_queue_mutex)  # Releases mutex, waits, reacquires
```

### Safety Guarantees

1. **Atomicity**: All work queue operations protected by single Mutex
   - No race conditions on enqueue/dequeue
   - No corruption of PriorityQueue heap

2. **Memory Safety**: No data races on chunks
   - Each chunk generation is independent
   - ChunkSystem.load_chunk handles thread-safe insertion
   - No chunk is accessed by multiple threads simultaneously

3. **Deadlock Freedom**:
   - Lock ordering: Work Queue Mutex → ChunkSystem Mutex (consistent)
   - No circular waits
   - Timeouts on critical paths (optional, not implemented)

4. **Signal Safety**:
   - Signals emitted from worker threads are thread-safe in Godot 4.5
   - Main thread receives signals in next frame's _process()

5. **Frame Coherence**:
   - All viewport changes applied atomically in _update_viewport_and_streaming()
   - Metrics updates happen at consistent points
   - No mid-frame inconsistencies observed by game logic

### Potential Race Conditions (Analyzed and Safe)

**Scenario 1: Simultaneous enqueue and dequeue**
- Safe: Mutex protects both operations
- Both acquire lock before accessing heap
- No interleaving possible

**Scenario 2: Chunk evicted while generating**
- Safe: Separate track in _chunks_in_transit
- Once loaded (marked in ChunkSystem), it's safe to evict old chunk
- LRU eviction is independent of generation

**Scenario 3: Viewport change during generation**
- Safe: Chunks already queued are generated
- New viewport just triggers new enqueues
- Old in-flight chunks still loaded (may be outside viewport, then unloaded)

---

## Configuration and Tuning

### Viewport Configuration

```gdscript
# viewport_culling.gd
view_radius: int = 3              # Chunks to load in each direction
preload_distance: int = 1         # Extra chunks beyond viewport for buffer
unload_distance: int = 5          # Distance at which chunks unload
```

**Impact**:
- Larger `view_radius` = More chunks loaded (more memory, more CPU)
- Larger `preload_distance` = Smoother movement (more chunks generated ahead)
- Larger `unload_distance` = More safety margin (slower memory reclamation)

### Streaming Rate Limits

```gdscript
# chunk_streaming_manager.gd
max_chunks_to_preload_per_frame: int = 2      # Queue 2 chunks/frame
max_chunks_to_unload_per_frame: int = 1       # Unload 1 chunk/frame
```

**Impact**:
- Lower limits = Smoother performance, slower streaming
- Higher limits = Faster streaming, potential frame spikes

**Recommended**:
- Preload: 2-4 per frame (typical: 2)
- Unload: 1 per frame (can be 1-2)

### Thread Pool Configuration

```gdscript
# thread_pool_generator.gd
min_workers: int = 2              # Always 2 threads
max_workers: int = 16             # Scale up with queue size
```

**Impact**:
- More workers = Faster chunk generation, more CPU usage
- Auto-scaling adjusts based on queue depth

### Performance Monitoring

```gdscript
# chunk_streaming_manager.gd
enable_performance_tracking: bool = true

# Access metrics:
var metrics = streaming_manager.get_metrics()
# Returns: {
#   "total_chunks_generated": 45,
#   "average_frame_time_ms": 14.2,
#   "frames_over_budget": 0,
#   ...
# }
```

---

## Design Patterns Used

### 1. Signal-Driven Architecture
- Components communicate via Godot signals (loose coupling)
- ChunkStreamingManager acts as signal hub (Observer pattern)
- No direct component dependencies

### 2. Priority Queue Pattern
- Work items prioritized by distance (closest first)
- Dynamic reprioritization supported (player movement)
- Efficient O(log n) operations

### 3. Rate Limiting Pattern
- Preload/unload rate-limited per frame
- Prevents frame time spikes from sudden memory operations
- Maintains consistent 60 FPS

### 4. Metrics Collection Pattern
- Frame times collected in circular buffer
- Rolling average computed lazily (on query)
- Avoids reallocation of array

### 5. Thread Pool Pattern
- Fixed pool of workers
- Auto-scaling based on queue depth
- Work items consumed from priority queue

### 6. LRU Cache Pattern
- Bounded memory via max capacity
- Automatic eviction of least-recently-used
- O(1) lookup by chunk coordinate

---

## Integration Points

### With Rendering System
- ChunkSystem loads spatial data
- Rendering reads from loaded chunks
- Synchronization: Chunks guaranteed loaded before _process() returns

### With Physics System
- Chunks contain collision geometry
- Physics queries against active chunks
- Unload queue prevents queries against unloaded chunks

### With Game Logic
- Player position from Player node
- ViewportCulling.update_player_position() called each frame
- Streaming transparent to game logic

### With Debug/Inspector
- `streaming_manager.print_streaming_state()` for debugging
- `streaming_manager.get_streaming_state()` for editor widgets
- Priority queue statistics available via `queue.get_stats()`

---

## Testing Strategy

### Unit Tests (Per-Component)
- **test_viewport_culling.gd**: Visibility detection, boundary crossing, distance calculation
- **test_priority_queue.gd**: Priority ordering, heap integrity, dynamic reprioritization
- **test_chunk_streaming_manager.gd**: Signal coordination, metrics tracking, preload/unload logic
- **test_thread_pool_generator.gd**: Work queue, priority integration, thread safety

### Integration Tests (Full Pipeline)
- **test_chunk_streaming_integration.gd**: Player movement → requests → generation → loading
  - Continuous movement across chunks
  - Rapid direction changes
  - Circular movement patterns
  - High-frequency movement (stress test)
  - Concurrent requests (50+ chunks)
  - Cache pressure (near capacity)

### LRU Cache Regression Tests
- **test_lru_cache_validation.gd**: Capacity bounds, race conditions, determinism
  - Ensures Story 1.1 (ChunkSystem) still functions correctly
  - Validates no memory leaks under streaming

### Performance Benchmarks
- Frame time measurements (should stay <16.67ms)
- Chunk load time measurements (should stay <10ms)
- Memory usage profiling (should stay <50MB total)
- Scaling tests (performance with 0-16 active chunks)

---

## Troubleshooting Guide

### Problem: Frame Rate Drops Below 60 FPS

**Check**:
1. Metrics: `streaming_manager.get_metrics()` - is `average_frame_time_ms` > 16.67?
2. Streaming: `streaming_manager.get_streaming_state()` - how many in-flight chunks?
3. ThreadPool: Reduce `max_chunks_to_preload_per_frame` from 2 to 1
4. Viewport: Reduce `view_radius` from 3 to 2

### Problem: Chunks Not Loading

**Check**:
1. Signals connected? `_on_chunks_to_load` being called?
2. ThreadPool running? `thread_pool.get_queue_size()` > 0?
3. ChunkSystem memory? `chunk_system.get_cache_stats()["active_chunks"]` < 16?
4. Generation working? Check ThreadPool worker thread logs

### Problem: Memory Growing Unbounded

**Check**:
1. Cache bounds: `chunk_system.MAX_ACTIVE_CHUNKS` = 16?
2. Unload working? `_process_unload_queue()` being called each frame?
3. ViewportCulling: `should_unload_chunk()` returning true for far chunks?
4. Profiler: Memory growth pattern - is it linear or stepped?

### Problem: Chunks Stutter/Pop-in

**Check**:
1. Preload distance: Set `preload_distance` from 1 to 2 chunks
2. Frame budget: Increase `max_chunks_to_preload_per_frame` to 3-4
3. Thread count: Increase ThreadPool `max_workers` from 16 to 20
4. GPU generation: Verify compute shader completion before load

---

## Future Optimization Opportunities

### 1. Spatial Acceleration
- Quadtree for viewport queries instead of linear iteration
- Reduces visibility check from O(view_radius²) to O(log n)

### 2. Incremental Loading
- Load chunk in multiple priority levels (critical → medium → low detail)
- Display low-detail while high-detail generates

### 3. Predictive Loading
- Analyze player movement trajectory
- Preload in direction of movement before chunks needed

### 4. Chunk Pooling
- Reuse chunk data structures instead of allocating new
- Reduces garbage collection pressure

### 5. Dynamic Quality Scaling
- Reduce view radius when frame time trending up
- Increase when frame time trending down
- Adaptive quality for consistent experience

### 6. LOD (Level of Detail)
- Generate multiple detail levels per chunk
- Stream lower detail while waiting for higher

---

## Summary

The Chunk Streaming Architecture provides a robust, performant solution for viewport-based level streaming in Harsh New World. By combining efficient data structures (priority queue, LRU cache), thread-safe parallel generation (ThreadPool), and performance monitoring, the system maintains 60 FPS gameplay while supporting massive world exploration.

Key characteristics:
- **Scalability**: Handles 1000x world without loading all chunks
- **Responsiveness**: <1ms viewport calculation, <10ms chunk generation
- **Memory Efficiency**: Bounded to ~8MB active chunks + <50MB streaming overhead
- **Robustness**: Thread-safe, race-condition-free, comprehensive testing
- **Debuggability**: Extensive metrics, state inspection, signal logging

This architecture forms the foundation for Phase 1b (GPU-First Map Generation) and enables sustainable world expansion in future phases.
