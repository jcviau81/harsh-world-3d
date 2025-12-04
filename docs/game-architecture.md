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

### Persistence System Implementation

```gdscript
# src/core/world/persistence_manager.gd
class_name PersistenceManager
extends Node

const SAVE_VERSION: String = "1.0"
const SAVE_DIR: String = "user://saves/"
const CHUNK_SAVE_DIR: String = "user://saves/chunks/"
const METADATA_FILE: String = "metadata.json"

var save_slot: int = 1
var last_save_time: float = 0.0
var auto_save_interval: float = 300.0  # 5 minutes

var player: Player
var chunk_manager: ChunkManager
var reputation_system: ReputationSystem
var world_seed: int

func _ready():
	player = get_tree().root.get_node("Player")
	chunk_manager = get_tree().root.get_node("World/ChunkManager")
	reputation_system = get_tree().root.get_node("Game/ReputationSystem")
	world_seed = chunk_manager.world_seed

	# Create save directories
	_ensure_save_directories()

	# Setup auto-save
	var timer = Timer.new()
	add_child(timer)
	timer.wait_time = auto_save_interval
	timer.timeout.connect(_on_auto_save_timer)
	timer.start()

func _process(_delta: float) -> void:
	# Could add periodic save checks here
	pass

func save_game(slot: int = -1) -> bool:
	if slot >= 0:
		save_slot = slot

	print("[Persistence] Saving game to slot %d" % save_slot)

	# Create save data structure
	var save_data = {
		"version": SAVE_VERSION,
		"timestamp": Time.get_ticks_msec(),
		"world_seed": world_seed,
		"player": _serialize_player(),
		"reputation": reputation_system.save_reputation(),
		"npcs": _serialize_all_npcs()
	}

	# Save metadata
	var metadata_path = "%sslot_%d/%s" % [SAVE_DIR, save_slot, METADATA_FILE]
	var json = JSON.stringify(save_data)

	if not FileAccess.open(metadata_path, FileAccess.WRITE):
		print("[Persistence] ERROR: Could not write metadata to %s" % metadata_path)
		return false

	FileAccess.get_open_error()
	var file = FileAccess.open(metadata_path, FileAccess.WRITE)
	file.store_string(json)

	# Save all modified chunks
	_save_modified_chunks()

	last_save_time = Time.get_ticks_msec()
	print("[Persistence] Game saved successfully")
	return true

func load_game(slot: int = -1) -> bool:
	if slot >= 0:
		save_slot = slot

	print("[Persistence] Loading game from slot %d" % save_slot)

	var metadata_path = "%sslot_%d/%s" % [SAVE_DIR, save_slot, METADATA_FILE]

	if not ResourceLoader.exists(metadata_path):
		print("[Persistence] ERROR: Save file not found at %s" % metadata_path)
		return false

	# Load metadata
	var file = FileAccess.open(metadata_path, FileAccess.READ)
	if file == null:
		print("[Persistence] ERROR: Could not read metadata")
		return false

	var json_str = file.get_as_text()
	var json = JSON.new()
	if json.parse(json_str) != OK:
		print("[Persistence] ERROR: Invalid JSON in metadata")
		return false

	var save_data = json.data

	# Verify version compatibility
	if save_data.get("version", "") != SAVE_VERSION:
		print("[Persistence] WARNING: Save file version mismatch")
		# Could implement migration logic here

	world_seed = save_data.get("world_seed", 0)
	chunk_manager.world_seed = world_seed

	# Load player state
	_deserialize_player(save_data.get("player", {}))

	# Load reputation
	reputation_system.load_reputation(save_data.get("reputation", {}))

	# Load NPC states
	_load_all_npcs(save_data.get("npcs", {}))

	print("[Persistence] Game loaded successfully")
	return true

func _serialize_player() -> Dictionary:
	return {
		"position": [player.global_position.x, player.global_position.y, player.global_position.z],
		"health": player.needs_system.health,
		"hunger": player.needs_system.hunger,
		"thirst": player.needs_system.thirst,
		"warmth": player.needs_system.warmth,
		"morale": player.needs_system.morale,
		"stamina": player.stamina,
		"skills": player.character_state.skills.duplicate(),
		"skill_xp": player.character_state.skill_xp.duplicate(),
		"inventory": player.inventory.save_inventory()
	}

func _deserialize_player(data: Dictionary):
	if data.has("position"):
		var pos_array = data["position"]
		player.global_position = Vector3(pos_array[0], pos_array[1], pos_array[2])

	if data.has("health"):
		player.needs_system.health = data["health"]
	if data.has("hunger"):
		player.needs_system.hunger = data["hunger"]
	if data.has("thirst"):
		player.needs_system.thirst = data["thirst"]
	if data.has("warmth"):
		player.needs_system.warmth = data["warmth"]
	if data.has("morale"):
		player.needs_system.morale = data["morale"]
	if data.has("stamina"):
		player.stamina = data["stamina"]

	if data.has("skills"):
		player.character_state.skills = data["skills"].duplicate()
	if data.has("skill_xp"):
		player.character_state.skill_xp = data["skill_xp"].duplicate()
	if data.has("inventory"):
		player.inventory.load_inventory(data["inventory"])

func _serialize_all_npcs() -> Dictionary:
	var npcs_data = {}
	var world = get_tree().root.get_node("World")

	for npc in world.get_tree().get_nodes_in_group("npcs"):
		if npc is NPCBase:
			npcs_data[npc.npc_id] = npc.save_npc_state()
			if npc is Merchant:
				npcs_data[npc.npc_id] = npc.save_merchant_state()

	return npcs_data

func _load_all_npcs(npcs_data: Dictionary):
	var world = get_tree().root.get_node("World")

	for npc in world.get_tree().get_nodes_in_group("npcs"):
		if npc is NPCBase and npcs_data.has(npc.npc_id):
			npc.load_npc_state(npcs_data[npc.npc_id])
			if npc is Merchant:
				npc.load_merchant_state(npcs_data[npc.npc_id])

func _save_modified_chunks():
	for chunk in chunk_manager.get_all_modified_chunks():
		_save_chunk(chunk)

func _save_chunk(chunk: ChunkData):
	if not chunk.is_modified:
		return

	var path = "%sslot_%d/chunk_%d_%d.tres" % [
		SAVE_DIR,
		save_slot,
		chunk.chunk_x,
		chunk.chunk_y
	]

	if ResourceSaver.save(chunk, path) != OK:
		print("[Persistence] ERROR: Failed to save chunk %d,%d" % [chunk.chunk_x, chunk.chunk_y])

func get_save_info(slot: int) -> Dictionary:
	var metadata_path = "%sslot_%d/%s" % [SAVE_DIR, slot, METADATA_FILE]

	if not ResourceLoader.exists(metadata_path):
		return {}

	var file = FileAccess.open(metadata_path, FileAccess.READ)
	if file == null:
		return {}

	var json_str = file.get_as_text()
	var json = JSON.new()
	if json.parse(json_str) != OK:
		return {}

	var data = json.data
	return {
		"timestamp": data.get("timestamp", 0),
		"world_seed": data.get("world_seed", 0),
		"version": data.get("version", "unknown")
	}

func delete_save(slot: int) -> bool:
	var save_path = "%sslot_%d" % [SAVE_DIR, slot]
	var dir = DirAccess.open(save_path.get_base_dir())

	if dir:
		return dir.remove(save_path) == OK

	return false

func _ensure_save_directories():
	# Create main save directory
	if not DirAccess.dir_exists_absolute(SAVE_DIR):
		DirAccess.make_abs_absolute(SAVE_DIR)

	# Create slot directory
	var slot_dir = "%sslot_%d" % [SAVE_DIR, save_slot]
	if not DirAccess.dir_exists_absolute(slot_dir):
		DirAccess.make_abs_absolute(slot_dir)

	# Create chunk directory
	var chunk_dir = "%sslot_%d/chunks" % [SAVE_DIR, save_slot]
	if not DirAccess.dir_exists_absolute(chunk_dir):
		DirAccess.make_abs_absolute(chunk_dir)

func _on_auto_save_timer():
	save_game()
	print("[Persistence] Auto-save complete")
```

