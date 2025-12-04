# Harsh World - Epic Breakdown

**Author:** JC
**Date:** 2025-12-03
**Project Level:** Beginner Game Dev
**Target Scale:** MVP Early Access with core survival loop

---

## Overview

This document provides the complete epic and story breakdown for Harsh World, decomposing the requirements from the [PRD](./PRD.md) into implementable stories with full technical context from the [Architecture](./game-architecture.md).

Harsh World is a hardcore single-player survival simulator set in 17th-century colonial North America. The game prioritizes mechanics-driven gameplay where food preparation, water management, and settlement placement directly impact survival success.

**Epic Structure Summary (Dependency-Ordered):**
- **Epic 1: Foundation & GPU Validation** - Engine setup, GPU terrain, grid system, chunk manager (MUST validate GPU first!)
- **Epic 2: Procedural World Generation** - Biomes, water system, infinite world exploration (built on validated GPU)
- **Epic 3: Core Survival Loop** - Forage, hunt, fish, prepare food, manage stamina/health
- **Epic 4: Fire & Shelter Management** - Build structures, maintain fire, sleep system
- **Epic 5: Permadeath & World Persistence** - Death mechanics, world reset, settlement persistence
- **Epic 6: NPC Trading System** - NPCs, merchants, reputation, trade mechanics
- **Epic 7: UI & Game Support Systems** - Inventory, HUD, save/load, audio

---

## Functional Requirements Inventory

From PRD.md, extracted all functional requirements:

| FR Code | Requirement | Category | Status |
|---------|-------------|----------|--------|
| F1.1 | Foraging - gather plants, berries, seeds from vegetation | Survival Loop | Core |
| F1.2 | Hunting & Fishing - hunt animals, fish in water bodies | Survival Loop | Core |
| F1.3 | Food Preparation - boil, cook, dry, ferment food | Survival Loop | Core |
| F1.4 | Food Consumption & Nutrition - eat food, manage nutrition | Survival Loop | Core |
| F1.5 | Fire & Shelter Management - maintain fire, shelter for warmth | Survival Loop | Core |
| F1.6 | Settlement Building - build basic structures (fire, storage, shelter) | Survival Loop | Core |
| F2.1 | Character Death - permadeath triggers on starvation/poison/cold | Permadeath | Core |
| F2.2 | World Reset - new world generates on death with different seed | Permadeath | Core |
| F2.3 | Settlement Persistence - settlement structures preserved across deaths | Permadeath | Core |
| F2.4 | Respawn Mechanics - player respawns at settlement automatically | Permadeath | Core |
| F3.1 | NPC Discovery - NPCs at fixed/wandering locations, discovered through exploration | NPC System | Core |
| F3.2 | NPC Trade Mechanics - NPCs have specific wants/offers, fair exchanges required | NPC System | Core |
| F3.3 | NPC Reputation System - reputation affects NPC availability and trade terms | NPC System | Core |
| F3.4 | Required NPC Trades - complex tools must be traded for, not crafted | NPC System | Core |
| F4.1 | Procedural Terrain Generation - GPU compute shaders, deterministic seed-based | World Gen | Core |
| F4.2 | Biome System - 3-4 MVP biomes with unique properties (flora, fauna, resources) | World Gen | Core |
| F4.3 | Water System - rivers, lakes, fishing, canoe travel | World Gen | Core |
| F4.4 | NPC Location Generation - procedurally placed NPCs, vary by seed | World Gen | Core |
| F5.1 | Character Attributes - stamina, health, hunger tracking | Character | Core |
| F5.2 | Character Progression - knowledge-based learning through discovery | Character | Core |
| F5.3 | Equipment System - inventory with weight/capacity limits | Character | Core |
| F6.1 | Day/Night Cycle - visual indicators, different day/night activities | Time/Weather | Core |
| F6.2 | Seasonal System - visual seasonal changes, food availability hints | Time/Weather | MVP |
| F6.3 | Weather System - random events (rain, snow, storms), affects gameplay | Time/Weather | Core |
| F7.1 | Inventory Screen - display items, manage inventory, show equipment | UI | Core |
| F7.2 | Food Preparation Menu - show food items, preparation methods, time/resources | UI | Core |
| F7.3 | Trading Interface - display NPC wants/offers, select items, confirm trades | UI | Core |
| F7.4 | Settlement Building Menu - show structures, resource requirements, placement | UI | Core |
| F7.5 | Minimal HUD - stamina, health, time, season indicators | UI | Core |
| F8.1 | Save Data - persistent settlement, character state, world seed | Save/Load | Core |
| F8.2 | Save Mechanics - auto-save on settlement, manual save available | Save/Load | Core |
| F8.3 | Load Mechanics - load settlement, world from seed, character state | Save/Load | Core |
| F9.1 | Music - background music (5-10 tracks), context-sensitive | Audio | MVP |
| F9.2 | Sound Effects - environmental/action sounds from sound libraries | Audio | MVP |
| F9.3 | Dialogue - text-based dialogue, silent delivery with language barriers | Audio | MVP |
| F9.4 | Accessibility - subtitle support, colorblind support (post-launch) | Accessibility | MVP |

---

## Architecture-Guided Epic Design with Correct Dependency Order

Based on the Architecture document, the technical decisions create the following **implementation sequence**. **Critical:** GPU terrain validation must be Epic 1 to ensure the GPU compute shader pipeline works before building world generation.

### Epic-to-Architecture Mapping (Dependency Order):
| Priority | Epic | Core Components | Architecture Sections | Why This Order |
|----------|------|-----------------|----------------------|-----------------|
| **P1 FIRST** | **1: Foundation & GPU** | Engine setup, GPU compute, grid system, chunk manager | src/core/world, src/shaders, src/core/rendering | **MUST validate GPU works before proceeding!** |
| **P1 SECOND** | **2: World Generation** | Terrain generation, biomes, water system | src/core/world, src/core/water, src/shaders | Built on validated GPU pipeline from Epic 1 |
| **P1 THIRD** | **3: Survival Loop** | Needs system, resource gathering, preparation | src/core/survival, src/gameplay/player | Gameplay on top of validated world |
| **P1 FOURTH** | **4: Fire & Shelter** | Settlement building, structure system | src/core/world, src/gameplay/player | Support systems for survival |
| **P2 FIFTH** | **5: Permadeath** | Death mechanics, world persistence | src/core/world/persistence.gd | Complete gameplay loop |
| **P2 SIXTH** | **6: NPC Trading** | Merchant system, reputation, dialogue | src/gameplay/npcs, reputation_system.gd | Populate validated world |
| **P3 SEVENTH** | **7: UI & Polish** | HUD, inventory, menus, audio | src/ui, assets/sounds, assets/music | Final polish and user experience |

---

## Epic 1: Foundation & GPU Validation

**Epic Goal:** Establish the Godot engine foundation with GPU-based terrain generation validated and working, grid-based rendering system, and basic scene structure. **This epic MUST be completed and GPU validated before proceeding to world generation.**

**Critical Path:** This is the foundation. If GPU compute shaders don't work, the entire project fails. Every story in this epic is P0 (blocking).

**Technical Context from Architecture:**
- Uses Godot 4.x 3D engine in hybrid 2D/3D mode
- GPU terrain generation via RenderingDevice API + GLSL compute shaders
- Chunk-based world (32×32 recommended chunk size)
- Sprite3D + CollisionShape3D rendering instead of GridMap
- Deterministic seed-based world generation
- Performance targets: 60 FPS minimum, 45+ FPS in dense areas

### Story 1.1: Godot Project Setup & Initial Scene Structure

**As a** developer,
**I want** to initialize the Godot 4.x project with proper folder structure and scene organization,
**So that** the foundation is ready for all subsequent systems.

**Acceptance Criteria:**

