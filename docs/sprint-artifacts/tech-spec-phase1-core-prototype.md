# Tech-Spec: Phase 1 - Core Prototype (Foundation)

**Created:** 2025-12-02
**Status:** Ready for Development
**Phase:** 1 of 4
**Project:** Harsh World - 2D Survival RPG in Godot 4.x 3D Engine

---

## Overview

### Problem Statement

Harsh World requires a foundational prototype that demonstrates core technical capabilities:
- GPU-accelerated procedural terrain generation using compute shaders
- Deterministic world seeding for infinite, reproducible worlds
- 2D sprite rendering in 3D space with proper camera/grid system
- Player movement and basic world interaction

The prototype must prove GPU compute viability and establish rendering/chunking patterns before gameplay systems development.

### Solution

Build Phase 1 as a minimal, technically-focused prototype with:
1. **Godot 4.x 3D project** with proper folder structure
2. **GPU compute pipeline** for terrain generation (GLSL compute shaders)
3. **GridMap-based rendering system** for 2D sprites in 3D space (32×32 cell grid)
4. **Deterministic world generation** with seed-based chunking (Minecraft-style)
5. **Player character** with basic grid-based movement on generated terrain

**Deliverable:** A playable prototype showing a procedurally generated world with player movement on a grid.

### Scope (In/Out)

**IN SCOPE:**
- Godot 4.x project setup with recommended folder structure
- GPU compute shader pipeline (heightmap generation)
- GridMap 3D setup with orthographic camera
- Seed-based world generation (deterministic)
- Chunk management skeleton (32×32 cells)
- Player sprite positioning and grid movement
- Basic collision system (grid-based)
- Save/load skeleton (binary format tests)

**OUT OF SCOPE (Phase 2+):**
- Survival mechanics (hunger, thirst, etc.)
- Skill progression system
- Inventory/crafting
- Water systems (Waterways integration)
- NPCs/merchants
- Dialogue systems
- Combat mechanics
- Any content (biomes, items, etc.) - procedurally generated only

---

## Context for Development

### Architecture Overview

**Game Engine:** Godot 4.x 3D
**GPU Technology:** Native Compute Shaders (GLSL, no CPU fallback)
**Rendering Approach:** 2D TileMap sprites in 3D GridMap space
**World Generation:** Deterministic seed-based procedural (Minecraft-style)
**Grid System:** 32×32 cells per chunk, 3D orthographic view
**Persistence:** Binary format (FileAccess.store_var()) with delta-only saves

### Technical Stack

| Component | Choice | Version | Notes |
|-----------|--------|---------|-------|
| Engine | Godot 4.x | 4.3+ | 3D engine with compute shader support |
| GPU Pipeline | Native Compute Shaders (GLSL) | 4.3+ | Must support compute shaders natively |
| Rendering | GridMap (3D) + TileMap (2D sprites) | 4.x | Community tools available for conversion |
| World Generation | Procedural (GPU-computed) | N/A | Noise generation via compute shaders |
| Collision | AStar Grid + Physics3D | 4.x | Grid-based pathfinding, basic physics |
| Save/Load | FileAccess.store_var() | 4.x | Binary format for efficiency |

### Codebase Patterns

**Naming Conventions:**
- Files: `snake_case.gd` (e.g., `player.gd`, `world_generator.gd`)
- Classes: `PascalCase` (e.g., `class_name Player extends Node3D`)
- Constants: `UPPER_CASE` (e.g., `CHUNK_SIZE = 32`)
- Scenes: `PascalCase.tscn` (e.g., `Player.tscn`, `MainScene.tscn`)

**Folder Structure:**