### ChunkManager Persistence Extension

```gdscript
# Add to ChunkManager class
var modified_chunks: Dictionary = {}  # {chunk_key: chunk_data}

func get_all_modified_chunks() -> Array[ChunkData]:
	var result: Array[ChunkData] = []
	for chunk in modified_chunks.values():
		if chunk.is_modified:
			result.append(chunk)
	return result

func mark_chunk_modified(chunk: ChunkData):
	chunk.is_modified = true
	var key = "%d_%d" % [chunk.chunk_x, chunk.chunk_y]
	modified_chunks[key] = chunk

func load_or_generate_chunk(x: int, y: int) -> ChunkData:
	var key = "%d_%d" % [x, y]

	# Check if we have it cached as modified
	if modified_chunks.has(key):
		return modified_chunks[key]

	# Try load from disk
	var persistence_mgr = get_tree().root.get_node("Game/PersistenceManager")
	var path = "%sslot_%d/chunk_%d_%d.tres" % [
		"user://saves/",
		persistence_mgr.save_slot,
		x,
		y
	]

	if ResourceLoader.exists(path):
		var chunk = ResourceLoader.load(path)
		modified_chunks[key] = chunk
		return chunk

	# Otherwise generate from seed
	var chunk = _generate_chunk(x, y)
	modified_chunks[key] = chunk
	return chunk
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

### Survival System Implementation

```gdscript
# src/core/survival/needs_system.gd
class_name NeedsSystem
extends Node

# References
var player: Player

# Need states (0-100)
var hunger: float = 100.0
var thirst: float = 100.0
var warmth: float = 100.0
var health: float = 100.0
var morale: float = 100.0

# Environmental context
var current_biome: String = "temperate_forest"
var is_raining: bool = false
var has_fire: bool = false
var is_sheltered: bool = false
var is_moving: bool = false

# Decay rates (per second)
var hunger_decay_rate: float = 5.0 / 60.0  # 5 per minute
var thirst_decay_rate: float = 8.0 / 60.0  # 8 per minute
var warmth_decay_rate: float = 2.0 / 60.0  # 2 per minute
var health_decay_rate: float = 0.0
var morale_decay_rate: float = 1.0 / 60.0  # 1 per minute

# Recovery rates (per second)
var hunger_recovery_rate: float = 0.0
var thirst_recovery_rate: float = 0.0
var warmth_recovery_rate: float = 0.0
var health_recovery_rate: float = 0.5 / 60.0  # 0.5 per minute
var morale_recovery_rate: float = 0.0

# Critical thresholds
const HUNGER_CRITICAL: float = 20.0
const THIRST_CRITICAL: float = 20.0
const WARMTH_CRITICAL: float = 30.0
const HEALTH_CRITICAL: float = 20.0
const MORALE_CRITICAL: float = 10.0

func _ready():
	player = get_parent()

func _process(delta: float) -> void:
	_update_needs(delta)
	_apply_need_effects()

func _update_needs(delta: float) -> void:
	# Calculate effective decay rates based on environment
	var hunger_rate = hunger_decay_rate
	var thirst_rate = thirst_decay_rate
	var warmth_rate = warmth_decay_rate
	var morale_rate = morale_decay_rate

	# Player movement increases hunger/thirst
	if is_moving and player.velocity.length() > 0.1:
		hunger_rate *= 1.2
		thirst_rate *= 1.2

	# Running increases decay significantly
	if player.is_running:
		hunger_rate *= 1.5
		thirst_rate *= 1.5

	# Cold environment increases warmth decay
	if current_biome in ["boreal_forest", "appalachian_mountains"]:
		warmth_rate *= 1.5

	# Rain affects thirst recovery (can drink)
	if is_raining:
		thirst_recovery_rate = 2.0 / 60.0

	# Fire provides warmth and morale recovery
	if has_fire:
		warmth_recovery_rate = 1.0 / 60.0
		morale_recovery_rate = 0.5 / 60.0

	# Shelter provides warmth
	if is_sheltered:
		warmth_recovery_rate += 0.5 / 60.0

	# Update need values
	hunger = clamp(hunger - hunger_rate * delta + hunger_recovery_rate * delta, 0.0, 100.0)
	thirst = clamp(thirst - thirst_rate * delta + thirst_recovery_rate * delta, 0.0, 100.0)
	warmth = clamp(warmth - warmth_rate * delta + warmth_recovery_rate * delta, 0.0, 100.0)
	health = clamp(health - health_decay_rate * delta + health_recovery_rate * delta, 0.0, 100.0)
	morale = clamp(morale - morale_rate * delta + morale_recovery_rate * delta, 0.0, 100.0)

	# Reset recovery rates each frame (they're set by environmental checks)
	hunger_recovery_rate = 0.0
	thirst_recovery_rate = 0.0
	warmth_recovery_rate = 0.0
	morale_recovery_rate = 0.0

func _apply_need_effects() -> void:
	# Stamina affects health regen
	if player.stamina < 20:
		health_recovery_rate = 0.0  # No regen when exhausted
	elif player.stamina < 50:
		health_recovery_rate = 0.25 / 60.0  # 50% slower
	else:
		health_recovery_rate = 0.5 / 60.0  # Normal

	# Critical needs cause damage
	if hunger < HUNGER_CRITICAL or thirst < THIRST_CRITICAL:
		health -= 0.2 / 60.0  # Lose 0.2 health per second when critical

	# Critical warmth causes health loss
	if warmth < WARMTH_CRITICAL:
		health -= 0.1 / 60.0

	# Critical health is handled separately (player enters low-health state)

	# Morale affects movement and interaction
	if morale < MORALE_CRITICAL:
		player.base_move_speed *= 0.7

