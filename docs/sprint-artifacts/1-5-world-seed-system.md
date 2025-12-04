# Story 1.5: World Seed System & Deterministic Generation

**Status:** drafted

**Story Key:** 1-5-world-seed-system

**Epic:** 1 - Foundation & GPU Validation

**Priority:** Critical (blocks reproducible testing across all systems)

---

## Story

**As a** developer,

**I want** to implement world seed management ensuring reproducible generation across all systems,

**so that** the same seed always produces the same world (testing + settlement persistence + reproducibility).

---

## Acceptance Criteria

- [ ] WorldSeed resource created with seed value and generation parameters
- [ ] Seed used in all PRNG calls: noise generation, object spawning, NPC placement
- [ ] Test: Same seed produces identical heightmaps (pixel-perfect comparison across multiple runs)
- [ ] Test: Same seed produces identical biome assignments (100% match verification)
- [ ] Test: Same seed produces identical water bodies (rivers/lakes placement match)
- [ ] Seed persisted in save file (loaded on game load, survives permadeath)
- [ ] New game creates new random seed (or user-specified for testing)
- [ ] Seed value displayable in game (for debugging/community sharing)
- [ ] Documentation: how determinism is maintained across all systems (GPU, CPU, random systems)
- [ ] Integration: Seed integrated into terrain generation shader (GPU noise)
- [ ] Integration: Seed integrated into chunk-based generation (deterministic per-chunk)
- [ ] Validation: Test on 3+ platforms confirms determinism works consistently

---

## Tasks / Subtasks

### Task 1: Seed System Design & Resource Class

- [ ] Create WorldSeed Resource class (GDScript)
  - [ ] seed: int (32-bit or 64-bit)
  - [ ] generation_parameters: Dictionary (for future expansion)
  - [ ] creation_timestamp: int (metadata)
  - [ ] Serializable to .tres format
- [ ] Design PRNG selection strategy (PCG, xorshift, or custom)
  - [ ] AC: Determinism across runs verified
  - [ ] AC: Period of PRNG sufficient for world size
- [ ] Create PRNG wrapper class for consistent randomness
  - [ ] AC: Accepts seed value
  - [ ] AC: Produces consistent sequences
  - [ ] AC: Used consistently across all randomness in project

### Task 2: GPU Shader Integration with Seed

- [ ] Integrate seed into terrain_generation.glsl compute shader
  - [ ] Seed passed as uniform buffer input
  - [ ] Noise generation uses seed (all octaves derive from seed)
  - [ ] AC: Same seed produces identical heightmap output
  - [ ] AC: Performance not degraded by deterministic approach
- [ ] Test GPU determinism on 3+ GPU types
  - [ ] NVIDIA GTX 1060 (or equivalent)
  - [ ] AMD RX 580 (or equivalent)
  - [ ] Intel Iris/Arc (or equivalent)
  - [ ] AC: All produce identical heightmaps for same seed

### Task 3: Per-Chunk Deterministic Generation

- [ ] Implement chunk-specific seed derivation
  - [ ] Formula: chunk_seed = PRNG(world_seed, chunk_x, chunk_y, system_hash)
  - [ ] Example: `hash(world_seed ^ (chunk_x << 16) ^ chunk_y ^ hash("biome_assignment"))`
  - [ ] AC: Same world_seed + chunk_coords always produce same chunk_seed
- [ ] Verify all systems use chunk_seed for chunk-specific randomness
  - [ ] Object spawning uses chunk_seed
  - [ ] NPC placement uses chunk_seed
  - [ ] Resource distribution uses chunk_seed
  - [ ] AC: Same chunk_seed produces identical results across runs

### Task 4: Integration with Existing Systems

- [ ] Integration: ChunkManager uses seed for deterministic generation
  - [ ] On chunk load: derive chunk_seed, pass to generation
  - [ ] AC: Regenerated chunks match original exactly
- [ ] Integration: BiomeGenerator uses seed for spawn rates
  - [ ] Objects spawned deterministically based on chunk_seed
  - [ ] AC: Same chunk always has same objects
- [ ] Integration: NPC placement uses seed
  - [ ] NPCs appear at deterministic locations per world_seed
  - [ ] AC: NPCs at identical locations across playthroughs with same seed
- [ ] Integration: TerrainGeneration pipeline confirms determinism
  - [ ] GPU generates same heightmap for same seed
  - [ ] CPU biome assignment matches
  - [ ] AC: Full terrain pipeline is deterministic

### Task 5: Save/Load & Persistence

- [ ] Seed storage in GameState resource
  - [ ] Save on new game start
  - [ ] Load on game load
  - [ ] AC: Seed persists across save/load cycles
- [ ] Settlement persistence across deaths
  - [ ] New world uses different seed (new Random().next_uint32())
  - [ ] Settlement location transferred to new world
  - [ ] AC: Settlement structures appear in new world
- [ ] Seed displayable in HUD/Debug menu
  - [ ] Show seed value in console or debug panel
  - [ ] AC: Player can copy seed and share with others

### Task 6: Testing & Validation

- [ ] Unit tests: PRNG consistency
  - [ ] Test: Same seed produces same sequence
  - [ ] Test: Different seeds produce different sequences
  - [ ] Test: PRNG period is sufficient
  - [ ] AC: All tests pass