```
harsh-world-3d/
├── src/
│   ├── core/
│   │   ├── world/
│   │   │   ├── world_generator.gd       # GPU compute shader pipeline
│   │   │   ├── chunk_manager.gd         # Chunk loading/unloading
│   │   │   ├── terrain_renderer.gd      # GridMap rendering
│   │   │   └── heightmap_shader.glsl    # Compute shader for terrain
│   │   ├── input/
│   │   │   └── input_handler.gd         # Player input processing
│   │   └── camera/
│   │       └── camera_controller.gd     # Orthographic camera setup
│   ├── gameplay/
│   │   └── player/
│   │       ├── player.gd                # Player character (Node3D)
│   │       ├── player_movement.gd       # Grid-based movement
│   │       └── player_sprite.gd         # Sprite rendering in 3D
│   └── persistence/
│       ├── save_system.gd               # Save/load logic
│       └── world_seed.gd                # Seed management
├── assets/
│   ├── sprites/
│   │   ├── player/
│   │   │   └── player.png               # Player sprite sheet
│   │   └── terrain/
│   │       └── grass_tile.png           # Terrain tile sprite
│   ├── shaders/
│   │   └── heightmap_compute.glsl       # GPU compute shader
│   └── scenes/
│       ├── main_scene.tscn              # Main game scene
│       ├── Player.tscn                  # Player scene
│       └── WorldGrid.tscn               # GridMap scene
├── docs/
│   └── game-architecture.md             # Architecture reference
└── project.godot                        # Godot project file
```

**Core Classes & Patterns:**

```gdscript
# src/core/world/world_generator.gd
class_name WorldGenerator
extends Node3D

var world_seed: int = 12345
var chunk_size: int = 32

func generate_world(seed: int) -> void:
    world_seed = seed
    # Call GPU compute shader for terrain
    # Generate heightmap using Perlin noise on GPU

# src/gameplay/player/player.gd
class_name Player
extends Node3D

var grid_position: Vector2i = Vector2i(0, 0)
var max_inventory_weight: float = 50.0

func move_to_cell(direction: Vector2i) -> void:
    grid_position += direction
    position = Vector3(grid_position.x * 32, get_height_at(grid_position), grid_position.y * 32)
```

### Files to Reference

1. **[game-architecture.md](../../docs/game-architecture.md)** - Complete architecture decisions and patterns
2. **[GDD.md](../../docs/game-design/GDD.md)** - Game Design Document (MVP source of truth)
3. **Godot 4.x Compute Shader Docs** - For GPU pipeline implementation
4. **Waterways Plugin (phase 2)** - For water system reference

### Technical Decisions (from ADR)

- **GPU-Exclusive Procedural Generation** (ADR-001): All generation must use GPU compute shaders (no CPU fallback)
- **Deterministic World via Seeding** (ADR-002): World fully reproducible via seed; chunks regenerable
- **Delta-Only Persistence** (ADR-003): Save only modifications, regenerate base world from seed
- **Grid-Based Movement** (ADR-005): 32×32 cell grid, grid-locked movement (not free-roaming)

---

## Critical Assumptions to Verify

Before starting Phase 1, these assumptions must be validated:

### GPU Compute Assumptions
- ✓ **GPU compute shaders compile natively in Godot 4.3+** - Not external compilation
  - *Action: Create minimal test shader, verify compilation and execution*
- ✓ **Perlin noise on GPU is fully deterministic** - Same seed produces identical output every frame
  - *Action: Generate heightmap twice with same seed, verify bit-perfect match*
- ✓ **GPU compute performance is acceptable** - Heightmap generation <16ms per frame (60 FPS target)
  - *Action: Profile shader on minimum target GPU (GTX 750)*
- ✓ **Texture output from compute shader is readable on CPU** - For collision/pathfinding checks
  - *Action: Write heightmap to texture, read back heights for grid collision*

### Rendering Assumptions
- ✓ **2D→3D sprite conversion tools work with custom shader pipeline**
  - *Action: Test community tools with Phase 1 rendering system*
- ✓ **GridMap orthographic camera provides clear visibility of grid and sprites**
  - *Action: Setup orthographic camera, verify sprite alignment to grid*
- ✓ **Sprite batch rendering performance is acceptable** with 10×10 visible chunks
  - *Action: Load 10×10 chunk grid, measure FPS with sprites rendered*

### Gameplay Feel Assumptions
- ✓ **Grid-locked movement (32×32 cells) feels right to play**
  - *Decision needed: Instant teleport vs smooth animation between cells*
  - *Action: Implement both, playtest to determine preference*
- ✓ **Chunk streaming (load/unload around player) feels seamless**
  - *Action: Test chunk loading at various speeds, measure pop-in perception*