func consume_food(food_type: String, quantity: int = 1) -> bool:
	var hunger_restored = 0.0

	match food_type:
		"berries":
			hunger_restored = 15.0 * quantity
		"meat":
			hunger_restored = 40.0 * quantity
		"bread":
			hunger_restored = 30.0 * quantity
		"fish":
			hunger_restored = 35.0 * quantity
		_:
			return false

	hunger = clamp(hunger + hunger_restored, 0.0, 100.0)
	return true

func consume_water(water_type: String, quantity: int = 1) -> bool:
	var thirst_restored = 0.0

	match water_type:
		"water_bottle":
			thirst_restored = 50.0 * quantity
		"water_pot":
			thirst_restored = 30.0 * quantity
		_:
			return false

	thirst = clamp(thirst + thirst_restored, 0.0, 100.0)
	return true

func apply_healing(healing_amount: float):
	health = clamp(health + healing_amount, 0.0, 100.0)

func get_biome_environment(biome: String):
	current_biome = biome
	match biome:
		"coastal_atlantic":
			warmth_decay_rate = 2.5 / 60.0
		"temperate_forest":
			warmth_decay_rate = 2.0 / 60.0
		"deciduous_forest":
			warmth_decay_rate = 2.0 / 60.0
		"grasslands":
			warmth_decay_rate = 2.0 / 60.0
		"appalachian_mountains":
			warmth_decay_rate = 4.0 / 60.0  # Much colder
		"boreal_forest":
			warmth_decay_rate = 5.0 / 60.0  # Extreme cold
		"wetlands":
			thirst_decay_rate = 3.0 / 60.0  # Faster thirst in heat/humidity

func get_all_needs_info() -> Dictionary:
	return {
		"hunger": {
			"current": hunger,
			"critical": hunger < HUNGER_CRITICAL
		},
		"thirst": {
			"current": thirst,
			"critical": thirst < THIRST_CRITICAL
		},
		"warmth": {
			"current": warmth,
			"critical": warmth < WARMTH_CRITICAL
		},
		"health": {
			"current": health,
			"critical": health < HEALTH_CRITICAL
		},
		"morale": {
			"current": morale,
			"critical": morale < MORALE_CRITICAL
		}
	}
```

### Biome-Specific Survival Effects

```gdscript
# Add to NeedsSystem
func apply_biome_effects(biome_id: String, terrain_type: String, weather: String = "clear"):
	get_biome_environment(biome_id)

	# Specific terrain effects
	match terrain_type:
		"dense_forest", "dense_boreal", "dense_hardwood":
			# Harder to see, morale decreases in darkness
			morale -= 0.05 / 60.0
			warmth_recovery_rate += 0.3 / 60.0  # Slightly warmer

		"rocky_cliff":
			# Dangerous, stressful
			morale -= 0.1 / 60.0

		"deep_swamp":
			# Uncomfortable, disease risk
			health -= 0.05 / 60.0
			morale -= 0.1 / 60.0

		"prairie_grass", "tall_grass":
			# Open space, morale boost
			morale += 0.05 / 60.0

		"shallow_water", "deep_water":
			# Water increases thirst recovery if accessible
			if not player.is_submerged:
				thirst_recovery_rate += 1.0 / 60.0

	# Weather effects
	match weather:
		"rain":
			is_raining = true
			warmth_decay_rate *= 1.3
			thirst_recovery_rate = 2.0 / 60.0

		"snow":
			warmth_decay_rate *= 2.0
			health -= 0.1 / 60.0

		"storm":
			morale -= 0.15 / 60.0
			warmth_decay_rate *= 1.5
```

### Food & Cooking System

```gdscript
# src/core/survival/food_system.gd
class_name FoodSystem
extends Node

var player: Player

const RECIPES = {
	"cooked_meat": {
		"requires": {"raw_meat": 1},
		"produces": "cooked_meat",
		"hunger_restore": 40.0,
		"preparation_time": 5.0  # seconds
	},
	"bread": {
		"requires": {"grain": 3},
		"produces": "bread",
		"hunger_restore": 30.0,
		"preparation_time": 30.0
	},
	"stew": {
		"requires": {"vegetables": 2, "meat": 1, "water": 1},
		"produces": "stew",
		"hunger_restore": 50.0,
		"thirst_restore": 20.0,
		"preparation_time": 15.0
	}
}

func cook_food(recipe_name: String) -> bool:
	if not RECIPES.has(recipe_name):
		return false

	var recipe = RECIPES[recipe_name]

	# Check player has all required items
	for item in recipe["requires"].keys():
		if not player.inventory.has_item(item, recipe["requires"][item]):
			return false

	# Remove required items
	for item in recipe["requires"].keys():
		player.inventory.remove_item(item, recipe["requires"][item])

	# Add produced item
	player.inventory.add_item(recipe["produces"], 1)

	return true

func eat_food(food_type: String, quantity: int = 1) -> bool:
	if not player.inventory.has_item(food_type, quantity):
		return false

	player.inventory.remove_item(food_type, quantity)
	player.needs_system.consume_food(food_type, quantity)

	return true
```

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

### Inventory System Implementation

```gdscript
# src/gameplay/player/inventory.gd
class_name Inventory
extends Node

var player: Player
var items: Dictionary = {}  # {item_id: quantity}
var max_weight: float = 50.0
var item_weights: Dictionary = {}  # {item_id: weight}

func _ready():
	player = get_parent()
	_load_item_definitions()

func add_item(item_id: String, quantity: int = 1) -> bool:
	if not item_weights.has(item_id):
		print("Item not found: %s" % item_id)
		return false

	var weight = item_weights[item_id] * quantity
	if get_current_weight() + weight > max_weight:
		print("Inventory full!")
		return false

	if not items.has(item_id):
		items[item_id] = 0

	items[item_id] += quantity
	_emit_inventory_changed()
	return true

func remove_item(item_id: String, quantity: int = 1) -> bool:
	if not items.has(item_id) or items[item_id] < quantity:
		return false

	items[item_id] -= quantity
	if items[item_id] <= 0:
		items.erase(item_id)

	_emit_inventory_changed()
	return true

func has_item(item_id: String, quantity: int = 1) -> bool:
	return items.has(item_id) and items[item_id] >= quantity

func get_quantity(item_id: String) -> int:
	return items.get(item_id, 0)

func get_current_weight() -> float:
	var total_weight = 0.0
	for item_id in items.keys():
		if item_weights.has(item_id):
			total_weight += item_weights[item_id] * items[item_id]
	return total_weight

func get_weight_percentage() -> float:
	return (get_current_weight() / max_weight) * 100.0

func _load_item_definitions():
	# Load item definitions from resources
	var items_dir = "res://assets/items/"
	var dir = DirAccess.open(items_dir)

	if dir:
		dir.list_dir_begin()
		var file_name = dir.get_next()

		while file_name != "":
			if file_name.ends_with(".tres"):
				var item: Item = load(items_dir + file_name)
				if item:
					item_weights[item.id] = item.weight

			file_name = dir.get_next()

func _emit_inventory_changed():
	player.inventory_changed.emit(items.duplicate())

func save_inventory() -> Dictionary:
	return items.duplicate()

func load_inventory(data: Dictionary):
	items = data.duplicate()
