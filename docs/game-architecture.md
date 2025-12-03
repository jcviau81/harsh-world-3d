# Harsh World - Game Architecture Document

## Executive Summary

Harsh World is a deterministic, GPU-exclusive 2D survival RPG built with Godot 4.x 3D Engine. The architecture leverages GPU compute shaders for procedural terrain generation, uses a chunk-based infinite world system with persistent delta storage, and implements simplified social mechanics with merchants and reputation tracking. The game runs on modest GPU/APU hardware and features navigable water systems for canoe exploration.

## Project Initialization

**Engine Setup:**
```bash
godot --version  # Requires: Godot 4.x
# Project created with:
# - Godot 4.x 3D Engine
# - GDScript
# - GLSL/WGSL compute shaders
```

**Required Godot Addons:**
- [Waterways .NET](https://godotengine.org/asset-library/asset/2607) - River and water system generation
- [Open World Database (OWDB)](https://godotengine.org/asset-library/asset/4166) - Chunk streaming and world persistence (or custom lightweight implementation)

## Decision Summary

| Category | Decision | Version | Rationale | Affects |
| -------- | -------- | ------- | --------- | ------- |
| **GPU Pipeline** | RenderingDevice API + GLSL Compute Shaders | 4.x | Godot 4.x native RenderingDevice for GPU compute; manual buffer management; deterministic generation | Terrain heightmap, noise, biome distribution |
| **World Generation** | Deterministic seed-based chunking (Minecraft-style) | 1.0 | Allows reproducible world generation, chunk caching for performance, and selective delta storage | Core gameplay loop |
| **Chunk System** | Chunk size configurable (32×32 recommended, 64×64+ tunable); streaming radius configurable; tuned per target performance | 1.0 | Balance between detail and performance; 32×32 conservative, 64×64+ for more visual density; empirical testing determines optimal size | World generation, rendering, persistence |
| **Persistence** | Full-chunk saves (Resource format); only modified chunks written to disk; regenerate unmodified chunks from seed | 4.x | Simple, reliable; player modifications (tree chops, structures) persist in modified chunks; reduced disk footprint | Save/load system |
| **Water System** | Waterways .NET plugin + navigable river networks for canoe mechanics | 2.x | DEM-based flow accumulation; classifies water bodies (creek/stream/river/lake); deterministic hydrology | Hydrology, exploration, gameplay |
| **Biome System** | Regional noise-based biomes with terrain_types, movement_speed, and resource spawning (Necesse-style) | 1.0 | 7 primary biomes, 2-3 terrain_types each; feature layers spawn across regions; resources vary by terrain | World generation, exploration, resource gathering |
| **Rendering Grid** | Node-based world objects (Sprite3D + CollisionShape3D) instead of GridMap; objects placed on 32×32 grid positions | 4.x | Individual nodes for each world object (trees, rocks, structures); native Godot physics and interaction | Object placement, collision layers/masks, interaction |
| **Pathfinding** | AStar 2D/3D based on grid cells + water-aware routing | 4.x | Native Godot support; integrates with grid system | NPC movement, creature behavior |
| **Social/NPC** | Simplified: Merchants (NPCs) + Reputation system only | 1.0 | Reduces scope complexity; merchants enable trade loops; reputation affects NPC interactions | Player progression, economy |
| **Player Movement** | CharacterBody3D with velocity-based movement; 4-direction sprite animation (6-frame walk cycles); terrain speed modifiers | 4.x | Smooth continuous movement; animation syncs with velocity; terrain affects speed (0.3-1.0 multiplier) | Core gameplay loop |
| **Interaction System** | Hold-E interaction (contextual: Chop/Dig/Pickup); proximity-based detection; stamina cost per action | 1.0 | Simple input (hold E); actions drain stamina proportional to difficulty; resource gathering integrated | Resource gathering, survival |
| **Stamina/Energy System** | Stamina 0-100; depletes from running, interaction actions, negative health; recovers at rest; affects movement_speed, interaction_speed, health_regen | 1.0 | Core survival mechanic; running multiplier 1.5x, terrain+stamina compound effects; low stamina = slow movement | Core gameplay loop |
| **Skill Progression** | Skill = Dictionary entry (0-100), XP-based with diminishing returns: `gain × (1 - current_skill/100)` | 1.0 | Simple Resource pattern; separates skill logic from character | Player progression, survival |
| **Survival Mechanics** | NeedsSystem as Player child Node; Hunger/Thirst/Warmth/Health/Morale with decay_rates; stamina affects regen | 1.0 | Standard Godot pattern; decay rates adjust for environment and stamina state | Core gameplay loop |
| **Inventory System** | Items as lightweight Resources; inventory as Dict `{"item_id": quantity}` | 1.0 | Minimal overhead; easily persisted; separates data from UI | Crafting, trading, persistence |
| **Crafting** | Simple recipe Dict: `{"recipe_id": {"requires": {...}, "produces": "item"}}` | 1.0 | MVP-focused; extensible to skill-based crafting later | Resource gathering, economy |
| **NPC Dialogue** | Merchants only: No branching dialogue tree; simple trade interface (yes/no + list trades) | 1.0 | Reduces scope; trades driven by `trades[]` array on Merchant class | Social mechanics |

## Project Structure

```
harsh-world-3d/
├── src/
│   ├── core/
│   │   ├── world/
│   │   │   ├── chunk_manager.gd         # Handles chunk loading/unloading
│   │   │   ├── chunk_generator.gd       # GPU-based terrain generation
│   │   │   ├── world_seed.gd            # Seed management & determinism
│   │   │   ├── biome_generator.gd       # Biome assignment + resource spawning
│   │   │   └── persistence.gd           # Save/load chunk system
│   │   ├── water/
│   │   │   ├── water_system.gd          # Waterways integration
│   │   │   ├── river_network.gd         # River generation & navigation
│   │   │   └── water_mechanics.gd       # Canoe, ford, crossing logic
│   │   ├── rendering/
│   │   │   ├── sprite_renderer.gd       # 2D sprite in 3D space (Sprite3D + CollisionShape3D)
│   │   │   ├── world_object.gd          # Base class for trees, rocks, structures
│   │   │   ├── chunk_loader.gd          # Instantiates objects from chunk data
│   │   │   └── camera_controller.gd     # Smooth camera follow (Don't Starve style)
│   │   └── survival/
│   │       ├── needs_system.gd          # Hunger, thirst, warmth, morale
│   │       ├── skills_system.gd         # 0-100 progression
│   │       └── resource_gathering.gd    # Hunting, fishing, foraging
│   ├── gameplay/
│   │   ├── player/
│   │   │   ├── player.gd                # CharacterBody3D controller + stamina
│   │   │   ├── interaction_manager.gd   # Hold-E interaction system
│   │   │   ├── inventory.gd             # Inventory management
│   │   │   └── character_state.gd       # Stats, skills, health
│   │   ├── npcs/
│   │   │   ├── npc_base.gd              # Base NPC class
│   │   │   ├── merchant.gd              # Merchant behavior
│   │   │   ├── reputation_system.gd     # Reputation tracking
│   │   │   └── dialogue.gd              # NPC dialogue framework
│   │   └── quest/
│   │       └── quest_system.gd          # Quest management
│   ├── shaders/
│   │   ├── terrain_generation.glsl      # Compute shader: heightmap
│   │   ├── noise.glsl                   # Perlin noise implementation
│   │   ├── biome_blending.glsl          # Biome shader blending
│   │   ├── water_flow.glsl              # Water flow simulation
│   │   └── sprite_rendering.glsl        # Sprite visual effects
│   └── ui/
│       ├── hud.gd                       # HUD elements
│       ├── inventory_ui.gd              # Inventory interface
│       └── dialogue_ui.gd               # Dialogue display
├── assets/
│   ├── sprites/
│   │   ├── characters/
│   │   ├── objects/
│   │   │   ├── trees/ (maple, birch, pine, willow, poplar, etc.)
│   │   │   ├── rocks/
│   │   │   └── resources/ (fish, ore, plants, etc.)
│   │   └── ui/
│   ├── biome_definitions/
│   │   ├── coastal_atlantic.tres
│   │   ├── temperate_forest.tres
│   │   ├── deciduous_forest.tres
│   │   ├── grasslands.tres
│   │   ├── appalachian_mountains.tres
│   │   ├── boreal_forest.tres
│   │   └── wetlands.tres
│   ├── sounds/
│   └── music/
├── scenes/
│   ├── world/
│   │   ├── world.tscn                   # Main world scene
│   │   ├── chunk.tscn                   # Chunk template
│   │   └── poi.tscn                     # Point of interest template
│   ├── player/
│   │   └── player.tscn
│   └── ui/
│       └── main_ui.tscn
├── tests/
│   ├── test_chunk_generation.gd
│   ├── test_water_system.gd
│   └── test_persistence.gd
├── saves/
│   └── player_saves/                    # Save file directory
├── godot.project
└── README.md
```

## Epic to Architecture Mapping

| Epic | Components | Location | Phase |
| ---- | ---------- | -------- | ----- |
| **Core Prototype** | Engine setup, GPU terrain, grid system, sprite rendering | `src/core/rendering`, `src/shaders` | 1 |
| **Survival System** | Needs management, resource gathering | `src/core/survival` | 2 |
| **Hydrology** | Water generation, rivers, fishing, canoe mechanics | `src/core/water` | 2 |
| **Skill Progression** | 0-100 skill system, mastery bonuses | `src/gameplay/player` | 2 |
| **Social & NPCs** | Merchants, reputation system | `src/gameplay/npcs` | 2 |
| **World Exploration** | Infinite generation, POI placement, navigation | `src/core/world` | 3 |
| **Settlements** | Settlement systems, water dependency | `src/core/world` | 3 |
| **Polish & Content** | Balance, optimization, bug fixes | All | 4 |

## Technology Stack Details

### Core Technologies

| Technology | Version | Purpose | Notes |
| ---------- | ------- | ------- | ----- |
| **Godot Engine** | 4.x | Game engine | 3D engine, used in hybrid 2D/3D mode |
| **GDScript** | 4.x | Game logic | Primary scripting language |
| **GLSL / WGSL** | Latest | GPU compute shaders | Terrain, noise, water flow - GPU exclusive |
| **Waterways .NET** | 2.x | Water system | River generation, navigation data |
| **Open World Database** | Latest | World streaming | Chunk management and persistence |

### Integration Points

- **RenderingDevice → Compute Pipeline:** GLSL compute shaders generate heightmaps via RenderingDevice API → returned to CPU as texture/buffer data
- **Heightmap → Biome Generation:** Heightmap elevation → biome selection via regional noise → terrain_type assignment per tile
- **Biome → Resource Spawning:** Terrain_type → resource spawn chances → per-tile resource placement (wood, stone, ore, etc.)
- **Waterways → Hydrology:** DEM from heightmap → flow accumulation calculation → water body classification (creek/stream/river/lake)
- **Biome + Waterways → World Objects:** Terrain + water data → spawn trees/rocks/structures as individual Node3D objects with Sprite3D + CollisionShape3D
- **Node-based Objects → Physics:** Each world object has collision layer/mask → player/NPC movement respects collisions
- **Pathfinding:** AStar 2D/3D respects terrain movement_speed and water barriers → NPC navigation

### RenderingDevice Implementation Pattern

**Godot 4.x RenderingDevice workflow:**

```gdscript
# Compile shader
var rd: RenderingDevice = RenderingServer.create_local_rendering_device()
var shader_source = preload("res://src/shaders/terrain_generation.glsl")
var shader_bytecode = shader_source.get_spirv()
var shader = rd.shader_create_from_spirv(shader_bytecode)

# Create compute pipeline
var pipeline = rd.compute_pipeline_create(shader)

# Allocate GPU buffers
var input_buffer = rd.storage_buffer_create(input_data.size(), input_data)
var output_buffer = rd.storage_buffer_create(output_size)

# Execute compute dispatch
var compute_list = rd.compute_list_begin()
rd.compute_list_bind_compute_pipeline(compute_list, pipeline)
rd.compute_list_bind_uniform_set(compute_list, uniform_set, 0)
rd.compute_list_dispatch(compute_list, groups_x, groups_y, groups_z)
rd.compute_list_end()

# Read results back to CPU
var result = rd.buffer_get_data(output_buffer)
```

**Key constraints:**
- Results must be read back from GPU (synchronous call = pipeline stall)
- One dispatch per chunk generation recommended
- Cache results aggressively (deterministic = can reuse)

### World Modification & Persistence Pattern

**ChunkData tracks modifications:**

```gdscript
class_name ChunkData
extends Resource

@export var chunk_x: int
@export var chunk_y: int
@export var seed: int
@export var is_modified: bool = false  # Flag for selective saving

@export var heightmap: PackedFloat32Array  # Base generation
@export var biome_map: PackedByteArray
@export var objects: Array[Dictionary]  # Mutable objects on chunk
    # Example: [
    #   {pos: Vector3(5,0,5), type: "tree", hp: 100},
    #   {pos: Vector3(10,0,8), type: "rock", hp: 50},
    #   {pos: Vector3(15,0,3), type: "player_structure", owner: "player"}
    # ]

func remove_object(world_pos: Vector3):
    var local_pos = world_pos - Vector3(chunk_x * 32, 0, chunk_y * 32)
    objects = objects.filter(func(obj): return obj.pos != local_pos)
    is_modified = true

func add_object(world_pos: Vector3, obj_type: String, data: Dictionary = {}):
    var local_pos = world_pos - Vector3(chunk_x * 32, 0, chunk_y * 32)
    objects.append({pos: local_pos, type: obj_type}.merge(data))
    is_modified = true
```

**ChunkManager save/load:**

```gdscript
func save_chunk(chunk: ChunkData):
    if not chunk.is_modified:
        return  # Don't save unmodified chunks

    var path = "user://saves/chunks/%d_%d.tres" % [chunk.chunk_x, chunk.chunk_y]
    ResourceSaver.save(chunk, path)

func load_or_generate_chunk(x: int, y: int) -> ChunkData:
    var path = "user://saves/chunks/%d_%d.tres" % [x, y]

    # Try load modified chunk
    if ResourceLoader.exists(path):
        return ResourceLoader.load(path)

    # Otherwise generate from seed
    return _generate_chunk(x, y)
```

**Workflow for player action (chop tree):**
1. Player clicks on tree → `RayCast3D` detects tree object
2. Call `chunk.remove_object(tree_pos)` → chunk marked `is_modified = true`
3. On next save checkpoint → `chunk_manager.save_chunk()` writes to disk
4. On load → system loads modified chunk (has tree removed)

## Implementation Patterns

### Naming Conventions

**Files & Folders:**
- Scripts: `snake_case.gd` (e.g., `chunk_manager.gd`)
- Scenes: `PascalCase.tscn` (e.g., `Player.tscn`, `Chunk.tscn`)
- Shaders: `descriptive_name.glsl` (e.g., `terrain_generation.glsl`)
- Assets: Category/`descriptive_name` (e.g., `sprites/characters/player_idle.png`)

**Godot Nodes:**
- Scene nodes: PascalCase (Player, Enemy, Chunk)
- Internal nodes: snake_case (collision_shape, sprite, audio)

**GDScript Classes & Functions:**
- Classes: `PascalCase` (Player, ChunkManager, WaterSystem)
- Functions: `snake_case` (generate_chunk(), get_water_height())
- Constants: `UPPER_CASE` (CHUNK_SIZE = 32, GRAVITY = 9.8)
- Private members: `_snake_case` (_current_chunk, _cache)

### Code Organization

**Structure Patterns:**
- Tests: `tests/` folder with `test_*.gd` files
- Shaders: Centralized in `src/shaders/` by function
- Scenes: Organized by gameplay domain (world, player, ui, npcs)
- Scripts: Grouped by system (core, gameplay, ui)

**Module Boundaries:**
- **World System:** Manages chunk generation, persistence, determinism
- **Water System:** Handles hydrology, navigation, mechanics
- **Rendering System:** Sprite placement, camera, visual effects
- **Gameplay System:** Player, NPCs, survival, skills
- **UI System:** HUD, inventory, dialogue

### Error Handling Strategy

- **GPU Shader Errors:** Log to console, fall back to basic terrain if compute fails
- **Persistence Errors:** Log error, keep in-memory state; retry save on next checkpoint
- **Chunk Generation Errors:** Retry with exponential backoff; use cached version if available
- **NPC/Pathfinding Errors:** Silently disable pathfinding; NPC remains static if AStar fails

### Logging Strategy

- **Level:** DEBUG, INFO, WARN, ERROR
- **Format:** `[SYSTEM] Message` (e.g., `[WorldGen] Chunk 5,3 generated in 142ms`)
- **Categories:** WorldGen, Water, Rendering, Gameplay, Persistence, Pathfinding

## Data Architecture

### World State

**Persisted Data:**
- Player state: position, inventory, skills, health, reputation
- Chunk modifications: terrain changes, destroyed objects, placed structures
- Environmental changes: tree growth, water level changes, NPC positions
- NPC state: location, reputation changes, trade history

**Generated Data (Recreated from Seed):**
- Base terrain heightmap (from compute shader)
- Biome distribution
- Water flow networks
- POI placement
- Vegetation, rocks, wildlife

### Save File Format

```
HarshWorld_Save.bin
├── Header
│   ├── Version: 1.0
│   ├── Timestamp
│   └── World Seed (32-bit)
├── Player State
│   ├── Position (x, y)
│   ├── Health, Hunger, Thirst, Warmth, Morale
│   ├── Skills (skill_name → 0-100 value)
│   ├── Inventory (item_id → quantity)
│   └── Reputation (npc_faction → -100 to +100)
└── Delta Storage
    ├── Modified Chunks (chunk_x, chunk_y → modifications)
    ├── Environmental Changes (timestamp, position, change_type)
    └── NPC State (npc_id → position, state_flags)
```

## Gameplay Systems Architecture

### Skill Progression System

**Data Model:**
```gdscript
# Player.gd
var skills = {
	"hunting": 0,
	"crafting": 0,
	"social": 0,
	"survival": 0,
	"combat": 0
}
var skill_xp = {
	"hunting": 0,
	"crafting": 0,
	# ... one entry per skill
}
```

**Progression Formula:**
- XP gain per action: `base_xp × (1 - current_skill/100)`
- Skill +1 every 100 XP
- Mastery bonuses at: 25, 50, 75, 100
- Skill decay: Unused skills decrease by 1 point per in-game week (future feature)

**Location:** `src/gameplay/player/character_state.gd`

### Survival Mechanics (Needs System)

**Architecture:**
```
Player (Node3D)
└── NeedsSystem (Node)
    ├── need_hunger
    ├── need_thirst
    ├── need_warmth
    ├── need_health
    └── need_morale
```

**Need Properties:**
- `current` (0-100): Current value
- `max` (100): Maximum capacity
- `decay_rate` (units/minute): How fast it decreases
- `regen_sources` (dict): What recovers each need

**Decay Rates (Base):**
| Need | Decay | Recovery Method |
|------|-------|-----------------|
| Hunger | -5/min | Eating food |
| Thirst | -8/min | Drinking water |
| Warmth | -2/min | Fire, clothing, shelter |
| Health | 0/min (stable) | Healing items, rest |
| Morale | -1/min | Social interaction, achievements |

**Environmental Modifiers:**
- Cold weather: +50% warmth decay
- Rain: +100% thirst recovery (free water)
- Injury: Health slowly regenerates (+0.5/min if resting)

**Location:** `src/core/survival/needs_system.gd`

### Inventory & Crafting System

**Inventory Data Model:**
```gdscript
# Player.gd
var inventory = {
	"fur": 5,
	"coin": 20,
	"wood": 3,
	"food_meat": 2
}

var max_inventory_weight = 50  # kg
```

**Item Definition (as Resource):**
```gdscript
# src/gameplay/player/item.gd
class_name Item
extends Resource

@export var id: String  # Unique ID
@export var name: String
@export var description: String
@export var weight: float  # kg
@export var max_stack: int = 99
@export var craftable: bool = true
```

**Crafting Recipes:**
```gdscript
# Stored as config file or Dict
var recipes = {
	"fur_coat": {
		"requires": {"fur": 5, "needle": 1},
		"produces": "fur_coat",
		"skill_required": "crafting",
		"skill_level": 25
	},
	"wooden_spoon": {
		"requires": {"wood": 2, "knife": 1},
		"produces": "wooden_spoon",
		"skill_required": "crafting",
		"skill_level": 0
	}
}
```

**Location:** `src/gameplay/player/inventory.gd`, `src/gameplay/player/crafting.gd`

### Merchant & Trading System

**Merchant Data:**
```gdscript
# src/gameplay/npcs/merchant.gd
class_name Merchant
extends Node3D

var merchant_id: String  # Unique ID
var trades = [
	{
		"id": "trade_1",
		"gives": "fur",
		"gives_amount": 1,
		"wants": "coin",
		"wants_amount": 5,
		"requires_reputation": -50,  # Minimum reputation to trade
		"repetitions": 1000  # Max times this trade can be done
	}
]
var reputation = 0  # -100 to +100
```

**Reputation System:**
- Starts at 0 for new NPCs
- +10 per successful trade
- -20 if player tries to steal
- Affects: NPC trading willingness, prices, dialogue options
- Merchants refuse to trade if reputation < -50

**Location:** `src/gameplay/npcs/merchant.gd`, `src/gameplay/npcs/reputation_system.gd`

### NPC Dialogue (Simplified)

**Merchant Interaction Flow:**
1. Player walks near merchant
2. Prompt appears: "Press E to talk to [Merchant Name]"
3. Simple menu opens:
   - [View Trades]
   - [Your Reputation: +15]
   - [Close]
4. If "View Trades" → List all available trades, player can accept or decline
5. Trade executed, both inventories updated, reputation updated

**No dialogue tree for MVP** - Just transactional.

**Location:** `src/gameplay/npcs/dialogue.gd`

## Biome Generation Implementation

**BiomeDefinition Resource:**

```gdscript
class_name BiomeDefinition
extends Resource

@export var biome_id: String  # "temperate_forest"
@export var color: Color
@export var description: String
@export var terrain_types: Dictionary  # {terrain_id: TerrainType}
@export var feature_layers: Array[String]  # Which features can spawn here

class TerrainType:
    var id: String
    var color: Color
    var walkable: bool
    var movement_speed: float  # 0.3 to 1.0
    var resources: Dictionary  # {resource_id: {spawn_chance, max_per_tile}}
```

**BiomeGenerator (per chunk):**

```gdscript
class_name BiomeGenerator
extends Node

var biome_definitions: Dictionary  # {biome_id: BiomeDefinition}
var noise: FastNoiseLite

func generate_chunk_biomes(chunk_x: int, chunk_y: int) -> PackedByteArray:
    var biome_map = PackedByteArray()
    var chunk_size = 32

    for y in range(chunk_size):
        for x in range(chunk_size):
            var world_x = chunk_x * chunk_size + x
            var world_y = chunk_y * chunk_size + y

            # Regional noise determines primary biome
            var regional_value = noise.get_noise_2d(
                world_x * 0.0003,
                world_y * 0.0003
            )
            var biome_id = _select_biome_from_noise(regional_value)
            biome_map.append(hash(biome_id) % 256)

    return biome_map

func spawn_resources_on_tile(biome_id: String, terrain_id: String) -> Array[String]:
    var biome = biome_definitions[biome_id]
    var terrain = biome.terrain_types[terrain_id]
    var resources = []

    for resource_id in terrain.resources.keys():
        var spawn_data = terrain.resources[resource_id]
        if randf() < spawn_data.spawn_chance:
            for _i in range(randi_range(1, spawn_data.max_per_tile)):
                resources.append(resource_id)

    return resources
```

**Waterways Integration:**

```gdscript
# After chunk biome generation, run Waterways to classify water bodies
var waterways = WateraysSystem.new()
var water_classification = waterways.classify_water_bodies(heightmap, chunk_x, chunk_y)

# Results: {position: {type: "creek", width: 1}, ...}
# Types: creek, stream, river, lake, ocean
```

## Player Movement & Interaction Implementation

### Player Controller with Stamina

```gdscript
# src/gameplay/player/player.gd
class_name Player
extends CharacterBody3D

# Movement
@export var base_move_speed: float = 5.0
@export var run_multiplier: float = 1.5
@export var acceleration: float = 20.0
@export var friction: float = 15.0

# Stamina
@export var max_stamina: float = 100.0
var stamina: float = 100.0
@export var stamina_drain_run: float = 15.0  # per second while running
@export var stamina_drain_interaction: float = 10.0  # per interaction
@export var stamina_regen_rate: float = 5.0  # per second at rest

# Animation
var animation_player: AnimationPlayer
var current_direction: Vector2 = Vector2.ZERO
var terrain_speed_modifier: float = 1.0
var is_running: bool = false

func _physics_process(delta: float) -> void:
    # Handle input
    current_direction = Input.get_vector("ui_right", "ui_left", "ui_down", "ui_up")
    is_running = Input.is_action_pressed("run") and stamina > 0

    # Calculate effective speed
    var speed_multiplier = run_multiplier if is_running else 1.0
    var effective_speed = base_move_speed * terrain_speed_modifier * speed_multiplier

    # Reduce speed if stamina critically low
    if stamina < 10:
        effective_speed *= 0.5

    # Apply movement
    if current_direction.length() > 0:
        velocity = velocity.lerp(
            Vector3(current_direction.x, 0, current_direction.y) * effective_speed,
            acceleration * delta
        )
    else:
        velocity = velocity.lerp(Vector3.ZERO, friction * delta)

    velocity = move_and_slide(velocity)

    # Update stamina
    _update_stamina(delta)

    # Update animation
    _update_animation()

func _update_stamina(delta: float) -> void:
    if is_running and velocity.length() > 0.1:
        stamina -= stamina_drain_run * delta
    else:
        stamina += stamina_regen_rate * delta

    stamina = clamp(stamina, 0, max_stamina)

func _update_animation():
    var speed = velocity.length()

    if speed > 0.1:
        # Determine 4-direction
        var dir = velocity.normalized()
        var angle = atan2(dir.z, dir.x)

        var direction_name = "down"
        if angle > PI * 0.75 or angle < -PI * 0.75:
            direction_name = "left"
        elif angle > PI * 0.25:
            direction_name = "down"
        elif angle > -PI * 0.25:
            direction_name = "right"
        else:
            direction_name = "up"

        # Play walk animation based on direction + running state
        var anim_name = "walk_" + direction_name
        if is_running:
            anim_name = "run_" + direction_name

        animation_player.play(anim_name)
    else:
        animation_player.play("idle")

func set_terrain_modifier(modifier: float):
    terrain_speed_modifier = modifier
```

### Interaction System (Hold-E for Actions)

```gdscript
# src/gameplay/player/interaction_manager.gd
class_name InteractionManager
extends Node

var player: Player
var interaction_raycast: RayCast3D
var current_interactable: WorldObject = null
var interaction_hold_time: float = 0.0
var interaction_in_progress: bool = false

func _process(delta: float) -> void:
    # Detect nearby interactable
    if interaction_raycast.is_colliding():
        var collider = interaction_raycast.get_collider()
        if collider is WorldObject:
            current_interactable = collider
        else:
            current_interactable = null
    else:
        current_interactable = null

    # Handle hold-E interaction
    if Input.is_action_pressed("interact") and current_interactable:
        interaction_hold_time += delta
        interaction_in_progress = true

        # Show progress UI (optional)
        # ui.show_interaction_progress(interaction_hold_time / current_interactable.interaction_time)
    else:
        if interaction_hold_time > 0:
            # Released early - cancel
            interaction_hold_time = 0.0
        interaction_in_progress = false

    # Complete interaction when hold time reached
    if current_interactable and interaction_hold_time >= current_interactable.interaction_time:
        _perform_interaction(current_interactable)
        interaction_hold_time = 0.0

func _perform_interaction(obj: WorldObject):
    # Deduct stamina
    if player.stamina < obj.stamina_cost:
        print("Not enough stamina!")
        return

    player.stamina -= obj.stamina_cost

    # Execute interaction (chop, dig, pickup, etc)
    match obj.interaction_type:
        "chop":
            obj.take_damage(1)  # 1 chop reduces durability
            player.gain_xp("woodcutting", 5)
        "dig":
            obj.take_damage(1)
            player.gain_xp("mining", 5)
        "pickup":
            player.inventory.add_item(obj.item_type, 1)
            obj.queue_free()

    print("Interaction complete: ", obj.interaction_type)
```

### WorldObject Base Class

```gdscript
# src/core/rendering/world_object.gd
class_name WorldObject
extends Node3D

@export var object_type: String = "tree"  # "tree", "rock", "resource"
@export var interaction_type: String = "chop"  # "chop", "dig", "pickup"
@export var durability: int = 3  # Hits needed to harvest
@export var interaction_time: float = 0.5  # Hold time (seconds)
@export var stamina_cost: float = 10.0  # Stamina drained per interaction
@export var resource_drop: String = "wood"  # Item dropped

var sprite: Sprite3D
var collision: CollisionShape3D
var current_durability: int

func _ready():
    current_durability = durability
    # Create sprite + collision
    _setup_visuals()

func take_damage(amount: int):
    current_durability -= amount
    if current_durability <= 0:
        _on_harvested()

func _on_harvested():
    # Drop resource
    var item_scene = preload("res://scenes/items/dropped_item.tscn")
    var item_instance = item_scene.instantiate()
    item_instance.position = global_position + Vector3(0.5, 0, 0.5)
    item_instance.item_type = resource_drop
    get_parent().add_child(item_instance)

    # Remove object from world
    queue_free()
```

### Stamina Effects on Health Regen & Interaction Speed

```gdscript
# Add to NeedsSystem or Player
func get_health_regen_rate() -> float:
    var base_regen = 0.5  # per second

    # Stamina affects regen
    if stamina < 20:
        return 0.0  # No regen when exhausted
    elif stamina < 50:
        return base_regen * 0.5  # 50% slower
    else:
        return base_regen

# Interaction speed affected by stamina (lower stamina = slower action)
func get_interaction_speed_multiplier() -> float:
    if stamina < 10:
        return 0.5
    elif stamina < 30:
        return 0.75
    else:
        return 1.0
```

## Consistency Rules

### Grid & Collision

- Grid system (32×32 cells) organizes world objects: trees, rocks, structures, resources
- World objects placed on grid cells with Godot collision shapes (CollisionShape2D/3D)
- Collision detection uses Godot's built-in physics system: collision layers and collision masks
- Player position tracked as continuous float coordinates, movement constrained by collision shapes
- Movement is fluid/continuous but blocked by solid colliders (like Don't Starve/Necesse)

### Movement & Animation

- Player uses continuous, float-based movement (velocity-based, not grid-locked); CharacterBody3D with terrain speed modifiers
- 4-direction sprite animation (up/down/left/right) with walk/run cycles synced to velocity
- **Camera** isometric offset (0, 8, 5) following player smoothly with look-ahead; always facing player
- Stamina affects: movement_speed (50% if < 10), interaction_speed, health regen rate
- Running drains stamina 15/sec; rests recover 5/sec at idle; low stamina = exhaustion penalties

### Survival Mechanics

- Needs degrade over time in consistent intervals
- Skill gains calculated as: `base_gain × (1 - current_skill/100)`
- Resource gathering: success based on skill check

### Water Mechanics

- Water height determined by Waterways system with DEM-based flow accumulation
- Waterways classifies rivers: creek (FA 3-20) → stream (20-50) → river (50+) → lakes (connected areas)
- Canoe can navigate rivers/streams; shallow water fordable
- Each terrain type has movement_speed modifier (dense forest 0.6, prairie 1.0, swamp 0.3, etc.)

### Biome System (Necesse-style)

**Regional Biome Distribution:**
- Deterministic biome placement based on regional noise (frequency 0.0003)
- Primary biomes: Coastal Atlantic, Temperate Forest, Deciduous Forest, Grasslands, Appalachian Mountains, Boreal Forest, Wetlands
- Each biome has 2-3 terrain_types with distinct colors, walkability, movement_speed, and resources

**Biome Structure (per biome example: Temperate Forest):**
```
Temperate Forest (regional biome)
├── light_forest (terrain type)
│   ├── color: [0.4, 0.6, 0.3]
│   ├── movement_speed: 0.9
│   └── resources: {maple: 35%, birch: 28%, poplar: 20%}
└── dense_temperate_forest (terrain type)
    ├── color: [0.2, 0.4, 0.15]
    ├── movement_speed: 0.6
    └── resources: {maple: 50%, birch: 42%, poplar: 28%}
```

**Feature Layers (spawn across multiple biomes):**
- Wetlands: spawn_chance 8%, appear in coastal/forest/grasslands
- Small Lakes: spawn_chance 12%, appear in most biomes
- Resources per tile: fish, stone, ore, wood, herbs vary by terrain

**Noise Generation:**
- Base frequency: 0.0015 (biome detail)
- Regional frequency: 0.0003 (climate zones)
- Color variation: 0.4 (visual diversity)

## Implementation Priority & Next Steps

### Phase 1: Core Prototype (Foundation)
1. **Godot Project Setup**
   - Create Godot 4.x 3D project
   - Set up folder structure (src/, assets/, scenes/, tests/)
   - Install Waterways .NET and OWDB addons

2. **GPU Pipeline Foundation**
   - Implement basic compute shader pipeline
   - Create heightmap generation shader
   - Test GPU compute performance

3. **Rendering System**
   - Implement GridMap 3D setup with 32×32 cells
   - Create 2D sprite rendering in 3D space (GridMap quads)
   - Set up orthographic camera system
   - Basic sprite positioning

4. **World System**
   - Implement seed management (deterministic world)
   - Create chunk manager skeleton
   - Test chunk generation and caching

**Deliverable:** Procedurally generated 3D world with player sprite movement on grid

### Phase 2: Core Gameplay (Systems Integration)
5. **Survival System**
   - Implement NeedsSystem with all 5 needs
   - Create need decay logic and UI
   - Implement food/water gathering mechanics

6. **Skill System**
   - Implement skill progression (0-100 with XP)
   - Test diminishing returns formula
   - Create skill UI display

7. **Inventory & Crafting**
   - Implement inventory dictionary system
   - Create crafting recipe system
   - Build simple inventory UI

8. **Water System**
   - Integrate Waterways plugin
   - Generate navigable rivers
   - Implement canoe mechanics

9. **Merchant System**
   - Create Merchant NPC class
   - Implement reputation tracking
   - Build simple trade UI

**Deliverable:** Fully playable survival loop with all core mechanics

### Phase 3: World Building (Content)
10. **Advanced World Generation**
    - Biome generation with shaders
    - POI (Point of Interest) placement
    - Wildlife and NPC distribution

11. **Settlements**
    - Settlement placement and persistence
    - Settlement water dependency
    - Trade hubs

12. **Advanced Hydrology**
    - Waterfalls, rapids, wetlands
    - Seasonal water level changes
    - Flood events

**Deliverable:** Rich, living world with exploration potential

### Phase 4: Polish (Quality)
13. **Optimization**
    - Chunk LOD system
    - Culling optimization
    - Shader performance tuning

14. **Balance & Content**
    - Skill progression balancing
    - Survival difficulty tuning
    - Recipe and item balancing

15. **Bug Fixes & Testing**
    - Full playthrough testing
    - Performance testing across hardware
    - Accessibility testing

**Deliverable:** Launch-ready game

---

## Architecture Decision Records (ADRs)

### ADR-001: GPU-Exclusive Procedural Generation
**Decision:** All procedural generation MUST use GPU compute shaders; no CPU fallback.
**Rationale:** Eliminates performance bottleneck; ensures consistent behavior; GPU compute is well-supported in Godot 4.x.
**Consequences:** Requires GPU support (all modern systems have this); cannot run on CPU-only machines; development requires GLSL expertise.

### ADR-002: Deterministic World via Seeding
**Decision:** World generation is fully deterministic based on seed; chunks are cached but regenerable.
**Rationale:** Allows persistent multiplayer (future); enables delta-only saving; reduces memory footprint.
**Consequences:** Chunk regeneration must be identical every time; environmental changes must be persisted separately.

### ADR-003: Full-Chunk Persistence with Selective Saves
**Decision:** Save complete modified chunks to disk (Resource format); unmodified chunks regenerated from seed on load.
**Rationale:** Simple implementation; player modifications (chopped trees, placed structures) persist reliably; reduced disk footprint (only save chunks with changes); deterministic generation recreates unmodified baseline.
**Consequences:** Modified chunks stored as .tres files; load time requires regenerating unmodified chunks; seed changes would orphan old save chunks.

### ADR-003b: Biome System with Terrain Types & Resources

**Decision:** Multi-layered biome system with regional distribution, terrain subtypes, and per-tile resource generation (Necesse-style).

**Structure:**
- Regional noise (0.0003 frequency) determines primary biome distribution
- Each biome contains 2-3 terrain_types with distinct movement costs and visual appearance
- Resources spawn probabilistically per tile based on terrain type
- Feature layers (wetlands, lakes) can spawn across multiple biomes
- Waterways classifies water bodies (creek → stream → river → lake → ocean)

**Rationale:**
- Creates diverse, explorable world without hand-placement
- Movement speed per terrain creates exploration pacing (dense forest slow, prairie fast)
- Resource diversity drives player exploration and crafting loops
- Necesse-level complexity achievable with procedural + Waterways

**Consequences:**
- Requires BiomeDefinition resources (one per biome type)
- Biome generation must happen before object spawning
- Waterways integration adds hydrology pass per chunk
- More complex configuration but matches Necesse gameplay depth

### ADR-004: Simplified MVP Scope
**Decision:** MVP includes: Survival, Skills, Merchants, Hydrology. Does NOT include: Complex factions, warfare, diplomacy.
**Rationale:** Achievable scope; core experience still complete; future expansion path clear.
**Consequences:** Some GDD features deferred to post-launch; may limit some gameplay complexity.

### ADR-005: Fluid/Continuous Movement with Smooth Camera
**Decision:** Player and NPCs use continuous, fluid movement (not grid-locked). Camera smoothly follows player with fixed offset (like Don't Starve/Necesse). Collisions use Godot's built-in physics system with collision layers/masks.
**Rationale:** Better visual feel and responsiveness; more organic player experience; camera following creates immersive exploration; Godot's physics system handles collision efficiently.
**Consequences:** Movement is smooth and free-roaming; NPCs path smoothly along generated routes; player blocked by collision shapes; requires float-based position tracking.

---

_Generated by BMAD Game Architecture Workflow_
_Date: 2025-12-02_
_For: JC_
_Status: COMPLETE - Ready for Implementation_
