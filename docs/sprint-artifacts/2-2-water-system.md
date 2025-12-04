# Story 2.2: Water System - Rivers, Lakes & Hydrology

**Status:** drafted

**Story Key:** 2-2-water-system

**Epic:** 2 - Procedural World Generation

**Priority:** High (core exploration and survival element)

---

## Story

**As a** player,

**I want** procedurally generated rivers and lakes that affect navigation and provide water resources,

**so that** water becomes a strategic element of exploration and survival.

---

## Acceptance Criteria

- [ ] Waterways .NET plugin integrated for river/lake generation
- [ ] River generation: DEM-based flow accumulation from heightmap
- [ ] Water body classification: Creeks (tiny), Streams (small), Rivers (large), Lakes (static)
- [ ] Water placement: Deterministic based on seed (same seed = same water layout)
- [ ] Water visual: Sprites/shaders distinguish water type (river vs lake color/animation)
- [ ] Water obstacles: Rivers block movement (require ford or canoe), lakes isolated
- [ ] Fishing spots: Water bodies generate fishing nodes automatically
- [ ] Water availability: Player can drink from water bodies (stamina/hunger trade-off)
- [ ] Canoe mechanics: Can craft/trade for canoe to travel rivers faster
- [ ] Bridge locations: Some rivers have natural or built bridge crossing points
- [ ] Flood risk: Heavy rain causes water level changes (seasonal/weather based)
- [ ] Performance: Water system doesn't degrade performance below 45 FPS in dense areas
- [ ] Chunk integration: Water bodies persist correctly across chunk boundaries

---

## Tasks / Subtasks

### Task 1: Waterways Plugin Integration