```

### Crafting System Implementation

```gdscript
# src/gameplay/player/crafting.gd
class_name CraftingSystem
extends Node

var player: Player
var inventory: Inventory

var recipes: Dictionary = {}  # {recipe_id: recipe_data}

func _ready():
	player = get_parent()
	inventory = player.inventory
	_load_recipes()

func _load_recipes():
	# Load recipe definitions
	recipes = {
		"wooden_axe": {
			"name": "Wooden Axe",
			"requires": {"wood": 3, "stone": 2},
			"produces": "wooden_axe",
			"quantity": 1,
			"skill_required": "crafting",
			"skill_level": 10,
			"xp_gain": 25,
			"time_seconds": 30.0
		},
		"stone_pick": {
			"name": "Stone Pickaxe",
			"requires": {"stone": 5, "wood": 2},
			"produces": "stone_pick",
			"quantity": 1,
			"skill_required": "crafting",
			"skill_level": 20,
			"xp_gain": 50,
			"time_seconds": 45.0
		},
		"fur_coat": {
			"name": "Fur Coat",
			"requires": {"fur": 5, "needle": 1, "thread": 3},
			"produces": "fur_coat",
			"quantity": 1,
			"skill_required": "tailoring",
			"skill_level": 15,
			"xp_gain": 40,
			"time_seconds": 60.0
		}
	}

func can_craft(recipe_id: String) -> Dictionary:
	# Returns {can_craft: bool, reason: String}
	if not recipes.has(recipe_id):
		return {"can_craft": false, "reason": "Recipe not found"}

	var recipe = recipes[recipe_id]

	# Check skill level
	var skill_level = player.get_skill(recipe["skill_required"])
	if skill_level < recipe["skill_level"]:
		return {
			"can_craft": false,
			"reason": "Skill too low: %d/%d" % [skill_level, recipe["skill_level"]]
		}

	# Check inventory
	for item_id in recipe["requires"].keys():
		var needed = recipe["requires"][item_id]
		if not inventory.has_item(item_id, needed):
			return {
				"can_craft": false,
				"reason": "Missing: %s" % item_id
			}

	# Check weight
	var produced_weight = 0.0  # Would need item definitions
	if inventory.get_current_weight() + produced_weight > inventory.max_weight:
		return {"can_craft": false, "reason": "Inventory full"}

	return {"can_craft": true, "reason": ""}

func craft(recipe_id: String) -> bool:
	var can_result = can_craft(recipe_id)
	if not can_result["can_craft"]:
		print("Cannot craft: ", can_result["reason"])
		return false

	var recipe = recipes[recipe_id]

	# Deduct ingredients
	for item_id in recipe["requires"].keys():
		inventory.remove_item(item_id, recipe["requires"][item_id])

	# Add produced items
	for _i in range(recipe["quantity"]):
		inventory.add_item(recipe["produces"], 1)

	# Grant XP
	player.gain_xp(recipe["skill_required"], recipe["xp_gain"])

	print("Crafted: ", recipe["name"])
	return true

func craft_with_animation(recipe_id: String) -> bool:
	# Animated crafting with progress
	var recipe = recipes[recipe_id]
	var time_remaining = recipe["time_seconds"]

	while time_remaining > 0:
		await get_tree().process_frame
		time_remaining -= get_physics_process_delta_time()

		# Show progress UI
		var progress = 1.0 - (time_remaining / recipe["time_seconds"])
		player.emit_signal("crafting_progress", progress)

	# Check if still valid
	if not can_craft(recipe_id)["can_craft"]:
		print("Crafting interrupted!")
		return false

	return craft(recipe_id)

func get_all_recipes() -> Array:
	var available = []
	for recipe_id in recipes.keys():
		var recipe = recipes[recipe_id]
		var skill = player.get_skill(recipe["skill_required"])

		# Can learn if within 10 levels of requirement
		if skill >= recipe["skill_level"] - 10:
			available.append({
				"id": recipe_id,
				"name": recipe["name"],
				"can_craft": can_craft(recipe_id)["can_craft"],
				"skill_level": recipe["skill_level"]
			})

	return available

func get_recipe_details(recipe_id: String) -> Dictionary:
	if recipes.has(recipe_id):
		return recipes[recipe_id].duplicate()
	return {}
```

### Inventory & Crafting Signals

```gdscript
# Add to Player.gd
signal inventory_changed(items: Dictionary)
signal crafting_started(recipe_id: String)
signal crafting_progress(progress: float)  # 0.0 to 1.0
signal crafting_complete(recipe_id: String)
signal item_used(item_id: String)

# Connect in _ready():
func _setup_signals():
	inventory.inventory_changed.connect(_on_inventory_changed)
```

### Item Usage System

```gdscript
# Add to Inventory or separate ItemUseSystem
func use_item(item_id: String) -> bool:
	if not has_item(item_id, 1):
		return false

	match item_id:
		"healing_potion":
			player.needs_system.apply_healing(30.0)
			remove_item(item_id, 1)
			return true

		"food_meat":
			player.needs_system.consume_food("meat", 1)
			remove_item(item_id, 1)
			return true

		"water_bottle":
			player.needs_system.consume_water("water_bottle", 1)
			remove_item(item_id, 1)
			return true

		_:
			return false

	_emit_inventory_changed()
	return true
```

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

### Reputation System Implementation

```gdscript
# src/gameplay/npcs/reputation_system.gd
class_name ReputationSystem
extends Node

var player_reputation: Dictionary = {}  # {merchant_id: reputation_value}

const REPUTATION_MIN: int = -100
const REPUTATION_MAX: int = 100

func get_reputation(merchant_id: String) -> int:
	return player_reputation.get(merchant_id, 0)

func set_reputation(merchant_id: String, value: int):
	player_reputation[merchant_id] = clamp(value, REPUTATION_MIN, REPUTATION_MAX)

func add_reputation(merchant_id: String, amount: int):
	var current = get_reputation(merchant_id)
	set_reputation(merchant_id, current + amount)

func get_reputation_description(rep: int) -> String:
	match rep:
		-100 to -80:
			return "Despised"
		-79 to -50:
			return "Hated"
		-49 to -20:
			return "Distrusted"
		-19 to 0:
			return "Unwelcome"
		1 to 20:
			return "Neutral"
		21 to 50:
			return "Liked"
		51 to 80:
			return "Trusted"
		81 to 100:
			return "Beloved"
		_:
			return "Unknown"

func get_price_multiplier(reputation: int) -> float:
	# Positive reputation = lower prices
	# Negative reputation = higher prices
	var base_multiplier = 1.0
	var modifier = float(reputation) / 100.0  # -1.0 to 1.0
	return base_multiplier - (modifier * 0.3)  # 0.7 to 1.3 range

func save_reputation() -> Dictionary:
	return player_reputation.duplicate()

func load_reputation(data: Dictionary):
	player_reputation = data.duplicate()
```

### Merchant Trading Implementation

```gdscript
# src/gameplay/npcs/merchant.gd - Extended implementation
class_name Merchant
extends NPCBase