- [ ] Integration tests: Full terrain determinism
  - [ ] Test: Generate world A with seed 12345
  - [ ] Test: Generate world B with seed 12345
  - [ ] Test: Compare heightmaps pixel-perfect (100% match)
  - [ ] Test: Compare biome assignments 100% match
  - [ ] Test: Compare water layouts 100% match
  - [ ] AC: All match exactly
- [ ] Cross-platform tests
  - [ ] Test on Windows 64-bit
  - [ ] Test on Linux 64-bit (if applicable)
  - [ ] Test on macOS (if applicable)
  - [ ] AC: Same results across all platforms
- [ ] GPU vendor tests
  - [ ] Test on NVIDIA GPU
  - [ ] Test on AMD GPU
  - [ ] Test on Intel GPU
  - [ ] AC: Deterministic on all tested GPUs
- [ ] Documentation
  - [ ] Write README: "How Determinism Works"
  - [ ] Document seed derivation formula
  - [ ] Document PRNG choice and why
  - [ ] Document tested platforms

---

## Dev Notes

### Architecture Reference

**From [docs/game-architecture.md](#)**

- Deterministic seed-based world generation is a core requirement
- GPU terrain generation uses compute shaders (RenderingDevice API)
- Chunk-based world (32×32) with deterministic generation
- Settlement persistence across permadeath requires seed reproducibility

### Technical Approach

**PRNG Selection:** Use deterministic PRNG (PCG or xorshift-based)
- Requirement: Deterministic across runs and platforms
- Requirement: Fast (millions of calls per world generation)
- Requirement: Good distribution (no visual artifacts from clustering)

**Seed Flow:**
1. New game: Generate random world_seed
2. On chunk access: Derive chunk_seed from world_seed + chunk_coords + system_id
3. GPU shader: Accepts world_seed, uses for noise generation
4. CPU systems: Accept chunk_seed, use for object spawning/NPCs
5. Save file: Persist world_seed for reload
6. Permadeath: Generate new world_seed, keep settlement, transfer to new world

**Chunk Seed Derivation Example:**
```gdscript
func derive_chunk_seed(world_seed: int, chunk_x: int, chunk_y: int, system_id: String) -> int:
    var h1 = world_seed
    var h2 = hash(h1 ^ (chunk_x << 16) ^ chunk_y)
    var h3 = hash(h2 ^ hash(system_id))
    return h3 & 0xFFFFFFFF
```

### Components to Touch

- `src/core/world/world_seed.gd` (create new - WorldSeed resource)
- `src/core/world/deterministic_rng.gd` (create new - PRNG wrapper)
- `src/core/world/terrain_generation.gd` (modify - integrate seed)
- `src/shaders/terrain_generation.glsl` (modify - add seed uniform)
- `src/core/world/chunk_manager.gd` (modify - use deterministic generation)
- `src/core/world/biome_generator.gd` (modify - use chunk_seed)
- `src/core/world/npc_spawner.gd` (modify - use chunk_seed)
- `src/gameplay/game_state.gd` (modify - save/load seed)

### Testing Standards

- Unit tests for PRNG: `tests/test_deterministic_rng.gd`
- Integration tests for terrain: `tests/test_terrain_determinism.gd`
- Cross-platform validation: Run on Windows + (Linux if available)
- GPU vendor validation: Test on 3+ GPU types (NVIDIA, AMD, Intel)
- Pixel-perfect comparison for heightmaps and biome maps

### Project Structure Notes

- WorldSeed resource saved to `user://saves/world_seed.tres`
- PRNG wrapper should be lightweight (called millions of times)
- Seed derivation formula must be consistent across all systems
- No floating-point arithmetic in seed derivation (integer-only for consistency)

---

## References

- [Source: docs/epics.md#Story-1.5](docs/epics.md#story-15-world-seed-system--deterministic-generation)
- [Source: docs/game-architecture.md#Deterministic Generation](#) (if section exists)
- [Source: src/core/world/terrain_generation.gd](#) (GPU pipeline reference)
- [Source: src/core/world/chunk_manager.gd](#) (chunk generation system)

---

## Dev Agent Record

### Context Reference

<!-- Generated by *story-context workflow -->

### Agent Model Used

Claude Sonnet 4.5

### Validation Checklist

- [ ] Story extracted from epics.md
- [ ] Acceptance criteria are SMART (Specific, Measurable, Achievable, Relevant, Time-bound)
- [ ] Tasks align with acceptance criteria
- [ ] Technical notes reference actual architecture components
- [ ] Ready for handoff to developer

### Dev Status

- [ ] In Progress
- [x] Drafted (waiting for developer assignment)
- [ ] Review Ready
- [ ] Done

### Completion Notes List

(To be filled during development)

### File List

- [ ] 1-5-world-seed-system.md (this file)
- [ ] 1-5-world-seed-system-context.md (to be generated by *story-context)
- [ ] tests/test_deterministic_rng.gd (to be created)
- [ ] tests/test_terrain_determinism.gd (to be created)

---

*Story created: 2025-12-04 | Ready for development | Depends on: Story 1.2 (GPU setup), Story 1.4 (Chunk manager)*