- [ ] Evaluate Waterways .NET plugin (or alternative C# solution)
  - [ ] Test compatibility with Godot 4.x
  - [ ] Evaluate performance on target hardware
  - [ ] AC: Plugin integrates without breaking existing systems
- [ ] Set up Waterways in project
  - [ ] Import plugin to addons/waterways/
  - [ ] Configure for deterministic generation
  - [ ] AC: Plugin is available and functional
- [ ] Integration point: Connect DEM heightmap to Waterways
  - [ ] Pass heightmap from GPU terrain generation to Waterways
  - [ ] AC: Waterways receives heightmap data correctly

### Task 2: River & Lake Generation Algorithm

- [ ] Implement DEM-based flow accumulation
  - [ ] Use heightmap to determine water flow directions
  - [ ] Calculate flow accumulation (how much water flows through each cell)
  - [ ] Set threshold: cells above threshold become rivers/streams
  - [ ] AC: Rivers flow downhill naturally from terrain
- [ ] Water body classification system
  - [ ] Define classification thresholds:
    - Creeks: small tributaries (1-2 cells wide)
    - Streams: medium flows (3-5 cells wide)
    - Rivers: large flows (6+ cells wide)
    - Lakes: accumulation basins (static water bodies)
  - [ ] AC: Different water types visibly distinct
- [ ] Deterministic water placement
  - [ ] Use chunk_seed + heightmap to generate water layout
  - [ ] Same seed produces same water bodies
  - [ ] AC: Water layout reproducible with same seed
- [ ] Water level calculation
  - [ ] Determine water height based on terrain elevation
  - [ ] Create water surface mesh/sprites for visualization
  - [ ] AC: Water appears at correct elevation relative to terrain

### Task 3: Water Visualization & Physics

- [ ] Water sprite/mesh rendering
  - [ ] Create water sprites for different water types
  - [ ] River sprites (flowing water animation)
  - [ ] Lake sprites (calm water animation)
  - [ ] Animated water surface with foam/ripples
  - [ ] AC: Water is visually distinct and appealing
- [ ] Water collision system
  - [ ] Rivers block movement (CollisionShape3D as barriers)
  - [ ] Lakes block movement (islands in lakes are traversable)
  - [ ] Player can walk to water edge but can't cross without canoe
  - [ ] AC: Rivers/lakes are physical obstacles
- [ ] Water shader integration
  - [ ] Implement water shader (color, animation, reflections)
  - [ ] Different shader settings for river vs lake
  - [ ] Performance optimization (LOD for distant water)
  - [ ] AC: Water looks good and performs well

### Task 4: Fishing System Integration

- [ ] Fishing node placement
  - [ ] Automatically place FishingSpot nodes on water bodies
  - [ ] Placement density: 1 fishing spot per ~50 cells of water
  - [ ] AC: Fishing spots appear in all water bodies
- [ ] Fish type variation by water type
  - [ ] Rivers: freshwater fish (salmon, trout, bass)
  - [ ] Lakes: freshwater fish (pike, perch, carp)
  - [ ] Coastal water: saltwater fish (cod, herring, mackerel)
  - [ ] AC: Different fish types in different water bodies
- [ ] Integration with Story 3.4 (Fishing System)
  - [ ] Fishing nodes ready for Story 3.4 implementation
  - [ ] AC: Story 3.4 can hook into FishingSpot system

### Task 5: Navigation & Movement Interaction

- [ ] River crossing mechanics
  - [ ] Options for crossing rivers:
    1. Walk to shallow ford (slower, stamina cost)
    2. Use canoe (fast travel)
    3. Find bridge crossing (safe, direct)
  - [ ] Fording: Player can cross if stamina > 10, costs 5 stamina
  - [ ] AC: River crossing options implemented
- [ ] Canoe mechanics setup
  - [ ] Canoe item: equipment that enables river travel
  - [ ] Canoe speeds: 2x normal movement on rivers
  - [ ] Canoe restrictions: Can't use canoe on lakes
  - [ ] AC: Canoe system ready for Story 3.4 integration
- [ ] Movement speed modifiers for water areas
  - [ ] Walking through shallow water: 0.7x speed
  - [ ] Walking through marsh: 0.5x speed
  - [ ] Deep water: impassable without canoe
  - [ ] AC: Water areas have appropriate movement penalties

### Task 6: Water Resource System

- [ ] Drinking from water bodies
  - [ ] Player can interact with water to drink
  - [ ] Cost: 2 stamina to drink, restores 5 hunger
  - [ ] Risk: Contaminated water has small chance of poisoning
  - [ ] AC: Water available as resource
- [ ] Water quality variation
  - [ ] Clean water: safe to drink
  - [ ] Contaminated water: small poison risk (5%)
  - [ ] Stagnant water: higher poison risk (25%)
  - [ ] AC: Water quality affects gameplay
- [ ] Integration with survival loop
  - [ ] Water becomes strategic resource (reduce hunger)
  - [ ] AC: Story 3.1 can consume water resources

### Task 7: Testing & Chunk Integration

- [ ] Determinism testing
  - [ ] Test: Same seed generates identical water layouts
  - [ ] Test: Water layout matches across 100 chunks
  - [ ] AC: Water system is fully deterministic
- [ ] Chunk boundary testing
  - [ ] Test: Water bodies align correctly across chunk boundaries
  - [ ] Test: Rivers flow correctly between chunks
  - [ ] AC: No visual artifacts or misalignments at chunk edges
- [ ] Performance testing
  - [ ] Test: Performance with 50+ water bodies
  - [ ] Target: Maintain 45+ FPS in water-heavy areas
  - [ ] AC: Performance acceptable on target hardware
- [ ] Integration testing
  - [ ] Test: Fishing spots appear correctly
  - [ ] Test: Water physics work with player movement
  - [ ] Test: River crossing mechanics function
  - [ ] AC: All systems integrate smoothly
- [ ] Visual quality testing
  - [ ] Test: Water visuals are appealing (animations, colors)
  - [ ] Test: Different water types visibly distinct
  - [ ] AC: Water looks good in game

---

## Dev Notes

### Architecture Reference

**From [docs/game-architecture.md](#)**

- Water system: Waterways .NET plugin for DEM-based hydrology
- Chunk-based world: Water bodies persist correctly across chunks
- Deterministic generation: Water layout reproducible from seed
- Sprite3D + CollisionShape3D: Water rendered as sprites with collision
- Performance targets: 45+ FPS minimum, 60 FPS target

### Technical Approach

**Waterways .NET Plugin:**
- Industry-standard for procedural water generation
- Uses DEM (Digital Elevation Model) from heightmap
- Flow accumulation algorithm generates natural river networks
- Deterministic output from input heightmap

**Water Flow Algorithm:**
```
For each cell in heightmap:
  1. Calculate flow direction (toward lowest adjacent cell)
  2. Accumulate flow from all cells that flow into this cell
  3. If accumulated_flow > river_threshold → river
  4. If accumulated_flow > creek_threshold → creek
  5. Otherwise → land
```

**Water Body Classification:**
- Creeks: flow < 10 cells (tiny tributaries)
- Streams: flow 10-50 cells (small waterways)
- Rivers: flow > 50 cells (major waterways)
- Lakes: localized accumulation basins (static water)

**Determinism:**
- Use chunk_seed + heightmap to generate water layout
- Same world_seed + chunk_coords always produce same water
- No per-frame randomness in water generation

### Components to Touch

- `src/core/water/water_generator.gd` (create new - main water generation)
- `src/core/water/water_physics.gd` (create new - water collision/interaction)
- `src/core/water/fishing_spawner.gd` (create new - fishing node placement)
- `src/core/world/chunk_manager.gd` (modify - integrate water generation)
- `src/core/world/biome_generator.gd` (modify - pass heightmap to Waterways)
- `src/gameplay/player/movement.gd` (modify - water movement penalties)
- `addons/waterways/` (import plugin)
- `assets/sprites/water/` (create or import water sprites)
- `assets/shaders/water.gdshader` (create water shader)

### Testing Standards

- Unit tests for flow accumulation: `tests/test_water_generation.gd`
- Integration tests for chunk boundaries: `tests/test_water_chunk_integration.gd`
- Visual quality inspection (manual testing)
- Performance profiling on target hardware
- Determinism verification (same seed = same water)

### Project Structure Notes

- Water sprites stored in `assets/sprites/water/`
- Water shader in `assets/shaders/water.gdshader`
- Waterways plugin in `addons/waterways/`
- Water generation triggered during chunk generation
- Water bodies serialized as part of chunk data
- FishingSpot nodes created during chunk generation

---

## References

- [Source: docs/epics.md#Story-2.2](docs/epics.md#story-22-water-system---rivers-lakes--hydrology)
- [Source: docs/game-architecture.md#Water System](#) (if section exists)
- [Source: src/core/world/terrain_generation.gd](#) (heightmap source)
- [Source: src/core/world/chunk_manager.gd](#) (chunk integration point)
- **External:** [Waterways Plugin Documentation](https://github.com/Xananax/godot-waterways) (or equivalent)

---

## Dependencies & Integration

**Depends On:**
- Story 1.2: GPU terrain generation (provides heightmap)
- Story 1.4: Chunk manager (chunk integration point)
- Story 1.5: World seed system (deterministic water placement)
- Story 2.1: Biome system (biome-specific water types)

**Enables (Blocked By This):**
- Story 3.4: Fishing system (fishing spots provided here)
- Story 3.2: Foraging system (water-adjacent foraging)
- Story 4.2: Fire system (water source for camps)

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
- [ ] Integration points identified with dependent stories
- [ ] Ready for handoff to developer

### Dev Status

- [ ] In Progress
- [x] Drafted (waiting for developer assignment)
- [ ] Review Ready
- [ ] Done

### Completion Notes List

(To be filled during development)

### File List

- [ ] 2-2-water-system.md (this file)
- [ ] 2-2-water-system-context.md (to be generated by *story-context)
- [ ] tests/test_water_generation.gd (to be created)
- [ ] tests/test_water_chunk_integration.gd (to be created)
- [ ] src/core/water/water_generator.gd (to be created)
- [ ] src/core/water/water_physics.gd (to be created)

---

*Story created: 2025-12-04 | Ready for development | Depends on: Story 1.2, 1.4, 1.5, 2.1*