var trades: Array[Dictionary] = []
var completed_trades: Dictionary = {}  # {trade_id: count}
var reputation_system: ReputationSystem

func _ready():
	super._ready()
	npc_type = "merchant"
	reputation_system = get_tree().root.get_node("Game/ReputationSystem")
	_initialize_trades()

func _initialize_trades():
	# Example trades for different merchant types
	match merchant_id:
		"merchant_settlement_0_0":
			_setup_trader_merchant()
		"merchant_settlement_0_1":
			_setup_hunter_merchant()
		"merchant_settlement_0_2":
			_setup_craftsman_merchant()

func _setup_trader_merchant():
	trades = [
		{
			"id": "trade_sell_coins",
			"gives": "coin",
			"gives_amount": 5,
			"wants": "fur",
			"wants_amount": 1,
			"requires_reputation": -100,
			"remaining": 1000
		},
		{
			"id": "trade_buy_food",
			"gives": "bread",
			"gives_amount": 2,
			"wants": "coin",
			"wants_amount": 3,
			"requires_reputation": -50,
			"remaining": 500
		},
		{
			"id": "trade_rare_axe",
			"gives": "iron_axe",
			"gives_amount": 1,
			"wants": "coin",
			"wants_amount": 50,
			"requires_reputation": 30,
			"remaining": 5
		}
	]

func _setup_hunter_merchant():
	trades = [
		{
			"id": "trade_sell_meat",
			"gives": "meat",
			"gives_amount": 2,
			"wants": "coin",
			"wants_amount": 4,
			"requires_reputation": -100,
			"remaining": 1000
		},
		{
			"id": "trade_buy_fur",
			"gives": "coin",
			"gives_amount": 8,
			"wants": "fur",
			"wants_amount": 1,
			"requires_reputation": -100,
			"remaining": 500
		}
	]

func _setup_craftsman_merchant():
	trades = [
		{
			"id": "trade_tools",
			"gives": "wooden_axe",
			"gives_amount": 1,
			"wants": "coin",
			"wants_amount": 10,
			"requires_reputation": -100,
			"remaining": 100
		}
	]

func can_trade(trade_id: String, player: Player) -> Dictionary:
	var trade = _get_trade(trade_id)
	if not trade:
		return {"can_trade": false, "reason": "Trade not found"}

	# Check reputation
	var reputation = reputation_system.get_reputation(merchant_id)
	if reputation < trade["requires_reputation"]:
		return {
			"can_trade": false,
			"reason": "Reputation too low: %s (%d/%d)" % [
				reputation_system.get_reputation_description(reputation),
				reputation,
				trade["requires_reputation"]
			]
		}

	# Check remaining uses
	if trade["remaining"] <= 0:
		return {"can_trade": false, "reason": "Trade exhausted"}

	# Check player inventory
	if not player.inventory.has_item(trade["wants"], trade["wants_amount"]):
		return {
			"can_trade": false,
			"reason": "Missing: %s (%d needed)" % [trade["wants"], trade["wants_amount"]]
		}

	return {"can_trade": true, "reason": ""}

func execute_trade(trade_id: String, player: Player) -> bool:
	var can_result = can_trade(trade_id, player)
	if not can_result["can_trade"]:
		print("Cannot execute trade: ", can_result["reason"])
		return false

	var trade = _get_trade(trade_id)

	# Apply price multiplier based on reputation
	var reputation = reputation_system.get_reputation(merchant_id)
	var price_multiplier = reputation_system.get_price_multiplier(reputation)

	# Adjust quantities based on reputation
	var wants_amount = int(trade["wants_amount"] * price_multiplier)
	var gives_amount = trade["gives_amount"]

	# Deduct from player
	player.inventory.remove_item(trade["wants"], wants_amount)

	# Give to player
	player.inventory.add_item(trade["gives"], gives_amount)

	# Update trade count
	trade["remaining"] -= 1
	var times_traded = completed_trades.get(trade_id, 0)
	completed_trades[trade_id] = times_traded + 1

	# Update reputation
	reputation_system.add_reputation(merchant_id, 10)

	print("Trade completed: %s gives %d %s for %d %s" % [
		display_name,
		gives_amount,
		trade["gives"],
		wants_amount,
		trade["wants"]
	])

	return true

func get_available_trades(player: Player) -> Array[Dictionary]:
	var available = []
	var reputation = reputation_system.get_reputation(merchant_id)

	for trade in trades:
		if reputation >= trade["requires_reputation"] and trade["remaining"] > 0:
			var can_do = can_trade(trade["id"], player)
			available.append({
				"id": trade["id"],
				"gives": trade["gives"],
				"gives_amount": trade["gives_amount"],
				"wants": trade["wants"],
				"wants_amount": trade["wants_amount"],
				"can_execute": can_do["can_trade"]
			})

	return available

func _get_trade(trade_id: String) -> Dictionary:
	for trade in trades:
		if trade["id"] == trade_id:
			return trade
	return {}

func get_merchant_info() -> Dictionary:
	var reputation = reputation_system.get_reputation(merchant_id)
	return {
		"merchant_id": merchant_id,
		"display_name": display_name,
		"reputation": reputation,
		"reputation_desc": reputation_system.get_reputation_description(reputation),
		"trades_available": get_available_trades(get_tree().root.get_node("Player"))
	}

func save_merchant_state() -> Dictionary:
	var state = save_npc_state()
	state["merchant_id"] = merchant_id
	state["completed_trades"] = completed_trades.duplicate()
	return state

func load_merchant_state(data: Dictionary):
	load_npc_state(data)
	merchant_id = data["merchant_id"]
	completed_trades = data.get("completed_trades", {})
```

### Merchant Interaction UI Logic

```gdscript
# src/ui/merchant_ui.gd
class_name MerchantUI
extends Control

var current_merchant: Merchant = null
var player: Player
var reputation_system: ReputationSystem

@onready var merchant_name_label = %MerchantNameLabel
@onready var reputation_label = %ReputationLabel
@onready var trades_list = %TradesList
@onready var confirm_button = %ConfirmButton

func _ready():
	player = get_tree().root.get_node("Player")
	reputation_system = get_tree().root.get_node("Game/ReputationSystem")
	visible = false

func show_merchant_trades(merchant: Merchant):
	current_merchant = merchant
	visible = true

	# Update UI
	merchant_name_label.text = merchant.display_name
	var reputation = reputation_system.get_reputation(merchant.merchant_id)
	reputation_label.text = "Reputation: %s (%d)" % [
		reputation_system.get_reputation_description(reputation),
		reputation
	]

	# List trades
	trades_list.clear()
	for trade in merchant.get_available_trades(player):
		var trade_text = "%s: Give %d %s for %d %s" % [
			trade["gives"],
			trade["gives_amount"],
			trade["gives"],
			trade["wants_amount"],
			trade["wants"]
		]

		if not trade["can_execute"]:
			trade_text += " [Can't do]"

		trades_list.add_item(trade_text)