### Save System Assumptions
- ✓ **FileAccess.store_var() binary format is performant enough** for frequent saves
  - *Action: Benchmark save/load time for different world sizes*
- ✓ **Delta-only persistence (only save modifications, regenerate terrain) reduces save file size significantly**
  - *Action: Compare save file size: full save vs delta-only*

---

## GPU Testing Checklist

Complete before proceeding to gameplay systems (Phase 2):

- [ ] **Shader Compilation**
  - [ ] GLSL compute shader compiles in Godot 4.3+
  - [ ] No compilation errors on minimum target GPU
  - [ ] Shader source code compiles for NVIDIA/AMD/Intel GPUs

- [ ] **Determinism Verification**
  - [ ] Heightmap generation: Same seed = byte-identical output
  - [ ] Multi-run consistency: Generate same terrain 10 times, all identical
  - [ ] Tested across different hardware (at least 2 different GPU models)
  - [ ] **SEAMING CRITICAL:** Adjacent chunks (0,0) and (1,0) share identical pixels at boundary
    - Generate chunk at (0,0): right edge pixels (x=31)
    - Generate chunk at (1,0): left edge pixels (x=0)
    - Compare: Boundary pixels must be byte-identical
    - Test with 5 different seeds to verify consistency
  - [ ] **ISLAND+OCEAN:** Ocean border chunks generate consistently with land chunks
    - Generate island center chunk and adjacent ocean chunk
    - Verify smooth height transition at boundary (no discontinuities)
    - Test: Ocean chunk generation must produce consistent ocean heights

- [ ] **Performance Profiling**
  - [ ] Heightmap generation time: Target <16ms/frame
  - [ ] Texture readback time (if needed for collision): <5ms
  - [ ] Total frame time with 10×10 chunks: 60 FPS sustained

- [ ] **Integration Testing**
  - [ ] GPU heightmap → CPU collision system works correctly
  - [ ] Player position → correct height lookup
  - [ ] **Chunk boundaries have no seams or artifacts**
    - [ ] Visual inspection: No visible cracks or discontinuities at chunk borders
    - [ ] Height continuity: Player moving across chunk boundary experiences smooth height transition
    - [ ] Collision consistency: Pathfinding treats chunk boundary as continuous (no false obstacles)
    - [ ] 10×10 chunk grid load test: All boundary pixels verify seamless for 100 total boundaries
  - [ ] **Island generation with ocean:**
    - [ ] Island chunks surrounded by ocean chunks generate seamlessly
    - [ ] Ocean height consistent across all ocean chunks
    - [ ] Island→Ocean boundary shows natural elevation transition (no cliff artifacts)

---

## GPU Compute Shader Implementation Guide

### Tileable Perlin Noise for Seamless Chunk Generation

**Reference Implementation:** Use tileable Perlin noise via sine-wave coordinate wrapping to guarantee seamless chunk boundaries.

**Complete Shader Structure (heightmap_compute.glsl):**

