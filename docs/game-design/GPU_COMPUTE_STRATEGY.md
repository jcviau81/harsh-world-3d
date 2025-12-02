# GPU Compute Shader Strategy & Device Compatibility Matrix

**Document Version:** 2.0
**Date:** 2025-12-02 (Updated for Godot 3D Engine + GPU-First Approach)
**Previous Version Date:** 2025-11-17
**Related Story:** 1.2 - GPU Compute Shader + Threading Strategy

**UPDATED CONTEXT:** This strategy has been refined for Godot 4.x 3D Engine architecture. All terrain generation, noise calculations, and procedural generation now leverage GPU compute shaders as the ONLY path. GPU compute support is a REQUIREMENT for running the game. This represents a GPU-exclusive approach for maximum performance and simplified architecture.

## Overview

This document outlines the GPU compute shader implementation strategy and device compatibility matrix for Phase 1b map generation. The implementation uses Godot 4.5's RenderingDevice API exclusively - GPU compute support is required. Systems without GPU compute capabilities are not supported.

## Architecture

### Component Overview

```
NoiseGeneratorFactory
├── GPU Compute Path (REQUIRED)
│   ├── GPUComputeShader (RenderingDevice wrapper)
│   ├── noise_compute.glsl (GLSL compute kernel)
│   └── GPU Buffer Management (elevation, moisture, temperature)
│
└── No CPU Fallback (GPU Required)
    └── Systems without GPU compute support cannot run this game
```

### Workflow

1. **Device Detection and Validation** (Startup)
   - Check if RenderingDevice is available (REQUIRED)
   - Detect GPU capabilities (Shader Tier 3+, compute shader support required)
   - ERROR and exit if GPU compute not supported
   - Log device information for debugging

2. **GPU Path Initialization**
   - Initialize GPU compute pipeline
   - Verify shader compilation
   - Allocate GPU buffers for terrain generation
   - Fail hard on any GPU initialization error (no fallback)

3. **Chunk Generation**
   - ThreadPool spins up N worker threads (based on CPU core count)
   - Each thread executes GPU compute shaders for noise generation
   - ThreadPool distributes 256 chunk jobs (16×16 grid for 8192×8192 world)
   - Per-thread state isolation (no race conditions)

4. **Synchronization**
   - ChunkSystem.mark_generating/mark_generated() tracks chunk state
   - Mutex-protected work queue
   - Condition variable signals workers when work available
   - All operations GPU-driven

## Device Compatibility Matrix

### Windows

| GPU Vendor | GPU Model | Compute Shaders | Status | Notes |
|:---|:---|:---:|:---|:---|
| NVIDIA | GeForce GTX/RTX (Kepler+) | ✅ | **SUPPORTED** | Best performance; most testing done |
| NVIDIA | GeForce GT | ✅ | **SUPPORTED** | Reduced performance |
| AMD | Radeon RX (RDNA/RDNA2) | ✅ | **SUPPORTED** | Good performance |
| AMD | Radeon RX 5700 XT | ✅ | **SUPPORTED** | Older architecture, slower |
| Intel | Arc A750/A770 | ✅ | **SUPPORTED** | Newer Arc GPUs good |
| Intel | Iris Xe (integrated) | ✅ | **SUPPORTED** | Limited performance |
| Intel | UHD 630/730 | ⚠️ | **FALLBACK** | Compute shader support limited |
| **FALLBACK** | Any GPU | ❌ | **CPU** | FastNoiseLite CPU path |

### macOS

| GPU Vendor | GPU Model | Compute Shaders | Status | Notes |
|:---|:---|:---:|:---|:---|
| Apple | Apple Silicon (M1/M2/M3) | ✅ | **SUPPORTED** | Metal compute excellent performance |
| Apple | Apple Silicon GPU | ✅ | **SUPPORTED** | Native Metal integration |
| Intel | Iris Pro / UHD | ⚠️ | **FALLBACK** | Metal compute limited support |
| AMD | Radeon Pro | ✅ | **SUPPORTED** | Older MacBook Pros |
| **FALLBACK** | Any GPU | ❌ | **CPU** | FastNoiseLite CPU path |

### Linux

| GPU Vendor | GPU Model | Compute Shaders | Status | Notes |
|:---|:---|:---:|:---|:---|
| NVIDIA | GeForce GTX/RTX | ✅ | **SUPPORTED** | CUDA compute, good performance |
| AMD | Radeon RX (RDNA) | ✅ | **SUPPORTED** | ROCM compute available |
| Intel | Arc A770 | ✅ | **SUPPORTED** | Arc support on Linux |
| Intel | UHD (integrated) | ⚠️ | **FALLBACK** | Intel compute limited |
| **FALLBACK** | Any GPU | ❌ | **CPU** | FastNoiseLite CPU path |

## Performance Targets

### GPU Path (Story 1.2 Target)
- **8192×8192 map:** <2 seconds (16×16 chunks in parallel)
- **Per-chunk:** ~8ms (GPU dispatch + transfer)
- **Bottleneck:** GPU buffer transfer (elevation + moisture + temperature)

### CPU Path (Fallback)
- **8192×8192 map:** 5-10 seconds (ThreadPool with 8-16 workers)
- **Per-chunk:** 50-150ms depending on thread count
- **Bottleneck:** Perlin noise computation (per-tile, per-octave)