func _on_confirm_trade():
	if trades_list.get_selected_items().size() == 0:
		return

	var selected_idx = trades_list.get_selected_items()[0]
	var available_trades = current_merchant.get_available_trades(player)

	if selected_idx < available_trades.size():
		var trade = available_trades[selected_idx]
		current_merchant.execute_trade(trade["id"], player)
		show_merchant_trades(current_merchant)  # Refresh UI
```

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

## NPC & Pathfinding Implementation

### NPC Base Class Architecture

```gdscript
# src/gameplay/npcs/npc_base.gd
class_name NPCBase
extends Node3D

# Identity
@export var npc_id: String  # Unique identifier
@export var display_name: String
@export var npc_type: String = "merchant"  # "merchant", "villager", etc.

# Behavior
@export var home_position: Vector3  # Where NPC returns to
@export var wander_radius: float = 20.0  # Max distance from home
@export var is_stationary: bool = false  # If true, stays at home_position

# State
var current_path: PackedVector3Array = []
var current_target: Vector3
var astar: AStar3D
var is_moving: bool = false
var velocity: Vector3 = Vector3.ZERO
var speed: float = 2.0

# Sprite & collision
var sprite: Sprite3D
var collision: CollisionShape3D
var animation_player: AnimationPlayer

func _ready():
	_setup_visuals()
	_initialize_astar()
	if not is_stationary:
		_choose_new_target()

func _physics_process(delta: float) -> void:
	if not is_stationary and current_path.size() > 0:
		_follow_path(delta)
		_update_animation()
	elif current_path.is_empty() and not is_stationary:
		# Reached target - pick new one
		_choose_new_target()

func _follow_path(delta: float) -> void:
	if current_path.size() == 0:
		return

	var target = current_path[0]
	var direction = (target - global_position).normalized()

	if global_position.distance_to(target) < 0.5:
		current_path.pop_front()
	else:
		velocity = direction * speed
		position += velocity * delta

func _choose_new_target():
	if is_stationary:
		return

	# Pick random point within wander_radius
	var angle = randf() * TAU
	var distance = randf() * wander_radius
	current_target = home_position + Vector3(cos(angle), 0, sin(angle)) * distance

	# Use AStar to find path
	_recalculate_path()

func _recalculate_path():
	if astar == null:
		return

	# Get closest grid point to current position
	var start_id = astar.get_closest_point(global_position)
	var end_id = astar.get_closest_point(current_target)

	if start_id >= 0 and end_id >= 0:
		current_path = astar.get_point_path(start_id, end_id)
	else:
		# Path not available - try again later
		await get_tree().create_timer(2.0).timeout
		_choose_new_target()

func _initialize_astar():
	astar = AStar3D.new()

	# Build pathfinding grid from walkable terrain
	var chunk_manager = get_tree().root.get_node("World/ChunkManager")
	if chunk_manager:
		_build_astar_from_chunks(chunk_manager)

func _build_astar_from_chunks(chunk_manager):
	# For each loaded chunk, add walkable points to AStar
	for chunk in chunk_manager.loaded_chunks:
		var chunk_x = chunk.chunk_x
		var chunk_y = chunk.chunk_y

		for y in range(32):
			for x in range(32):
				var world_x = chunk_x * 32 + x
				var world_y = chunk_y * 32 + y
				var point_id = world_x * 1000 + world_y

				# Check if walkable
				if chunk.is_walkable(x, y):
					var point_pos = Vector3(world_x, 0, world_y)
					astar.add_point(point_id, point_pos)

	# Connect adjacent walkable points
	_connect_astar_points(chunk_manager)

func _connect_astar_points(chunk_manager):
	for chunk in chunk_manager.loaded_chunks:
		var chunk_x = chunk.chunk_x
		var chunk_y = chunk.chunk_y

		for y in range(32):
			for x in range(32):
				var world_x = chunk_x * 32 + x
				var world_y = chunk_y * 32 + y
				var current_id = world_x * 1000 + world_y

				# Connect to neighbors (4-directional)
				for dx in [-1, 1]:
					var nx = world_x + dx
					var neighbor_id = nx * 1000 + world_y
					if astar.has_point(neighbor_id):
						astar.connect_points(current_id, neighbor_id)

				for dy in [-1, 1]:
					var ny = world_y + dy
					var neighbor_id = world_x * 1000 + ny
					if astar.has_point(neighbor_id):
						astar.connect_points(current_id, neighbor_id)

func _update_animation():
	var speed_magnitude = velocity.length()
	if speed_magnitude > 0.1:
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

		animation_player.play("walk_" + direction_name)
	else:
		animation_player.play("idle")

func _setup_visuals():
	# Create sprite and collision
	sprite = Sprite3D.new()
	sprite.texture = preload("res://assets/sprites/npcs/merchant.png")
	add_child(sprite)

	collision = CollisionShape3D.new()
	collision.shape = CapsuleShape3D.new()
	add_child(collision)
```

### Water-Aware Pathfinding

```gdscript
# Add to NPCBase or separate WaterAwarePathfinder class

func _connect_astar_points_water_aware(chunk_manager):
	# Same as _connect_astar_points, but check water barriers
	for chunk in chunk_manager.loaded_chunks:
		var chunk_x = chunk.chunk_x
		var chunk_y = chunk.chunk_y

		for y in range(32):
			for x in range(32):
				var world_x = chunk_x * 32 + x
				var world_y = chunk_y * 32 + y
				var current_id = world_x * 1000 + world_y

				if not chunk.is_walkable(x, y):
					continue

				# Connect to neighbors, checking water classification
				for dx in [-1, 1]:
					var nx = world_x + dx
					var ny = world_y
					var neighbor_id = nx * 1000 + ny

					if astar.has_point(neighbor_id):
						# Check if water blocks path
						var target_chunk = chunk_manager.get_chunk_at(nx, ny)
						var target_x = nx % 32
						var target_y = ny % 32

						# Allow crossing shallow water, but not deep water
						if target_chunk.water_type[target_y][target_x] in ["ford", "shallow"]:
							astar.connect_points(current_id, neighbor_id)
						elif target_chunk.is_walkable(target_x, target_y):
							astar.connect_points(current_id, neighbor_id)

				for dy in [-1, 1]:
					var nx = world_x
					var ny = world_y + dy
					var neighbor_id = nx * 1000 + ny

					if astar.has_point(neighbor_id):
						var target_chunk = chunk_manager.get_chunk_at(nx, ny)
						var target_x = nx % 32
						var target_y = ny % 32

						if target_chunk.water_type[target_y][target_x] in ["ford", "shallow"]:
							astar.connect_points(current_id, neighbor_id)
						elif target_chunk.is_walkable(target_x, target_y):
							astar.connect_points(current_id, neighbor_id)

# Water classification for terrain:
# "deep_water" - impassable
# "shallow_water" - fordable (slow 0.5x speed)
# "creek/stream/river" - Waterways classification (may be fording or canoe-only)
```

### NPC State Persistence

```gdscript
# Add to NPCBase
func save_npc_state() -> Dictionary:
	return {
		"npc_id": npc_id,
		"position": [global_position.x, global_position.y, global_position.z],
		"home_position": [home_position.x, home_position.y, home_position.z],
		"current_target": [current_target.x, current_target.y, current_target.z],
		"is_moving": is_moving
	}