```glsl
#version 450

// TILE_SIZE must match chunk size in units (e.g., 32 cells * pixel_scale)
const int TILE_SIZE = 256;  // Adjust based on your chunk coordinate system
const float TWO_PI = 6.28318530718;

layout(local_size_x = 8, local_size_y = 8, local_size_z = 1) in;
layout(rgba32f, binding = 0) uniform image2D heightmap_output;

uniform int chunk_x;      // Chunk coordinate (0, 1, 2, ...)
uniform int chunk_y;      // Chunk coordinate (0, 1, 2, ...)
uniform int world_seed;   // Seed for deterministic generation

// ============================================
// PERLIN NOISE IMPLEMENTATION (standard)
// ============================================
// [Include standard 3D Perlin noise here - see Godot docs or shadertoy]
// Key: Takes vec3 input, returns float (0-1)

float perlin_noise(vec3 p) {
  // Standard Perlin noise implementation
  // Can copy from Godot documentation or proven sources
  // Must be deterministic (same input = same output)
  vec3 pi = floor(p);
  vec3 pf = fract(p);

  // [Full Perlin implementation...]
  // Simplified: just return a basic gradient-based noise
  return sin(p.x) * cos(p.y) * sin(p.z) * 0.5 + 0.5;
}

// ============================================
// TILEABLE PERLIN NOISE WRAPPER
// ============================================
float tileable_perlin(vec3 p) {
  // Convert to tileable coordinates using sine wave wrapping
  // This ensures noise loops seamlessly at tile boundaries

  float x_wrapped = sin(p.x * TWO_PI / float(TILE_SIZE)) * float(TILE_SIZE) / TWO_PI;
  float y_wrapped = sin(p.y * TWO_PI / float(TILE_SIZE)) * float(TILE_SIZE) / TWO_PI;
  float z_seed = p.z;  // Keep seed component unchanged

  vec3 wrapped_p = vec3(x_wrapped, y_wrapped, z_seed);

  return perlin_noise(wrapped_p);
}

// ============================================
// ELEVATION SIMULATION
// ============================================
float elevation_gradient(vec3 world_pos) {
  // Creates natural elevation patterns (not flat terrain)
  // Simulates mountain/valley formation via noise octaves

  float elevation = 0.0;
  float amplitude = 1.0;
  float frequency = 1.0;

  // Multi-octave noise for natural terrain variation
  for (int i = 0; i < 4; i++) {
    elevation += amplitude * tileable_perlin(world_pos * frequency);
    amplitude *= 0.5;
    frequency *= 2.0;
  }

  return elevation * 0.3; // Scale to reasonable height range
}

// ============================================
// CRATER/FEATURE SIMULATION
// ============================================
float crater_simulation(vec3 world_pos) {
  // Creates natural depressions and peaks
  // Uses radial falloff from feature centers

  vec2 feature_pos = mod(world_pos.xy, 128.0);  // Repeat every 128 units
  float distance_to_center = length(feature_pos - vec2(64.0));

  // Crater: depression in terrain
  float crater = 0.1 * exp(-distance_to_center / 20.0);

  return -crater;  // Negative = depression
}

// ============================================
// MAIN COMPUTE SHADER
// ============================================
void main() {
  // Get pixel coordinates for this thread
  ivec2 pixel_coord = ivec2(gl_GlobalInvocationID.xy);

  // World position = chunk offset + pixel offset
  vec3 world_pos = vec3(
    float(chunk_x * 32 + pixel_coord.x),
    float(chunk_y * 32 + pixel_coord.y),
    float(world_seed)
  );

  // Generate seamless height using tileable Perlin
  float height = tileable_perlin(world_pos);

  // Add elevation variation
  height += elevation_gradient(world_pos);

  // Add crater/feature detail
  height += crater_simulation(world_pos);

  // Clamp to valid range (0.0 - 1.0)
  height = clamp(height, 0.0, 1.0);

  // Write to output texture
  imageStore(heightmap_output, pixel_coord, vec4(height, 0.0, 0.0, 1.0));
}
```

### Integration Notes:

1. **TILE_SIZE constant:** Must match your chunk size. If chunks are 32 grid cells, TILE_SIZE should be 256 (32 * 8 texels per cell, for example).

2. **World Seed:** Include in the Perlin noise input (z-component) to ensure different seeds produce different worlds while maintaining determinism.

3. **Chunk Coordinates:** Pass chunk_x and chunk_y to the shader. These determine the world position for noise sampling.

4. **Validation:** After implementing:
   - Generate chunk (0,0) and (1,0) with same seed
   - Extract right edge of (0,0): pixels[x=31, 0:32]
   - Extract left edge of (1,0): pixels[x=0, 0:32]
   - Compare: Must be pixel-identical

### Performance Optimization:

- Sine-wave wrapping is ~5-10% slower than standard Perlin
- Acceptable for <16ms/frame target (measure on GTX 750)
- If slower, consider pre-computed lookup tables for sine/cos operations

---

## Implementation Plan

### Tasks

#### 1. Project Initialization & Setup
- [ ] **1.1:** Create folder structure (`src/`, `assets/`, `scenes/`)
- [ ] **1.2:** Set up `project.godot` with Godot 4.3+ settings
- [ ] **1.3:** Install recommended plugins (Waterways .NET, OWDB - reference only)
- [ ] **1.4:** Configure editor settings (tilemap grid, orthographic view preferences)