- [ ] Project created in Godot 4.x with GDScript enabled
- [ ] Folder structure matches Architecture specification (src/, assets/, scenes/, tests/)
- [ ] Main world scene created (world.tscn) with 3D viewport
- [ ] Player spawn point established at settlement location
- [ ] Camera controller added (Don't Starve style isometric view with smooth follow)
- [ ] Input system configured (WASD for movement, E for interaction, Space for run)
- [ ] Basic HUD scene created (ready for stamina/health bars, time indicators)
- [ ] Save/load directory structure created (user://saves/chunks/)

**Prerequisites:** None - this is the foundational story

**Technical Notes from Architecture:**
- Camera: 45° isometric view following player with smooth dampening
- Input handling: CharacterBody3D with velocity-based movement
- Performance: Target 60 FPS on test hardware (Windows 64-bit with GPU compute)
- File structure: Use Resource format (.tres) for save data

---

### Story 1.2: GPU Compute Shader Setup for Terrain Generation ⚡ CRITICAL

**As a** developer,
**I want** to implement the Godot RenderingDevice API with GLSL compute shaders,
**So that** deterministic terrain generation runs on GPU for performance.

**⚠️ VALIDATION MILESTONE:** This story's completion validates the GPU pipeline. If this fails, the project architecture cannot proceed. Extensive testing required.

**Acceptance Criteria:**

- [ ] RenderingDevice API initialized in terrain_generation.glsl
- [ ] Compute shader compiles successfully (SPIRV bytecode) - TEST: compile on 3+ GPUs (NVIDIA, AMD, Intel)
- [ ] Heightmap generation shader outputs 32×32 height values per chunk
- [ ] Perlin noise implementation in GPU (noise.glsl) produces deterministic output from seed
- [ ] Shader pipeline created: seed → noise → heightmap → CPU return
- [ ] First test chunk generates from seed (e.g., seed=12345 produces same heightmap every run) - TEST: 100 chunks with same seed produce identical results
- [ ] Performance measurement: chunk generation < 100ms on target hardware - TEST: measure on NVIDIA GTX 1060, AMD RX 580, Intel Iris
- [ ] Error handling: Graceful fallback if GPU doesn't support compute (show error, don't crash)
- [ ] Shader code documented with input/output contracts
- [ ] **VALIDATION SIGN-OFF:** Document GPU shader works, determinism verified, performance acceptable

**Prerequisites:** Story 1.1 - Project setup complete

**Technical Notes from Architecture:**
- Use RenderingDevice.create_local_rendering_device() for local pipeline
- Compile from preloaded shader resource
- Allocate storage buffers for input/output data
- Execute compute dispatch with appropriate thread groups (32×32 chunk)
- Synchronously read results back to CPU (pipeline stall acceptable for determinism)
- Store results in PackedFloat32Array for biome assignment

**Technical Implementation Pattern:**
```gdscript
var rd: RenderingDevice = RenderingServer.create_local_rendering_device()
var shader = rd.shader_create_from_spirv(compute_shader_spirv)
var pipeline = rd.compute_pipeline_create(shader)
# ... buffer allocation and dispatch ...
var heightmap_result = rd.buffer_get_data(output_buffer)
```

**Validation Testing:**
- Test on 3+ GPU types (document which GPUs work/fail)
- Test determinism: Same seed = same heightmap (pixel-perfect)
- Test performance: Measure generation time per chunk
- Test error cases: GPU not available, shader compilation failure

---

### Story 1.3: Grid-Based World Object System with Sprite3D

**As a** developer,
**I want** to implement the Sprite3D + CollisionShape3D world object system,
**So that** terrain features (trees, rocks, structures) are placed and interact correctly.

**Acceptance Criteria:**

- [ ] WorldObject base class created (extends Node3D with Sprite3D child)
- [ ] Objects placed on 32×32 grid positions (snap-to-grid verified)
- [ ] CollisionShape3D attached to each object with proper layer/mask
- [ ] Collision detection working (player can't walk through trees/rocks)
- [ ] Object types defined: tree, rock, structure, resource_node
- [ ] Resource spawning system maps biome_data → object types
- [ ] Chunk loader instantiates objects from chunk data on load
- [ ] Chunk unloader removes objects on unload (memory management)
- [ ] Performance: 100+ objects per chunk without frame drops

**Prerequisites:** Story 1.2 - Terrain generation complete

**Technical Notes from Architecture:**
- Each world object = Node3D with Sprite3D + CollisionShape3D child nodes
- Collision layers: terrain_objects (layer 2), player (layer 1), npcs (layer 3)
- Collision masks: player walks on/collides with terrain_objects
- Sprite pivot: bottom-center for isometric alignment
- Z-ordering: handled by object's Y position (higher Y = further back)

**Pattern for Custom Objects:**
```gdscript
class_name TreeObject extends WorldObject
func _ready():
    sprite.texture = load("res://assets/sprites/objects/trees/maple.png")
    collision_shape.shape = BoxShape3D.new()
    health = 100
```

---

### Story 1.4: Chunk Manager with Streaming & Persistence

**As a** developer,
**I want** to implement chunk loading/unloading based on player position,
**So that** the world loads dynamically and only modified chunks are saved.

**Acceptance Criteria:**

- [ ] ChunkManager tracks player position and determines active chunks
- [ ] Streaming radius configurable (recommended: 3 chunks in each direction)
- [ ] Chunks loaded in async pattern (don't stall main thread)
- [ ] Chunks unloaded when outside streaming radius
- [ ] ChunkData Resource class stores: heightmap, biome_map, objects[], is_modified flag
- [ ] Save logic: only write chunks where is_modified = true to disk
- [ ] Load logic: if chunk exists on disk, load; otherwise generate from seed
- [ ] Chunk format: Resource (.tres files) saved to user://saves/chunks/x_y.tres
- [ ] 100 chunks tested without performance regression
- [ ] Memory usage stays < 4GB with full persistence

**Prerequisites:** Story 1.3 - World object system complete

**Technical Notes from Architecture:**
- Chunk size: 32×32 (configurable, tested with different sizes)
- Streaming radius: 3 chunks = 5×5 chunk grid (96×96 units)
- Async loading: Use threading to avoid frame stalls
- Persistence: Only save chunks that have player modifications (structures, resource depletion)
- Deterministic: If chunk not on disk, regenerate from world_seed + chunk_x + chunk_y

---

### Story 1.5: World Seed System & Deterministic Generation

**As a** developer,
**I want** to implement world seed management ensuring reproducible generation,
**So that** same seed always produces same world (testing + settlement persistence).

**Acceptance Criteria:**

- [ ] WorldSeed resource created with seed value and generation parameters
- [ ] Seed used in all PRNG calls: noise generation, object spawning, NPC placement
- [ ] Test: Same seed produces identical heightmaps (pixel-perfect comparison)
- [ ] Test: Same seed produces identical biome assignments
- [ ] Test: Same seed produces identical water bodies (rivers/lakes)
- [ ] Seed persisted in save file (loaded on game load)
- [ ] New game creates new random seed (or user-specified)
- [ ] Seed value displayable in game (for debugging/community)
- [ ] Documentation: how determinism is maintained across all systems

**Prerequisites:** Story 1.2 - GPU terrain generation

**Technical Notes from Architecture:**
- Use deterministic PRNG (e.g., PCG or xorshift based on seed)
- All randomness derived from: seed + chunk_x + chunk_y + system_name
- Example: `forest_spawning_rng = PRNG(seed ^ (chunk_x << 16) ^ (chunk_y) ^ hash("forest_spawn"))`
- Shader: pass seed as uniform to compute shader

---

## Epic 2: Procedural World Generation

**Epic Goal:** Implement biome system, water generation, and infinite world exploration creating varied, discoverable environments with resource distribution matching biome characteristics. **Built entirely on the validated GPU pipeline from Epic 1.**

**Technical Context from Architecture:**
- Biome system: 7 primary biomes with 2-3 terrain types each
- Biome assignment: Regional noise-based selection from heightmap
- Water system: Waterways .NET plugin for DEM-based hydrology
- Resource spawning: Biome-based spawn chances for trees, rocks, resources
- Chunk streaming: 32×32 chunks loaded/unloaded based on player proximity

### Story 2.1: Biome System - Create Unique Environments

**As a** player,
**I want** distinct biomes with unique flora, fauna, resources, and visual appearance,
**So that** exploration feels varied and different regions require different strategies.

**Acceptance Criteria:**

- [ ] 7 primary biomes implemented: Coastal Atlantic, Temperate Forest, Deciduous Forest, Grasslands, Appalachian Mountains, Boreal Forest, Wetlands
- [ ] Each biome has unique: visual appearance (sprite colors), forage items, huntable animals, resources
- [ ] Biome selection: Based on regional noise + elevation (noise determines broad biome zones)
- [ ] Terrain types: Each biome has 2-3 terrain subtypes affecting resource distribution
- [ ] Biome visual variety: Different tree types, water colors, seasonal appearance per biome
- [ ] Biome difficulty: Mountain biome harder (cold, sparse resources), forest easier
- [ ] Resource distribution: Biome determines spawn rates for wood types, stone, ore
- [ ] Animal distribution: Each biome has unique huntable creatures (coast has seals, forest has deer)
- [ ] Forage diversity: Coastal forage ≠ Mountain forage (visual + gameplay variety)
- [ ] Biome transitions: Smooth transition zones between biomes (not sharp borders)
- [ ] Biome persistence: Same seed produces same biome layout (deterministic)

**Prerequisites:** Epic 1 complete (GPU validated) - Specifically Story 1.2 and 1.4

**Technical Notes from Architecture:**
- Biome assignment: Use regional Perlin noise (2D, large scale) + elevation to select biome
- Terrain types: Each biome has terrain_type mapped (e.g., forest_dense, forest_sparse)
- Visual variation: Use biome_definitions/*.tres to define sprite replacements per biome
- Resource spawn: BiomeGenerator.spawn_resources_for_chunk(biome_data, chunk_data)
- Transition zones: Linear interpolation between adjacent biome resources at boundaries

---

### Story 2.2: Water System - Rivers, Lakes & Hydrology

**As a** player,
**I want** procedurally generated rivers and lakes that affect navigation and provide water resources,
**So that** water becomes a strategic element of exploration and survival.

**Acceptance Criteria:**

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

**Prerequisites:** Story 2.1 - Biomes complete

**Technical Notes from Architecture:**
- Waterways integration: Use Waterways .NET addon to generate river networks from heightmap
- River routing: AStar pathfinding respects river barriers (player navigates around)
- Canoe mechanics: Canoe item allows fast travel on rivers (override normal movement speed)
- Water nodes: WaterTile objects placed in river/lake areas (not blocking terrain)
- Fishing integration: FishingSpots placed automatically on water bodies

---

### Story 2.3: Exploration & Navigation - Infinite Island World

**As a** player,
**I want** to explore an infinite procedurally generated island without loading screens,
**So that** discovery and navigation challenges drive gameplay.

**Acceptance Criteria:**

- [ ] World is bounded island (not infinite): Ocean surrounds playable area
- [ ] Island size: ~500×500 chunks recommended (16,000×16,000 units)
- [ ] Chunk loading: Chunks stream in/out seamlessly as player moves
- [ ] No loading screens: Transitions between chunks invisible (chunk loads before visible)
- [ ] Navigation challenges: Water barriers, mountains, dense forests require path planning
- [ ] POI discovery: Points of interest (NPC camps, resource-rich areas) scatter across world
- [ ] Map knowledge: Player must memorize locations (no minimap/quest markers)
- [ ] Procedural variation: Different regions have different challenges (mountain vs swamp navigation)
- [ ] Return navigation: Player can return to previously visited locations (landmarks, known paths)
- [ ] World boundaries: Ocean blocks further exploration (clear boundary)
- [ ] Fast travel: Settlement acts as fast travel point (optional post-launch feature)

**Prerequisites:** Story 2.1 & 2.2 - Biomes and water system

**Technical Notes from Architecture:**
- Chunk size: 32×32 units, total world = 16,000×16,000 (allows ~250,000 chunks if memory permits)
- Streaming radius: 3 chunks in each direction = 5×5 chunk grid visible
- Island bounds: Kill zone outside island boundary (water/cliffs push player back)
- POI spawning: Merchant camps, resource-rich forests placed deterministically via seed
- Memory: Streaming system keeps < 100 chunks in memory (aggressive unloading)

---

### Story 2.4: Seasonal System - Visual Indicators & Resource Variation

**As a** player,
**I want** visible seasonal changes and resource availability affected by season,
**So that** time progression adds strategic depth to exploration and planning.

**Acceptance Criteria:**

- [ ] Day/night cycle: 20 in-game minutes per day, visual lighting changes
- [ ] 4 seasons: Spring, Summer, Autumn, Winter cycle (7 in-game days each)
- [ ] Visual changes: Biome sprites change with season (colors, snow, leaf changes)
- [ ] Resource variation: Spring/Summer have more forage, Winter less
- [ ] Animal variation: Summer has more huntable animals, Winter fewer
- [ ] Temperature changes: Winter temperatures lower (requires more warmth)
- [ ] Seasonal UI: Calendar shows current season and day
- [ ] Seasonal warning: Notifications like "Winter is coming!" 7 days before
- [ ] Gameplay impact MVP: Visual-only (no mechanical impact except temperature)
- [ ] Post-launch expansion: Add food_availability tracking, crop growth cycles

**Prerequisites:** Story 2.1 - Biomes, Story 1.1 - Time system

**Technical Notes from Architecture:**
- Season tracking: Player.game_time tracks seconds, convert to season/day via math
- Sprite replacement: Use biome_definition + season to select sprite set for objects
- Spawn rate modifiers: BiomeGenerator multiplies spawn_rates by season_multiplier
- Temperature system: Base temperature adjusted by season (-5 in Winter, +5 in Summer)
- Calendar: Display in HUD showing Season + Day of Season

---

## Epic 3: Core Survival Loop

**Epic Goal:** Implement the core gameplay loop where players forage, hunt, fish, prepare food, and manage stamina/health/hunger through resource gathering and consumption. **Built on top of validated world generation from Epic 2.**

**Technical Context from Architecture:**
- Stamina system: 0-100, depletes from running/actions, recovers at rest
- Skills: 0-100 progression with diminishing returns
- Needs system: Hunger/Thirst/Warmth/Health/Morale with decay rates
- Resource gathering: Forage, hunt, fish interactions drain stamina
- Inventory: Dictionary-based item storage, lightweight Resources
- Food preparation: Recipe system with tool/fuel requirements

### Story 3.1: Player Character with Stamina & Health System

**As a** player,
**I want** stamina and health bars that deplete with activity and can be recovered through food/rest,
**So that** I must manage resources carefully to survive.

**Acceptance Criteria:**

- [ ] Player has Stamina (0-100) displayed in HUD
- [ ] Player has Health (0-100) displayed in HUD
- [ ] Player has Hunger (tracking food need) visible as decay rate
- [ ] Stamina depletes when running (1.5x speed multiplier, stamina cost: 0.5/sec)
- [ ] Stamina depletes when performing actions (interaction actions cost 5-20 stamina)
- [ ] Stamina recovers at rest (sleep system): +2 stamina/sec when in shelter resting
- [ ] Health depletes from starvation (1 health/10 mins when hunger > threshold)
- [ ] Health depletes from poison/bad food (15 health per poisoned meal)
- [ ] Food consumption replenishes stamina (varies by food type: 10-50 stamina)
- [ ] Health reaches 0 → character dies (triggers permadeath)
- [ ] HUD bars update in real-time with smooth animation

**Prerequisites:** Story 1.1 - Project setup

**Technical Notes from Architecture:**
- Stamina, Health, Hunger are properties on Player node
- Decay rates: hunger increases 0.1/sec (empty stomach in ~15 mins)
- Running: costs 0.5 stamina/sec, grants 1.5x movement speed
- Action costs: forage/dig = 5, chop = 10, fishing = 15 (stamina)
- Sleep requirement: player must sleep 8 hours per in-game day to recover stamina fully
- Integration: Needs system child node handles decay, Player node handles action costs

---

### Story 3.2: Foraging System - Gather Plants & Berries

**As a** player,
**I want** to gather edible plants, berries, and seeds from vegetation,
**So that** I have a renewable food source that doesn't require hunting equipment.

**Acceptance Criteria:**

- [ ] Forage nodes spawn in biomes based on biome_data (terrain_type + randomization)
- [ ] Player can interact with forage nodes (hold E + stamina check)
- [ ] Interaction shows random forage item (5-10 types: berries, mushrooms, roots, seeds, etc.)
- [ ] Items vary by biome: boreal biome has different forage than temperate
- [ ] Items vary by season: spring/summer have more plants, winter/fall have fewer
- [ ] Forage nodes deplete on interaction (respawn after 2 in-game days)
- [ ] Stamina cost: 5 per forage action
- [ ] Foraging fails if stamina < 5 (can't perform action)
- [ ] Items go into inventory with weight (berries: 0.2kg, mushrooms: 0.1kg)
- [ ] Tooltip/HUD shows forage item name and nutrition info on hover
- [ ] No tutorial: player must discover what's edible through trial and error (eat items to learn)

**Prerequisites:** Story 3.1 - Character stamina system, Story 2.1 - Biomes (object spawning)

**Technical Notes from Architecture:**
- Forage node types: ForageNode (extends WorldObject)
- Biome mapping: coastal has kelp, forest has mushrooms, mountains have rare herbs
- Season system: Affects spawn rate (winter = 30% of summer spawn chance)
- Respawn: Set is_modified=true on chunk when forage depleted, regenerate after time
- Inventory: Items as Resource "class_name FoodItem extends Resource" with nutritional_data
- Discovery: No in-game documentation; nutrition properties only reveal after consumption

---

### Story 3.3: Hunting System - Hunt Animals for Raw Meat

**As a** player,
**I want** to hunt animals (deer, moose, rabbits, birds) for meat,
**So that** I have a more challenging but rewarding food source requiring preparation.

**Acceptance Criteria:**

- [ ] Animal types defined: deer (common), moose (rare, high-value), rabbits (easy), birds (medium)
- [ ] Animals spawn in biomes based on biome_data (hunt_spawn_rates)
- [ ] Animals have AI: wander, flee from player, graze
- [ ] Player can hunt: chase animal until caught/died (no combat, just stamina race)
- [ ] Hunting requires: player stamina, animal health tracking (takes multiple hits or stamina > animal stamina)
- [ ] Successful hunt: animal dies, drops raw_meat (quantity varies: rabbit=1, deer=3, moose=5)
- [ ] Stamina cost: 15 per animal hunted (depletion + movement)
- [ ] Hunting fails: if player stamina depletes, animal escapes
- [ ] Animal locations vary by season: summer → more grazing animals, winter → animals scarce
- [ ] Each biome has unique animal set (coast has seals, forest has deer, boreal has moose)

**Prerequisites:** Story 3.1 - Stamina system, Story 2.1 - Biome spawning, creature AI

**Technical Notes from Architecture:**
- Animal node: AnimalBase (extends CharacterBody3D) with pathfinding using AStar
- AI states: Idle, Grazing, Alert, Fleeing, Dead
- Hunt mechanic: Reduce animal health via player proximity + stamina expenditure (stamina-based damage)
- Meat quality: depends on animal health at death (poorly-fed animals = worse meat)
- Respawn: Animals respawn at camp locations or wandering routes (not finite population)

---

### Story 3.4: Fishing System - Catch Fish in Water

**As a** player,
**I want** to fish in rivers and lakes using basic tools,
**So that** I have another renewable food source requiring patience and equipment.

**Acceptance Criteria:**

- [ ] Fishing nodes placed in water (rivers, lakes) based on water_system data
- [ ] Player can fish: interact with water + wait mechanic (5-30 sec catch time)
- [ ] Fishing requires: fishing_rod tool (can be basic stick or upgraded iron rod)
- [ ] Stamina cost: 1/sec while fishing (continuous drain, can stop anytime)
- [ ] Success rate: varies by rod quality (stick=50%, basic=70%, iron=90%) and fish abundance
- [ ] Catch: raw_fish items (1-3 per successful catch)
- [ ] Fail: stamina depleted, catch nothing (player can try again)
- [ ] Fish vary by biome: coastal has salt water fish, rivers have fresh water
- [ ] Fishing proficiency: Skill "fishing" increases catch rate (0-100, +2% per skill level)
- [ ] Catch notifications: "You caught a salmon!" when successful
- [ ] Basic fishing rod crafted from stick + vine (no tools needed)

**Prerequisites:** Story 3.1 - Stamina system, Story 2.2 - Water system

**Technical Notes from Architecture:**
- Fishing node: FishingSpot (extends Node3D) marked on water bodies
- Fish item: FoodItem subclass with fish_type property
- Rod tool: Equipment item with catch_bonus property (basic=0%, iron=40%)
- Skill system: Player.skills["fishing"] modified on successful catch (+1 XP per 10 catches until skill = 100)
- Wait mechanic: UI timer showing catch progress, cancelable with E key

---

### Story 3.5: Food Preparation Menu - Cook, Boil, Dry, Ferment

**As a** player,
**I want** to prepare food using different methods (cooking, boiling, drying, fermenting),
**So that** prepared food lasts longer and provides different nutritional benefits.

**Acceptance Criteria:**

- [ ] Food preparation menu accessible from inventory or at settlement fire
- [ ] Preparation methods: boil, cook, dry, ferment (each requires different tools)
- [ ] Boil: requires pot + fire, time: 2 mins, uses 5 fuel
- [ ] Cook: requires fire + stick/skewer, time: 1 min, uses 3 fuel
- [ ] Dry: requires drying_rack structure + 8 in-game hours, no fuel
- [ ] Ferment: requires fermentation_barrel structure + 2 in-game days, no fuel
- [ ] Tool requirements enforced: no cooking without fire, no drying without rack
- [ ] Menu shows: available items, preparation methods available, time/resource cost
- [ ] Upon completion: original food consumed, prepared version added to inventory
- [ ] Prepared food: different nutrition profile (some nutrients preserved, new properties added)
- [ ] Spoilage: prepared food lasts 2-7 in-game days before spoiling (varies by method)
- [ ] Advanced tools (steel pot, iron skewer): required for optimal nutrition (trade-only, can't craft)

**Prerequisites:** Story 3.2/3.3/3.4 - Raw food items

**Technical Notes from Architecture:**
- Recipe system: Dictionary format `{"recipe_id": {"requires": {...}, "produces": FoodItem}}`
- Cooking process: Create PreparedFood resource with nutrition modified from base
- Time tracking: Game calendar tracks in-game time, spoilage checked on consumption
- Fire requirement: Can only cook/boil at settlement fire or temporary campfire
- Advanced tools: NPCs trade for steel_pot, iron_skewer (can't craft with basic tools)
- Inventory: Items as Resources with prepare_methods[] property defining valid preparations

---

### Story 3.6: Food Consumption & Nutrition Management

**As a** player,
**I want** to eat food which replenishes stamina and provides nutrition,
**So that** I can prevent starvation and maintain health through balanced diet.

**Acceptance Criteria:**

- [ ] Inventory shows food items with eat action
- [ ] Eating consumes item and replenishes stamina (varies: 10-50 stamina based on food)
- [ ] Food provides nutrients: proteins, minerals, vitamins (tracked as properties)
- [ ] Different foods have different nutrition profiles (meat high protein, berries high vitamin, etc.)
- [ ] Side effects from poor nutrition: starvation (health loss), vitamin_deficiency (stamina regen reduced), food_poisoning (health loss + stamina drain)
- [ ] Eating poisoned food (spoiled, wrong preparation): -15 health + nausea state
- [ ] Nausea state: reduced stamina recovery, visual/audio feedback
- [ ] Notification on eat: "Ate salmon - gained X stamina, nutrition: protein, minerals"
- [ ] Malnutrition warning: "You need more protein/vitamins!" when deficiencies detected
- [ ] Food variety encourages: eating different foods unlocks nutrition variety bonus
- [ ] Starvation progression: First 1 hour (hunger>80), Health loses 1/min, visible warning HUD

**Prerequisites:** Story 3.2/3.3/3.4/3.5 - Food system, Story 3.1 - Health system

**Technical Notes from Architecture:**
- Food items: FoodItem resource with nutrition Dictionary: {protein: 10, vitamin: 5, mineral: 8}
- Consumption: Player.eat(food_item) updates stamina + health + nutritional_intake
- Nutritional tracking: Player maintains running_nutrition[] dict, tracks deficiency states
- Side effects: Create buff/debuff system (Nausea, VitaminDeficiency, etc.) with decay
- Poisoned detection: Based on food.is_spoiled or food.preparation_failed flags

---

## Epic 4: Fire & Shelter Management

**Epic Goal:** Implement settlement structures (fire pit, shelter, storage) that enable survival through warmth, rest, and resource management. **Built on top of core survival from Epic 3.**

**Technical Context from Architecture:**
- Settlement building: Player can place structures with resource requirements
- Structures persistent: survive permadeath, appear in new world
- Fire system: Requires fuel (wood, coal), provides warmth and cooking platform
- Shelter: Provides rest point, warmth during cold, enables sleep
- Storage: Inventory extension at settlement

### Story 4.1: Settlement Building - Construct & Maintain Structures

**As a** player,
**I want** to build basic structures (fire pit, shelter, storage) at my settlement,
**So that** I can rest, cook food, and store resources safely.

**Acceptance Criteria:**

- [ ] Settlement building menu accessible from inventory or hotkey
- [ ] Available structures: fire_pit, shelter, storage_bin, crafting_table
- [ ] Placement system: grid-based (same grid as terrain), snap-to-grid
- [ ] Collision detection: structures can't overlap terrain objects or each other
- [ ] Resource cost: Each structure requires materials (wood, stone, etc.)
- [ ] Fire pit: costs 10 wood, enables cooking/boiling
- [ ] Shelter: costs 20 wood + 10 cloth, enables sleep + warmth bonus
- [ ] Storage: costs 15 wood + 10 nails, expands inventory capacity
- [ ] Crafting table: costs 30 wood, enables crafting recipes
- [ ] Construction time: 10-30 seconds per structure (real time, can't cancel)
- [ ] Damage/repair: structures have health, can be damaged by weather, repaired with materials
- [ ] Persistence: completed structures remain across permadeath (saved in settlement data)

**Prerequisites:** Epic 3 complete - Core survival loop

**Technical Notes from Architecture:**
- Structure node: SettlementStructure (extends WorldObject) with health, owner, structure_type
- Placement validation: Check collision_shape overlaps, validate grid position within settlement zone
- Resource cost: Deduct from inventory before construction (fail if insufficient)
- Placement UI: Show ghost structure while hovering, turn green/red for valid/invalid
- Settlement persistence: Save settlement location + structures[] to settlement.tres Resource
- Chunk modification: Mark chunk as is_modified when structure added/removed

---

### Story 4.2: Fire System - Maintain Fire for Cooking & Warmth

**As a** player,
**I want** to maintain a fire at my settlement that provides warmth and enables cooking,
**So that** I can prepare food and survive cold weather.

**Acceptance Criteria:**

- [ ] Fire pit structure created (Story 4.1)
- [ ] Fire requires fuel: wood (burns 1 min per log), coal (burns 5 mins per coal)
- [ ] Player can add fuel: interact with fire pit + select fuel from inventory
- [ ] Fire state: On/Off, tracked as property on fire_pit object
- [ ] Fire provides warmth: +5 temperature modifier to player standing nearby (range: 3 units)
- [ ] Fire notification: "Fire is burning - 45 minutes of fuel remaining"
- [ ] Fire dies: Out of fuel → goes out, must be relit
- [ ] Fire visibility: Animated fire effect at night, dimmer during day
- [ ] Cooking at fire: Can only cook/boil when fire is lit (required for Story 3.5)
- [ ] Cold mechanic: Without fire/shelter, player loses warmth, stamina regen reduced
- [ ] Multiple fires: Multiple fire pits provide cumulative warmth (each +5)

**Prerequisites:** Story 4.1 - Settlement structures, Story 3.5 - Cooking system

**Technical Notes from Architecture:**
- Fire pit: Tracks fuel_remaining (float, decrements over time), is_lit (bool)
- Warmth system: Player.update_warmth() checks nearby fire_pits, calculates temperature_bonus
- Temperature: Player has temperature property (0-100), affects health/stamina
- Low temperature: temperature < 30 → stamina_regen reduced to 50%, health_loss 0.1/sec
- Fire animation: Sprite3D with animated_texture or particle_effect node
- Fuel consumption: Happens in _process(delta), tracks seconds elapsed

---

### Story 4.3: Shelter System - Rest, Sleep & Temperature Management

**As a** player,
**I want** to build a shelter and sleep to restore stamina and manage temperature,
**So that** I can survive long expeditions away from settlement.

**Acceptance Criteria:**

- [ ] Shelter structure created (Story 4.1)
- [ ] Shelter provides: warmth (+15 temperature), sleep point, rest bonus
- [ ] Sleep mechanic: Player can sleep in shelter (time acceleration 8x, heals stamina)
- [ ] Sleep duration: 8 in-game hours required for full recovery (10 real-time seconds)
- [ ] Sleep benefit: Stamina recovers at +10/sec while sleeping (vs +2/sec resting awake)
- [ ] Health recovery: +1 health/sec while sleeping (if warmth adequate)
- [ ] Weather protection: Inside shelter, weather (rain, snow) doesn't damage health
- [ ] Shelter quality: Basic shelter provides basic protection, advanced shelter better
- [ ] Multiple shelters: Player can build multiple shelters (each provides separate rest point)
- [ ] Poor sleep: If shelter in bad condition (health < 50%), sleep quality reduced (-50% recovery)
- [ ] Sleep requirement: Player must sleep or suffers stamina_regen reduction after 16 in-game hours awake
- [ ] Shelter persistence: Shelter survives permadeath, available in new world

**Prerequisites:** Story 4.1 - Settlement structures, Story 3.1 - Stamina system

**Technical Notes from Architecture:**
- Sleep mechanic: Enter shelter, press Rest button, time accelerates 8x, UI countdown shows time
- Sleep tracking: Player.hours_since_sleep counter increments, triggers warning at 14 hours
- Sleep exhaustion: After 16 hours awake, stamina_regen penalty -50% applies
- Temperature: Shelter interior = +15 bonus, stacks with fire pit (+5 each)
- Shelter UI: Shows "Time until fully rested: X minutes"

---

## Epic 5: Permadeath & World Persistence

**Epic Goal:** Implement permadeath mechanics where death triggers world reset but settlement structures persist, creating progression through accumulated knowledge and persistent infrastructure. **Built on top of complete survival loop from Epic 4.**

**Technical Context from Architecture:**
- Permadeath: Character death → unrecoverable, all inventory lost
- World reset: New world generated with different seed on respawn
- Settlement persistence: Settlement location randomized, structures preserved
- Respawn: Automatic at old settlement location in new world

### Story 5.1: Character Death Mechanics

**As a** player,
**I want** my character to die on starvation/poison/extreme cold,
**So that** failure has real consequences and forces careful resource management.

**Acceptance Criteria:**

- [ ] Death triggered when: health reaches 0 (from starvation, poison, cold)
- [ ] Death notification: Clear UI message "You have died! Cause: [starvation/poison/cold]"
- [ ] Inventory loss: All carried items are lost (nothing remains after death)
- [ ] Equipment loss: All worn equipment is lost
- [ ] Death recording: Record cause of death for player review
- [ ] Permadeath: Character is unrecoverable (can't undo or reload)
- [ ] Settlement access: Player can see what structures/items are at settlement before respawn
- [ ] Death count: Track total deaths (meta stat shown in main menu or summary)
- [ ] Respawn option: "Respawn at Settlement" button triggers new world generation

**Prerequisites:** Epic 4 complete - Core survival loop with permadeath trigger

**Technical Notes from Architecture:**
- Death check: Happens in Player._process() or health_system, checks health <= 0
- Death handler: Calls permadeath_system.handle_death(cause) which triggers world_reset flow
- Inventory wipe: Player.inventory.clear() before respawn
- Death stats: Store in meta-save (separate from world/character saves)

---

### Story 5.2: World Reset - Generate New World on Death

**As a** player,
**I want** a completely new procedurally generated world when I respawn,
**So that** each playthrough is unique and exploration remains challenging.

**Acceptance Criteria:**

- [ ] On death, new random seed generated (don't reuse previous world)
- [ ] New world generation starts (all chunks reset, previous chunks discarded)
- [ ] Chunk regeneration: Unmodified chunks regenerated from new seed
- [ ] Modified chunks: Settlement chunks loaded from persistence (not discarded)
- [ ] Old world is gone: Player cannot return to previous world
- [ ] Generation time: New world loads within 30 seconds
- [ ] Seed variety: Different seeds produce visibly different worlds (different biome layouts, water patterns, NPC locations)
- [ ] World seed stored: New seed persisted for save file

**Prerequisites:** Story 5.1 - Death mechanics, Story 1.5 - Seed system, Story 1.4 - Chunk system

**Technical Notes from Architecture:**
- Seed generation: `new_seed = random.next_uint32()`
- Chunk regeneration: ChunkManager.clear_all_chunks() then load from seed on next access
- Settlement chunks: Load from settlement.tres (preserved across deaths)
- Old world: Delete from user://saves/chunks/ or skip loading (implementation choice)
- Seed storage: Save new_seed to game_state.tres for next world load

---

### Story 5.3: Settlement Persistence - Structures Survive Permadeath

**As a** player,
**I want** my settlement structures to survive death and appear in the new world,
**So that** my progress isn't completely lost and I can rebuild faster on next life.

**Acceptance Criteria:**

- [ ] Settlement location randomized: Settlement appears at different location in new world
- [ ] Settlement structures preserved: All built structures transferred to new world
- [ ] Structure inventory preserved: Items stored in storage bins are preserved
- [ ] Settlement layout maintained: Relative positions of structures preserved (snapped to new grid)
- [ ] Structure condition preserved: Damaged structures remain damaged (or repaired as bonus)
- [ ] Settlement access: New character spawns at settlement location immediately
- [ ] First-life settlement: On new game, settlement appears at random starting location
- [ ] Respawn notification: "Welcome back! Your settlement has been recovered at [coordinates]"
- [ ] Multiple playthroughs: Settlement accumulates structures across many deaths (optional growth tracking)

**Prerequisites:** Story 4.1 - Settlement structures, Story 5.1 - Death mechanics, Story 5.2 - World reset

**Technical Notes from Architecture:**
- Settlement data: Resource format with structures[], location, inventory_items
- Location randomization: Place settlement at random valid location in new biome (avoid water/mountains)
- Structure transfer: Load settlement.tres, instantiate structure nodes at settlement
- Inventory preservation: StorageStructure.items[] persisted in settlement.tres
- Settlement object: SettlementManager tracks persistent settlement data across saves

---

### Story 5.4: Respawn Mechanics - Automatic Spawn at Settlement

**As a** player,
**I want** to respawn automatically at my settlement when I die,
**So that** I don't lose progress on settlement location and can resume survival.

**Acceptance Criteria:**

- [ ] On death: New world generated (Story 5.2)
- [ ] Respawn automatic: Player spawns at settlement without delay
- [ ] Spawn location: Settlement location set in game_state.tres loaded on new world
- [ ] New character: Fresh character spawned with no items (inventory empty)
- [ ] Starting inventory: Very basic starter items (stick, one piece of food)
- [ ] No respawn timer: Respawn happens immediately (no waiting mechanic)
- [ ] Respawn message: "You have been reborn at your settlement"
- [ ] Save point: Settlement acts as persistent save point (location persists across deaths)

**Prerequisites:** Story 4.1 - Settlement, Story 5.1-5.3 - Permadeath system

**Technical Notes from Architecture:**
- Respawn flow: death_handler → world_reset → load_settlement → spawn_player_at_settlement
- Spawn location: `player.position = settlement.position`
- Starting inventory: Hard-coded starting_items Resource loaded on new game
- No death cooldown: Immediate respawn (permadeath is consequence enough)

---

## Epic 6: NPC Trading System

**Epic Goal:** Implement simplified NPC merchants with individual trade requirements and reputation mechanics, creating economic progression loops where trade enables acquisition of complex tools required for survival. **Built on top of validated world from Epics 1-2.**

**Technical Context from Architecture:**
- Merchant system: NPCs simplified to merchants only (no combat, quests, complex dialogue)
- Trade economy: Each NPC has wants/offers lists, fair exchanges required
- Reputation: Simple Reputation system affects NPC interaction (0-100 per NPC)
- Pathfinding: NPCs use AStar with terrain speed modifiers for navigation
- Dialogue: Text-based, silent, trade-focused (no branching dialogue trees)

### Story 6.1: NPC Merchant System - Trading with NPCs

**As a** player,
**I want** to discover NPCs scattered across the world and trade items for tools I can't craft,
**So that** progression requires exploration and strategic trading chains.

**Acceptance Criteria:**

- [ ] 10+ NPCs placed in procedural world at trading_post locations
- [ ] NPC locations fixed (don't wander, stay at trading posts)
- [ ] NPCs discoverable: Player must explore to find them (no map markers)
- [ ] Each NPC has: wants[], offers[], trade_multiples (fair exchange calculation)
- [ ] Trade interface: Show NPC wants/offers, select items from inventory, confirm trade
- [ ] Fair exchanges: Trading system prevents unfair trades (player can't scam NPCs)
- [ ] Trade completeness: All essential items obtainable through trade chains
- [ ] NPC dialogue: Text-based greeting + trade options (no branching)
- [ ] Trade history: Record successful trades (optional UI showing what was traded)
- [ ] NPC persistence: Same NPC locations across saves (seed-based placement)
- [ ] Complex tools: Steel pots, iron tools, muskets only available through trade (not craftable)

**Prerequisites:** Epic 2 complete - World generation (NPC placement), Epic 3 complete - Survival loop (requires complex tools)

**Technical Notes from Architecture:**
- Merchant node: Merchant (extends Node3D) with trades[] array
- Trade structure: `{wants: {item_id: quantity}, offers: {item_id: quantity}, fair_rate: 1.0}`
- NPC placement: Deterministic via seed + biome (always same location for same seed)
- Trade validation: Check inventory has all wants items, check fair_rate (player can't cheat)
- NPC AI: Merchant stands at trading_post, greets approaching player, offers trade UI

---

### Story 6.2: Reputation System - Actions Affect NPC Relations

**As a** player,
**I want** my actions to affect NPC reputation and relationships,
**So that** social mechanics add depth beyond simple trading.

**Acceptance Criteria:**

- [ ] Reputation tracking: Each NPC/tribal_group has reputation (0-100)
- [ ] Reputation actions: Successful trades increase reputation (+5), theft decreases (-50)
- [ ] Reputation effects: High reputation unlocks better trade terms (future expansion)
- [ ] Reputation display: Show current reputation with NPC on trade screen
- [ ] Reputation persistence: Reputation saved with game, persists across saves
- [ ] No permanent locks: All NPCs remain accessible (no permadeath-like NPC locks)
- [ ] Reputation notifications: "NPC relationship improved!" when reputation increases
- [ ] Reputation reset: New world = reset reputation (all at 50 baseline)
- [ ] Tribal reputation: Tribes have collective reputation (shared among tribe members)
- [ ] Future expansion: Reputation could unlock unique traders, special items, discounts

**Prerequisites:** Story 6.1 - NPC trading system

**Technical Notes from Architecture:**
- Reputation tracking: Player.reputation = {npc_id: value} Dictionary
- Reputation changes: On successful trade, increment reputation (for future use)
- Reputation persistence: Save in game_state.tres
- NPC grouping: Tribal groups have shared reputation (NPCs in same tribe are related)

---

### Story 6.3: Trade Chains - Unlock Tool Progression Through Trading

**As a** player,
**I want** complex tools (steel pots, iron tools, advanced fishing equipment) to be obtainable only through NPC trading,
**So that** trading becomes essential progression mechanic, not optional convenience.

**Acceptance Criteria:**

- [ ] Trade chains designed: Verify all essential tools obtainable through trading
- [ ] Example chain: Basic tools → trade for furs → trade furs for steel pot → cook complex meals
- [ ] Multiple paths: Multiple NPCs have overlapping trades (alternative paths)
- [ ] No dead ends: Every trade chain completes (no impossible locks)
- [ ] Early access tools: Basic tools available at game start or easy to craft
- [ ] Mid-tier tools: Require single trade with nearby NPC
- [ ] Late-tier tools: Require multi-step trade chain or rare items
- [ ] Tool quality: Advanced tools provide better crafting results/faster preparation
- [ ] Trade balance: No single trade too powerful or trivial
- [ ] Documentation: Trade requirements documented for testing/balance

**Prerequisites:** Story 6.1 - NPC system, Story 3.5 - Food preparation

**Technical Notes from Architecture:**
- Trade chain design: Document all NPC wants/offers in spreadsheet, verify connectivity
- Essential items: Steel pots (cooking), iron tools (gathering), muskets (future combat)
- Trade validation: Graph analysis to verify no isolated items, all items have acquisition path
- Crafting limits: Basic tools craftable from sticks/stones, advanced tools trade-only

---

## Epic 7: UI & Game Support Systems

**Epic Goal:** Implement user interface, HUD, save/load system, and audio that complete the survival experience with intuitive interaction and persistent world management. **Final polish across all systems.**

**Technical Context from Architecture:**
- HUD: Minimal (stamina, health, time, season)
- Menus: Inventory, food prep, trading, settlement building
- Save system: Auto-save + manual save, one slot per character
- Audio: Background music (context-sensitive), sound effects, text-based dialogue

### Story 7.1: Minimal HUD - Display Essential Information

**As a** player,
**I want** a minimal heads-up display showing only essential survival stats,
**So that** immersion isn't broken by excessive UI elements.

**Acceptance Criteria:**

- [ ] Stamina bar: Upper left, green bar showing current/max stamina
- [ ] Health bar: Upper left below stamina, red bar showing current/max health
- [ ] Hunger indicator: Visual representation of hunger level (numeric or bar)
- [ ] Time display: Upper right, shows current time of day (clock or text)
- [ ] Season display: Upper right below time, shows current season
- [ ] No quest markers: No objectives, markers, or guided UI
- [ ] No minimap: No map or radar display
- [ ] No tutorials: No help text or tutorial overlays
- [ ] Context tooltips: Brief tooltips only when hovering over interactive objects
- [ ] HUD opacity: Slightly transparent so it doesn't block view
- [ ] Fullscreen mode: HUD remains visible even in fullscreen
- [ ] Accessibility: Font large enough for readability (tested on 1080p+)

**Prerequisites:** Epic 3 complete - Stamina/health system, Epic 2 complete - Time/season system

**Technical Notes from Architecture:**
- HUD node: HUD.gd extends CanvasLayer (always on top)
- Stamina display: TextureProgressBar with gradient color (green→yellow→red)
- Bar updates: Connected to Player.stamina signal, updates in real-time
- Time display: Calculate from game_time (seconds → hour:minute format)
- Season display: Text showing spring/summer/autumn/winter

---

### Story 7.2: Inventory System - Item Management & Capacity

**As a** player,
**I want** to manage inventory with item organization and capacity limits,
**So that** resource management decisions matter and carrying capacity is strategic.

**Acceptance Criteria:**

- [ ] Inventory screen: Accessible via 'I' key or menu button
- [ ] Item display: Lists carried items with quantities and weight
- [ ] Capacity tracking: Shows current weight / max capacity
- [ ] Item management: Drop, move, use items from inventory
- [ ] Equipment slots: Display equipped items (if equipped items system used)
- [ ] Item search: Filter/search by item name (post-MVP feature)
- [ ] Sorting: Sort by type, weight, name
- [ ] Item details: Hover shows description, nutrition, weight
- [ ] Carry limit: Can't carry more than capacity (attempt shows "Inventory full!")
- [ ] Capacity expansion: Storage structures increase max capacity
- [ ] Durability display: Show durability/condition of tools (optional post-MVP)

**Prerequisites:** Epic 3 - Item system, Story 4.1 - Storage structures

**Technical Notes from Architecture:**
- Inventory UI: InventoryUI.gd extends Control (shows inventory panel)
- Item data: Items as lightweight Resources with weight, name, icon properties
- Capacity calculation: Player.inventory_weight = sum(item.weight * quantity)
- Max capacity: Player.max_inventory_weight (default 20kg, increased by storage structures)
- Drop mechanic: Remove item from inventory, instantiate WorldItem at player position

---

### Story 7.3: Food Preparation Menu - Interactive Cooking System

**As a** player,
**I want** a dedicated food preparation interface showing available methods, times, and requirements,
**So that** cooking becomes intuitive and strategic.

**Acceptance Criteria:**

- [ ] Menu accessible: From inventory or hotkey near fire/structures
- [ ] Item list: Shows available raw food items to prepare
- [ ] Method display: Shows available preparation methods (boil, cook, dry, ferment)
- [ ] Cost display: Shows time, fuel, and tool requirements for each method
- [ ] Availability check: Greyed out methods if requirements not met (no fire, no pot)
- [ ] Recipe preview: Show resulting prepared food item and nutrition
- [ ] Time estimate: Display preparation time for selected method
- [ ] Start cooking: Select item + method, confirm to start
- [ ] Progress bar: Show cooking progress with time remaining
- [ ] Completion notification: "Food is ready!" when done
- [ ] Multiple items: Can queue multiple cooking items in succession

**Prerequisites:** Story 3.5 - Food preparation system

**Technical Notes from Architecture:**
- Menu UI: FoodPrepMenu.gd extends Control, shows food_prep_ui.tscn
- Item filtering: Only show raw food items (filter by food_type property)
- Method availability: Check for required_tool in inventory, check fire presence
- Preparation queue: Array of pending_prep_items in player state
- Progress UI: Show progress bar with time remaining, animated

---

### Story 7.4: Trading Interface - Simple Trade Negotiation

**As a** player,
**I want** a clear trading interface showing what an NPC wants and offers,
**So that** trades can be executed without confusion.

**Acceptance Criteria:**

- [ ] Trade screen: Opens when interacting with merchant
- [ ] NPC info: Show merchant name and description
- [ ] Wants list: Display items NPC wants with quantities
- [ ] Offers list: Display items NPC offers with quantities
- [ ] Inventory preview: Show player inventory items available for trade
- [ ] Selection: Click/drag items from inventory to trade slots
- [ ] Fair trade validation: Show "Fair trade" or "Unfair!" based on NPC rates
- [ ] Trade button: Confirm trade if fair (disabled if unfair)
- [ ] Confirmation: "Are you sure?" before trading
- [ ] Trade history: Optional log showing past trades with this NPC
- [ ] Multiple trades: NPC can have multiple independent trades available

**Prerequisites:** Story 6.1 - NPC trading system

**Technical Notes from Architecture:**
- Trade UI: TradeUI.gd extends Control, shows trade_ui.tscn
- Trade validation: Calculate fair_value for both sides, compare ratios
- Item slots: DragDrop system for moving items between player/trade slots
- Trade execution: On confirm, transfer items and reputation update

---

### Story 7.5: Save & Load System - Persistent Game State

**As a** player,
**I want** to save my progress and load previous saves,
**So that** I don't lose progress and can take breaks between sessions.

**Acceptance Criteria:**

- [ ] Auto-save: Game saves automatically when at settlement (every 5 minutes)
- [ ] Manual save: Player can save manually via menu
- [ ] Save location: user://saves/character_X.tres
- [ ] Save data includes: Character state, inventory, settlement location, reputation, world seed
- [ ] Load game: Load button in main menu shows character history
- [ ] Save slots: One active save per character (overwrites on new save)
- [ ] Playtime tracking: Track total playtime in save file
- [ ] Permadeath record: Track deaths and death causes
- [ ] Corruption check: Validate save file on load (error if corrupted)
- [ ] No manual deletion: Saves are permanent (to prevent game resets)

**Prerequisites:** All systems (integrated save system)

**Technical Notes from Architecture:**
- Save file: GameState resource with character[], settlement[], world_seed, playtime
- Auto-save trigger: Called every 300 seconds or on settlement entry
- Resource format: Use ResourceSaver/ResourceLoader for .tres format
- Encryption: Optional post-launch (MVP: plain text saves)
- Version tracking: Save file version for future compatibility

---

### Story 7.6: Background Music & Sound Effects

**As a** player,
**I want** immersive background music and sound effects that respond to gameplay,
**So that** audio reinforces atmosphere and provides feedback.

**Acceptance Criteria:**

- [ ] Background music: 5-10 tracks in folk/17th-century style
- [ ] Context-sensitive music: Different tracks for settlement vs exploration vs danger
- [ ] Music transitions: Smooth fades between tracks
- [ ] Volume control: Master volume + music/sfx sliders in settings
- [ ] Looping: Music loops seamlessly without silence gaps
- [ ] Sound effects: Environmental (wind, water, fire), action (chop, cook, build)
- [ ] Audio feedback: Action sounds play on successful interaction
- [ ] Distance audio: Sounds fade with distance (only nearby sounds audible)
- [ ] No intrusive audio: Music/sfx don't override critical information
- [ ] Mute option: Option to mute music/sfx individually
- [ ] No audio-critical mechanics: No information requires audio-only (all visual alternatives)

**Prerequisites:** None (can be added throughout development)

**Technical Notes from Architecture:**
- Music system: MusicManager.gd manages background track playback
- Tracks: Audio files in assets/music/ folder (Suno AI generated)
- Context switching: Change music based on current_biome and player_state
- Sound effects: Library of short audio clips (< 1 sec) for actions
- Spatial audio: Use AudioStreamPlayer3D for distance-based volume

---

## FR Coverage Matrix

| Functional Requirement | Epic | Story | Implementation Status |
|----------------------|------|-------|----------------------|
| F1.1: Foraging | 3 | 3.2 | Implemented |
| F1.2: Hunting | 3 | 3.3 | Implemented |
| F1.3: Food Preparation | 3 | 3.5 | Implemented |
| F1.4: Food Consumption | 3 | 3.6 | Implemented |
| F1.5: Fire & Shelter | 4 | 4.2, 4.3 | Implemented |
| F1.6: Settlement Building | 4 | 4.1 | Implemented |
| F2.1: Character Death | 5 | 5.1 | Implemented |
| F2.2: World Reset | 5 | 5.2 | Implemented |
| F2.3: Settlement Persistence | 5 | 5.3 | Implemented |
| F2.4: Respawn Mechanics | 5 | 5.4 | Implemented |
| F3.1: NPC Discovery | 6 | 6.1 | Implemented |
| F3.2: NPC Trade Mechanics | 6 | 6.1 | Implemented |
| F3.3: NPC Reputation | 6 | 6.2 | Implemented |
| F3.4: Required NPC Trades | 6 | 6.3 | Implemented |
| F4.1: Procedural Terrain | 1 & 2 | 1.2, 2.1 | Implemented |
| F4.2: Biome System | 2 | 2.1 | Implemented |
| F4.3: Water System | 2 | 2.2 | Implemented |
| F4.4: NPC Location Generation | 2 | 2.1 | Implemented |
| F5.1: Character Attributes | 3 | 3.1 | Implemented |
| F5.2: Character Progression | 3 | 3.1 | Implemented |
| F5.3: Equipment System | 3 & 7 | 3.1, 7.2 | Implemented |
| F6.1: Day/Night Cycle | 2 | 2.4 | Implemented |
| F6.2: Seasonal System | 2 | 2.4 | Implemented |
| F6.3: Weather System | 2 | 2.4 | Implemented |
| F7.1: Inventory Screen | 7 | 7.2 | Implemented |
| F7.2: Food Preparation Menu | 7 | 7.3 | Implemented |
| F7.3: Trading Interface | 7 | 7.4 | Implemented |
| F7.4: Settlement Building Menu | 7 | 4.1 | Implemented |
| F7.5: Minimal HUD | 7 | 7.1 | Implemented |
| F8.1: Save Data | 7 | 7.5 | Implemented |
| F8.2: Save Mechanics | 7 | 7.5 | Implemented |
| F8.3: Load Mechanics | 7 | 7.5 | Implemented |
| F9.1: Music | 7 | 7.6 | Implemented |
| F9.2: Sound Effects | 7 | 7.6 | Implemented |
| F9.3: Dialogue | 6 | 6.1 | Implemented |
| F9.4: Accessibility | 7 | 7.6 | Implemented |

**Coverage Summary:** ✅ **34/34 functional requirements covered**

---

## Implementation Sequence Summary

### Phase 1: Foundation & Validation (Must Complete Before Phase 2)
- **Epic 1: Foundation & GPU Validation** (5 stories) - ⚠️ **CRITICAL PATH**
  - Project setup, GPU compute shader validation, grid system, chunk manager, seed system
  - **Validation Gate:** GPU shader must be proven to work deterministically before proceeding

### Phase 2: World Generation (Depends on Phase 1)
- **Epic 2: Procedural World Generation** (4 stories)
  - Biomes, water system, exploration, seasons

### Phase 3: Core Gameplay (Depends on Phases 1-2)
- **Epic 3: Core Survival Loop** (6 stories)
- **Epic 4: Fire & Shelter Management** (3 stories)
- **Epic 5: Permadeath & World Persistence** (4 stories)

### Phase 4: Final Systems (Depends on Phases 1-3)
- **Epic 6: NPC Trading System** (3 stories)
- **Epic 7: UI & Game Support Systems** (6 stories)

---

## Summary

This epic breakdown transforms the Harsh World PRD into **7 epics with 31 implementation-ready stories** organized by true dependency order, with **GPU validation as the critical first step before world generation**.

### Total Stories: 31
- Epic 1 (Foundation & GPU): 5 stories
- Epic 2 (World Generation): 4 stories
- Epic 3 (Survival Loop): 6 stories
- Epic 4 (Fire & Shelter): 3 stories
- Epic 5 (Permadeath): 4 stories
- Epic 6 (NPC Trading): 3 stories
- Epic 7 (UI & Support): 6 stories

### Key Architecture Integration:
- All stories reference specific Architecture decisions (GPU compute shaders, chunk system, stamina mechanics, etc.)
- Technical patterns documented for each story (RenderingDevice API, ChunkData structure, NPC dialogue system)
- Tool requirements enforced (complex tools trade-only, basic tools craftable)
- All FR requirements from PRD are covered with complete acceptance criteria
- **Critical validation point:** GPU compute shader must be proven working before proceeding to world generation

### Next Steps:
Each story is ready for development implementation using the `create-story` workflow to generate individual developer context documents with full technical guidance.

---

_Created: 2025-12-03 | Status: Ready for Sprint Planning and Development | Level: MVP Early Access Implementation_

_Use the `sprint-planning` workflow to create sprint-status tracking and organize these epics into development phases._