### Hybrid (GPU + CPU Worker Mix)
- Not implemented in Story 1.2, but ThreadPool supports heterogeneous worker pools
- Future optimization: GPU workers for GPU-capable threads, CPU workers for others

## Implementation Details

### GPU Compute Shader

**File:** `src/world/noise_compute.glsl`

- **Thread Group Size:** 16×16 (256 threads per group)
- **Output Textures:** 3× RGBA32F (elevation, moisture, temperature)
- **Algorithm:** FBM Perlin noise with 4 octaves
- **Compilation:** Deferred to Godot 4.5.1+ for full compute shader support

### Noise Generators

**Base Class:** `NoiseGenerator` (src/world/noise_generator.gd)
- Abstract interface: `generate_noise(chunk_x, chunk_y, chunk_size) -> Dictionary`
- Per-chunk state isolation (thread-safe by design)

**GPU Implementation:** `GPUComputeShader` (src/world/gpu_compute_shader.gd)
- Uses RenderingDevice API
- Configurable octaves, frequency, persistence, lacunarity
- Auto-fallback on any initialization failure

**CPU Implementation:** `CPUNoiseGenerator` (src/world/cpu_noise_generator.gd)
- Uses Godot's FastNoiseLite (built-in, no dependencies)
- Identical noise output to GPU (same algorithm)
- Always available as fallback

### Device Detection

**Factory:** `NoiseGeneratorFactory` (src/world/noise_generator_factory.gd)

```gdscript
var gen = NoiseGeneratorFactory.create_noise_generator(prefer_gpu: true)
# Returns GPU if available, otherwise CPU

var info = NoiseGeneratorFactory.get_device_info()
# {
#   "platform": "Windows/macOS/Linux",
#   "device": "GeForce RTX 3080",
#   "gpu_available": true,
#   "compute_shader_support": true,
#   "shader_tier": 3
# }
```

### ThreadPool Integration

**File:** `src/world/thread_pool_generator.gd`

- **Worker Threads:** Auto-detected (2-16 based on CPU cores)
- **Work Queue:** Mutex-protected, condition variable signaled
- **Chunk Sync:** Uses ChunkSystem.mark_generating/mark_generated
- **Per-Thread State:** Each worker gets own NoiseGenerator instance
- **Statistics:** Tracks chunks_generated, elapsed_time, chunks_per_second

## Future Enhancements

### Story 1.3: Streaming
- Viewport-based chunk culling (only generate visible chunks)
- Streaming priority based on player distance
- LRU cache integration with ThreadPool work queue

### Story 1.4: Biome System
- Post-noise biome assignment (using elevation/moisture/temperature)
- Resource spawning per biome
- 5 core biomes: Coastal, Forest, Mountain, Tundra, Grassland

### Story 2.x: GPU Optimization
- Direct RenderingServer integration (skip intermediate buffers)
- GPU-native biome assignment (compute shader extension)
- GPU-native resource spawning (if feasible)

## Testing

### Unit Tests
- `tests/unit/world/test_gpu_compute.gd` - GPU/CPU generator tests
- `tests/unit/world/test_thread_pool.gd` - ThreadPool synchronization tests

### Integration Tests
- Full 8192×8192 generation via ThreadPool + GPU/CPU
- Regression tests: Story 1.1 tests must pass unchanged
- Device compatibility matrix validation

### Performance Tests
- Benchmark GPU vs CPU on target devices
- Measure GPU memory usage
- Profile ThreadPool overhead

## System Requirements

1. **GPU Compute Shader Support:** GPU compute shaders are REQUIRED. Games will not run on systems without this support.

2. **Minimum GPU Requirements:**
   - NVIDIA: GeForce GTX 750+ (Kepler architecture or newer)
   - AMD: Radeon RX series (RDNA or newer)
   - Intel: Arc series or UHD 730+
   - Apple: Apple Silicon (M1+)
   - Intel Arc A380+

3. **GLSL to SPIR-V Compilation:** Compute shader compilation requires Godot 4.5.1+ for full RenderingDevice support.

4. **Cross-Platform Support:** GPU required on all platforms (Windows, macOS, Linux). No CPU-only systems supported.

## Deployment Checklist

- [ ] GPU compute shader enabled and tested on all target platforms
- [ ] Device compatibility matrix validated (Windows, macOS, Linux with GPU support)
- [ ] Performance targets met: GPU generation <2s per 8192×8192 chunk
- [ ] GPU error handling and validation in place (hard fail on missing GPU)
- [ ] Story 1.1 regression tests pass (no biome/resource changes)
- [ ] Device detection and error messaging clear for unsupported systems
- [ ] ThreadPool worker count tuning per CPU cores
- [ ] Minimum GPU requirements documented in system requirements

## References

- Godot RenderingDevice: https://docs.godotengine.org/en/stable/tutorials/rendering/using_3d_characters/index.html
- FastNoiseLite: https://docs.godotengine.org/en/stable/classes/class_fastnoiselite.html
- Compute Shaders: https://www.khronos.org/opengl/wiki/Compute_Shader
- Perlin Noise: https://en.wikipedia.org/wiki/Perlin_noise
- FBM (Fractal Brownian Motion): https://en.wikipedia.org/wiki/Fractional_Brownian_motion