#### 2. GPU Compute Pipeline Foundation
- [ ] **2.1:** Create `src/core/world/heightmap_compute.glsl` (basic Perlin noise)
- [ ] **2.2:** Create `src/core/world/world_generator.gd` - GPU shader caller
- [ ] **2.3:** Test GPU compute performance with small terrain (256x256)
- [ ] **2.4:** Debug GPU compute output (heightmap visualization)

#### 3. Rendering System
- [ ] **3.1:** Create `src/core/camera/camera_controller.gd` (orthographic setup)
- [ ] **3.2:** Create `src/core/world/terrain_renderer.gd` (GridMap 3D setup)
- [ ] **3.3:** Create terrain sprites (or use placeholder quads)
- [ ] **3.4:** Set up GridMap with 32×32 cell grid
- [ ] **3.5:** Test sprite positioning on grid (visual alignment)

#### 4. World System
- [ ] **4.1:** Create `src/core/world/chunk_manager.gd` (load/unload chunks)
- [ ] **4.2:** Create `src/core/world/world_seed.gd` (seed management)
- [ ] **4.3:** Implement chunk streaming (load/unload around player)
- [ ] **4.4:** Test deterministic generation (same seed = same terrain)

#### 5. Player Character
- [ ] **5.1:** Create `src/gameplay/player/player.gd` (basic Node3D)
- [ ] **5.2:** Create `src/gameplay/player/player_movement.gd` (grid movement)
- [ ] **5.3:** Create `src/core/input/input_handler.gd` (WASD/arrow keys)
- [ ] **5.4:** Create player sprite (or placeholder quad)
- [ ] **5.5:** Test movement on grid (smooth animation vs instant)

#### 6. Save/Load System (Skeleton)
- [ ] **6.1:** Create `src/persistence/save_system.gd` (FileAccess setup)
- [ ] **6.2:** Create `src/persistence/world_seed.gd` (seed persistence)
- [ ] **6.3:** Test save/load cycle (player position, world seed)

#### 7. Integration & Testing
- [ ] **7.1:** Create `scenes/main_scene.tscn` (integrate all systems)
- [ ] **7.2:** Playtest basic movement on generated terrain
- [ ] **7.3:** Test chunk loading/unloading (move far from origin)
- [ ] **7.4:** Performance profiling (frame rate, GPU usage)
- [ ] **7.5:** Bug fixes and polish

### Acceptance Criteria

- [ ] **AC-1:** Player can see a procedurally generated 3D world with visible terrain variation
- [ ] **AC-2:** Player can move on grid using WASD or arrow keys
- [ ] **AC-3:** Terrain regenerates identically when reloading same world seed
- [ ] **AC-4:** World chunks load/unload smoothly (no visible pop-in)
- [ ] **AC-5:** Frame rate maintains 60 FPS on target GPU (GeForce GTX 750+)
- [ ] **AC-6:** Save file captures seed and player position; loads correctly
- [ ] **AC-7:** No console errors or warnings during 10+ minute play session

---

## Additional Context

### Dependencies

**Required:**
- Godot 4.3+
- GPU with compute shader support (GeForce GTX 750+, Radeon RX, Intel Arc, Apple Silicon M1+)
- GDScript knowledge
- GLSL compute shader basics

**Optional (Phase 2):**
- Waterways .NET plugin (water system)
- Open World Database (POI generation reference)

### Testing Strategy

**Unit Tests:**
- Seed determinism: Same seed → same heightmap
- Grid movement: Move commands → correct grid position
- Chunk loading: Position changes → correct chunks loaded

**Integration Tests:**
- Full world generation (10x10 chunks)
- Player movement across chunk boundaries
- Save/load cycle with multiple play sessions
- GPU compute shader compilation and execution

**Performance Tests:**
- Heightmap generation time (target: <16ms per frame)
- Chunk load time (target: <50ms per chunk)
- Frame rate with 10x10 chunk grid (target: 60 FPS)
- Memory usage (target: <500MB for 10x10 chunks)