func load_npc_state(data: Dictionary):
	global_position = Vector3(data["position"][0], data["position"][1], data["position"][2])
	home_position = Vector3(data["home_position"][0], data["home_position"][1], data["home_position"][2])
	current_target = Vector3(data["current_target"][0], data["current_target"][1], data["current_target"][2])
	is_moving = data["is_moving"]
	if is_moving:
		_recalculate_path()
```

### Merchant NPC Subclass

```gdscript
# src/gameplay/npcs/merchant.gd
class_name Merchant
extends NPCBase

# Trade data
var trades: Array[Dictionary] = [
	{
		"id": "trade_1",
		"gives": "fur",
		"gives_amount": 1,
		"wants": "coin",
		"wants_amount": 5,
		"requires_reputation": -50,
		"repetitions": 1000
	}
]

# Reputation
var merchant_id: String
var reputation: int = 0  # -100 to +100

func _ready():
	npc_type = "merchant"
	super._ready()

func get_available_trades(player_reputation: int) -> Array[Dictionary]:
	var available = []
	for trade in trades:
		if player_reputation >= trade["requires_reputation"]:
			available.append(trade)
	return available

func execute_trade(player: CharacterBody3D, trade: Dictionary) -> bool:
	# Check player has required items
	if not player.inventory.has_items(trade["wants"], trade["wants_amount"]):
		return false

	# Execute trade
	player.inventory.remove_item(trade["wants"], trade["wants_amount"])
	player.inventory.add_item(trade["gives"], trade["gives_amount"])

	# Update reputation
	reputation += 10
	player.reputation[merchant_id] = player.reputation.get(merchant_id, 0) + 10

	return true

func save_merchant_state() -> Dictionary:
	var state = save_npc_state()
	state["merchant_id"] = merchant_id
	state["reputation"] = reputation
	return state

func load_merchant_state(data: Dictionary):
	load_npc_state(data)
	merchant_id = data["merchant_id"]
	reputation = data["reputation"]
```

### Village/Settlement System

```gdscript
# src/core/world/settlement_system.gd
class_name SettlementSystem
extends Node

var settlements: Array[Settlement] = []

class Settlement:
	var position: Vector3
	var name: String
	var npcs: Array[NPCBase] = []
	var buildings: Array[Node3D] = []
	var water_accessible: bool = false

func generate_settlements(chunk_manager, world_seed: int):
	# Use deterministic noise to place settlements
	var noise = FastNoiseLite.new()
	noise.seed = world_seed

	var settlement_chance = 0.05  # 5% chance per region

	# Sample world for settlement sites
	for region_x in range(-10, 10):
		for region_y in range(-10, 10):
			var noise_val = noise.get_noise_2d(region_x * 100, region_y * 100)

			if noise_val > 0.5 and randf() < settlement_chance:
				var settlement = Settlement.new()
				settlement.position = Vector3(region_x * 100, 0, region_y * 100)
				settlement.name = "Settlement_%d_%d" % [region_x, region_y]
				settlement.water_accessible = _is_near_water(settlement.position, chunk_manager)

				_spawn_settlement_npcs(settlement, chunk_manager)
				settlements.append(settlement)

func _spawn_settlement_npcs(settlement: Settlement, chunk_manager):
	# Spawn 3-5 merchants per settlement
	for i in range(randi_range(3, 5)):
		var merchant = preload("res://scenes/npcs/Merchant.tscn").instantiate()
		merchant.npc_id = "merchant_%s_%d" % [settlement.name, i]
		merchant.display_name = "Merchant " + str(i)
		merchant.home_position = settlement.position + Vector3(i * 5, 0, 0)
		merchant.global_position = merchant.home_position
		merchant.merchant_id = merchant.npc_id

		get_tree().root.get_node("World").add_child(merchant)
		settlement.npcs.append(merchant)

func _is_near_water(position: Vector3, chunk_manager) -> bool:
	# Check if within 10 units of water
	var chunk = chunk_manager.get_chunk_at(int(position.x), int(position.z))
	if not chunk:
		return false

	var local_x = int(position.x) % 32
	var local_z = int(position.z) % 32

	for dx in range(-10, 10):
		for dz in range(-10, 10):
			var check_x = local_x + dx
			var check_z = local_z + dz

			if 0 <= check_x < 32 and 0 <= check_z < 32:
				if chunk.biome_map[check_z * 32 + check_x] == "water":
					return true

	return false
```

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
var waterways = WaterwaysSystem.new()
var water_classification = waterways.classify_water_bodies(heightmap, chunk_x, chunk_y)

# Results: {position: {type: "creek", width: 1}, ...}
# Types: creek, stream, river, lake, ocean
```

## Water System & Waterways Implementation

### Water System Manager

```gdscript
# src/core/water/water_system.gd
class_name WaterSystem
extends Node

var chunk_manager: ChunkManager
var waterways: WaterwaysSystem
var water_data: Dictionary = {}  # {chunk_key: water_info}

func _ready():
	chunk_manager = get_tree().root.get_node("World/ChunkManager")
	waterways = WaterwaysSystem.new()
	waterways.seed = chunk_manager.world_seed

func get_water_at_position(world_pos: Vector3) -> Dictionary:
	# Returns water info at position: {type: "creek", depth: 0.5, current_strength: 0.2}
	var chunk_x = int(world_pos.x) / 32
	var chunk_y = int(world_pos.z) / 32
	var local_x = int(world_pos.x) % 32
	var local_z = int(world_pos.z) % 32

	var key = "%d_%d" % [chunk_x, chunk_y]
	if not water_data.has(key):
		water_data[key] = _generate_water_data(chunk_x, chunk_y)

	var chunk_water = water_data[key]
	if chunk_water["map"].has(local_z * 32 + local_x):
		return chunk_water["map"][local_z * 32 + local_x]

	return {"type": "none", "depth": 0.0}

func is_in_water(world_pos: Vector3) -> bool:
	var water = get_water_at_position(world_pos)
	return water["type"] != "none"

func is_ford_capable(water_type: String) -> bool:
	# Which water types can be waded through
	return water_type in ["creek", "shallow_water", "ford"]

func is_navigable_by_canoe(water_type: String) -> bool:
	# Which water types can be navigated with canoe
	return water_type in ["creek", "stream", "river", "lake"]

func _generate_water_data(chunk_x: int, chunk_y: int) -> Dictionary:
	# Use Waterways to classify water bodies
	var chunk = chunk_manager.load_or_generate_chunk(chunk_x, chunk_y)
	var water_map = waterways.classify_water_bodies(chunk.heightmap, chunk_x, chunk_y)

	return {
		"chunk_x": chunk_x,
		"chunk_y": chunk_y,
		"map": water_map,
		"generated_time": Time.get_ticks_msec()
	}

func get_water_flow_velocity(world_pos: Vector3) -> Vector3:
	# Returns water flow velocity (used for canoe mechanics)
	var water = get_water_at_position(world_pos)

	if water["type"] == "none":
		return Vector3.ZERO

	# Flow direction based on position (simplified; real impl would use heightmap)
	var flow_strength = 0.0
	match water["type"]:
		"creek":
			flow_strength = 0.5
		"stream":
			flow_strength = 1.0
		"river":
			flow_strength = 1.5
		"lake":
			flow_strength = 0.0  # Lakes don't flow

	if flow_strength == 0:
		return Vector3.ZERO

	# Simple downhill flow based on nearby heightmap
	# In real implementation, use DEM gradient
	var flow_dir = Vector3(0.2, 0, 0.1).normalized()  # Placeholder
	return flow_dir * flow_strength
```