### GPU Compute Shader Notes

**Critical Requirements:**
1. Compute shader MUST compile natively in Godot 4.x (no external compilation)
2. Heightmap output stored as texture (readable by CPU for collision)
3. Test on minimum target GPU (GTX 750) to ensure compatibility
4. Document shader compilation process for future GPU features

**Recommended Approach:**
```glsl
// heightmap_compute.glsl (skeleton)
#version 450

layout(local_size_x = 8, local_size_y = 8, local_size_z = 1) in;
layout(rgba32f, binding = 0) uniform image2D heightmap;

void main() {
    // Compute Perlin noise at this pixel
    // Store height in heightmap texture
}
```

### Known Unknowns & Decision Points

1. **Player Movement Animation** (DECISION NEEDED)
   - *Option A:* Instant teleport between cells (simpler, grid-based feel)
   - *Option B:* Smooth animation between cells (fluid feel, higher CPU cost)
   - *Action:* Implement both, playtest to determine which feels better
   - *Impact:* Could affect player experience significantly

2. **2D→3D Sprite Conversion** (UNKNOWN)
   - Community tools availability/compatibility with custom shader pipeline
   - May need tweaking or custom solution
   - *Action:* Research tools early in Phase 1 Task 3

3. **GPU Shader Portability** (RISK)
   - Compute shader behavior varies significantly by GPU vendor
   - Must test on minimum target GPU (GTX 750) early
   - *Action:* GPU Testing Checklist (see section above)

4. **Chunk Boundary Seaming** (✅ SOLVED - PRIMARY APPROACH SELECTED)
   - **Challenge**: Adjacent chunks generated independently will show visible discontinuities at boundaries
   - **Solution**: Use **Tileable Perlin Noise** (sine-wave coordinate wrapping) for mathematically seamless generation
   - **Why This Works**: Perlin noise becomes periodic at chunk boundaries; same seed always produces identical edge pixels
   - **Implementation**: Modify GPU compute shader to wrap coordinates using sin(x * 2π / tile_size) before noise sampling
   - **Benefits**: Zero performance overhead, deterministic across all hardware, no overlap padding needed, works perfectly with island+ocean constraint
   - **Validation**: Add boundary pixel comparison tests to GPU Testing Checklist; verify seaming holds on 3+ different GPU models
   - *Action:* Implement in Phase 1 Task 2.2 (GPU compute shader). Reference: Perlin noise tileable implementation using sine-wave wrapping

5. **Orthographic Camera Projection** (TECHNICAL UNKNOWN)
   - How to setup GridMap 3D camera for clear top-down view
   - Sprite alignment to grid cells may need tweaking
   - *Action:* Prototype in Phase 1 Task 3 early

6. **Texture Readback Performance** (PERFORMANCE UNKNOWN)
   - Reading computed heightmap back to CPU for collision checks
   - Could be bottleneck if not optimized
   - *Action:* Performance test in GPU Testing Checklist

7. **Deterministic Randomness Across Platforms** (CRITICAL UNKNOWN)
   - GPU random number generation may differ between NVIDIA/AMD/Intel
   - Affects determinism requirement
   - *Action:* Test on at least 2 different GPU types, document differences

### Notes

- **No Visual Polish:** Phase 1 is technical foundation only. Expect programmer-art placeholder sprites.
- **Performance First:** Prioritize GPU efficiency over graphics quality.
- **Modular Design:** Keep systems loosely coupled for Phase 2 integration.
- **Document Decisions:** Log why architectural choices were made (GPU approach, grid size, etc.).

---

## Success Definition

**Phase 1 is complete when:**
1. ✅ A procedurally generated world is visible and playable
2. ✅ Player can move on the grid consistently
3. ✅ World regenerates identically with same seed
4. ✅ Save/load preserves game state
5. ✅ GPU compute shaders compile and execute correctly
6. ✅ No critical console errors
7. ✅ Performance meets targets (60 FPS, <500MB memory)

**Ready for Phase 2:** Core gameplay systems (survival, skills, inventory)

---

**Generated:** 2025-12-02
**For:** JC
**Project:** Harsh World
**Status:** COMPLETE - Ready for Implementation