### Canoe Navigation System

```gdscript
# src/core/water/canoe_system.gd
class_name CanoeSystem
extends Node

var player: Player
var water_system: WaterSystem
var is_in_canoe: bool = false
var canoe_speed: float = 4.0
var canoe_acceleration: float = 10.0
var canoe_max_speed: float = 6.0

func _ready():
	player = get_tree().root.get_node("Player")
	water_system = get_tree().root.get_node("World/WaterSystem")

func _physics_process(delta: float) -> void:
	if not is_in_canoe:
		return

	var water = water_system.get_water_at_position(player.global_position)
	if not water_system.is_navigable_by_canoe(water["type"]):
		exit_canoe()
		return

	_update_canoe_movement(delta, water)

func _update_canoe_movement(delta: float, water: Dictionary) -> void:
	var input_dir = Input.get_vector("ui_right", "ui_left", "ui_down", "ui_up")
	var flow_velocity = water_system.get_water_flow_velocity(player.global_position)

	# Player paddling
	var paddle_velocity = Vector3(input_dir.x, 0, input_dir.y) * canoe_speed
	var effective_velocity = paddle_velocity + flow_velocity

	# Apply current/flow effects
	if water["type"] == "river":
		effective_velocity = effective_velocity.lerp(flow_velocity, 0.3)

	effective_velocity = effective_velocity.limit_length(canoe_max_speed)
	player.velocity = effective_velocity

	player.velocity = player.move_and_slide(player.velocity)

	# Stamina drain (paddling)
	if input_dir.length() > 0.1:
		player.stamina -= 5.0 * delta  # Paddle drain

func enter_canoe(canoe: Node3D):
	is_in_canoe = true
	print("Entered canoe")
	player.can_move = false

func exit_canoe():
	is_in_canoe = false
	print("Exited canoe")
	player.can_move = true
	player.velocity = Vector3.ZERO
```

### Fishing System

```gdscript
# src/core/water/fishing_system.gd
class_name FishingSystem
extends Node

var player: Player
var water_system: WaterSystem

const FISH_SPECIES = {
	"trout": {
		"spawn_chance": 0.6,
		"biome_preference": ["temperate_forest", "boreal_forest"],
		"water_type": ["stream", "river"],
		"size_range": [1, 3],
		"xp": 15
	},
	"bass": {
		"spawn_chance": 0.5,
		"biome_preference": ["grasslands", "deciduous_forest"],
		"water_type": ["lake", "river"],
		"size_range": [2, 4],
		"xp": 20
	},
	"pike": {
		"spawn_chance": 0.3,
		"biome_preference": ["wetlands", "boreal_forest"],
		"water_type": ["lake"],
		"size_range": [3, 5],
		"xp": 30
	},
	"salmon": {
		"spawn_chance": 0.4,
		"biome_preference": ["temperate_forest"],
		"water_type": ["river"],
		"size_range": [2, 4],
		"xp": 25
	}
}

func _ready():
	player = get_tree().root.get_node("Player")
	water_system = get_tree().root.get_node("World/WaterSystem")

func can_fish_here(world_pos: Vector3) -> bool:
	var water = water_system.get_water_at_position(world_pos)
	return water["type"] in ["creek", "stream", "river", "lake"]

func fish(biome: String, water_type: String, duration: float = 10.0) -> Dictionary:
	# Returns caught fish or empty dict if nothing caught
	var valid_fish = []

	for fish_type in FISH_SPECIES.keys():
		var species = FISH_SPECIES[fish_type]

		if biome in species["biome_preference"] and water_type in species["water_type"]:
			if randf() < species["spawn_chance"]:
				valid_fish.append(fish_type)

	if valid_fish.size() == 0:
		return {}

	# Fish based on player skill
	var fishing_skill = player.get_skill("fishing")
	var catch_chance = (fishing_skill / 100.0) * 0.8 + 0.2  # 20% to 100%

	if randf() > catch_chance:
		return {}  # Didn't catch anything

	# Caught a fish
	var caught_type = valid_fish[randi() % valid_fish.size()]
	var species = FISH_SPECIES[caught_type]
	var size = randi_range(species["size_range"][0], species["size_range"][1])

	return {
		"type": caught_type,
		"size": size,
		"item_id": "%s_%d" % [caught_type, size]
	}

func catch_fish_with_animation(duration: float = 10.0) -> bool:
	var world_pos = player.global_position
	var water = water_system.get_water_at_position(world_pos)

	if not can_fish_here(world_pos):
		return false

	# Animate fishing (wait duration)
	var time_remaining = duration
	while time_remaining > 0:
		await get_tree().process_frame
		time_remaining -= get_physics_process_delta_time()

		# Drain stamina while fishing
		player.stamina -= 2.0 * get_physics_process_delta_time()

	# Check if still in valid water
	var current_water = water_system.get_water_at_position(world_pos)
	if not can_fish_here(world_pos):
		return false

	# Fish
	var caught = fish(player.current_biome, current_water["type"], duration)
	if caught.size() > 0:
		player.inventory.add_item(caught["item_id"], 1)
		player.gain_xp("fishing", FISH_SPECIES[caught["type"]]["xp"])
		print("Caught: %s (size %d)" % [caught["type"], caught["size"]])
		return true

	return false
```

### Water Physics & Hazards

```gdscript
# Add to Player or separate WaterPhysicsSystem
func apply_water_effects(water: Dictionary, delta: float):
	match water["type"]:
		"none":
			return

		"creek", "ford", "shallow_water":
			# Slow movement
			terrain_speed_modifier = 0.5
			# Slight cold effect
			needs_system.warmth -= 0.1 * delta

		"stream", "river":
			# Fast movement penalty + current push
			terrain_speed_modifier = 0.4
			velocity += water_system.get_water_flow_velocity(global_position) * delta
			needs_system.warmth -= 0.2 * delta

		"deep_water", "lake":
			# Check if drowning
			if not has_canoe_equipment():
				# Drowning
				if needs_system.health > 0:
					needs_system.health -= 10.0 * delta
				print("WARNING: DROWNING")

func has_canoe_equipment() -> bool:
	# Check if player has canoe or life jacket
	return inventory.has_item("canoe", 1) or inventory.has_item("life_jacket", 1)
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
