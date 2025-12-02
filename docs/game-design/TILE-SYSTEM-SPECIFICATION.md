# Tile-Based World System Specification (3D Engine)

**Project:** Harsh New World
**Date:** 2025-11-19
**Updated:** 2025-12-02 (Godot 3D Engine + GridMap)
**Status:** Updated for 3D rendering pipeline
**Purpose:** Define tile system for object placement and gameplay using Godot 3D engine

---

## Tile System Overview

The world is **strictly tile-based** in logical structure to enable roguelike gameplay mechanics (object placement, turn-based logic, grid-based movement), implemented using Godot's 3D engine with GridMap concepts for efficient rendering and GPU acceleration.

### Core Dimensions

**Tile Unit:**
- 1 tile = 1 game unit
- **Visual size: 16x16 pixels** (FIXED)
- All gameplay operates at tile granularity
- Player occupies 1 tile at a time

**Chunk Structure:**
- 1 chunk = 512x512 tiles
- Chunks tile seamlessly (no gaps, no overlaps)
- World = infinite grid of seamless chunks

**World Scale:**
- Seamless infinite world
- Player can traverse any direction indefinitely
- World coordinates map to tile coordinates directly

---

## Tile Data Structure

Each tile is a discrete unit with complete information:

```gdscript
class TileData:
  # Position in world (tile coordinates)
  world_x: int                     # Global tile X
  world_y: int                     # Global tile Y
  chunk_x: int                     # Which chunk (world_x // 512)
  chunk_y: int                     # Which chunk (world_y // 512)
  tile_x: int                      # Position in chunk (0-511)
  tile_y: int                      # Position in chunk (0-511)

  # Procedurally Generated Properties
  biome_type: String               # "forest", "desert", "mountain",
                                   # "coastal", "tundra", "polar"
  elevation: float                 # 0.0-1.0 range (terrain height)
  feature_type: String             # "cave", "tree", "rock", "none"

  # Tile-Based Gameplay
  walkable: bool                   # Can player/entities move here?
  entity_id: Optional[int]         # ID of entity on this tile (if any)
  resource_type: String            # "wood", "ore", "berries",
                                   # "mushroom", "salt", etc.
  resource_amount: int             # How much of resource available

  # Derived/Cached
  tile_sprite: String              # Sprite key for rendering
  tile_color: Color                # Color tint for rendering
```

---

## Tile Properties by Biome

### Forest
```
Walkable Tiles:     Grass, leaf litter, open areas
Non-Walkable:       Dense trees, thick brush
Features:           Trees (walkable-adjacent), caves (scattered)
Resources:          Wood (from trees), Berries (from bushes), Wildlife
Elevation Variance: Gentle rolling (0.3-0.7 range)
Visual:             Green palette, varied vegetation
```

### Desert
```
Walkable Tiles:     Sand, hard-packed earth
Non-Walkable:       Large rocks, dunes, quicksand
Features:           Rock formations, scattered oasis
Resources:          Minerals (from rocks), Cactus, Salt
Elevation Variance: Dunes and flats (0.2-0.8 range)
Visual:             Sand/golden palette, sparse vegetation
```

### Mountain
```
Walkable Tiles:     Rocky ground, some grass
Non-Walkable:       Cliffs, dense rock faces, caves
Features:           Cave systems, peaks, crevices
Resources:          Ore (from rocks), Crystals, Stones
Elevation Variance: Extreme (0.1-0.95 range, dramatic peaks)
Visual:             Gray/brown rocky palette
```

### Coastal
```
Walkable Tiles:     Beach sand, shallow water areas
Non-Walkable:       Deep water, rocky shores (somewhat)
Features:           Sandy beaches, tidal zones, rock outcrops
Resources:          Fish, Shells, Driftwood, Salt water
Elevation Variance: Gradual descent (0.8→0.2 approaching water)
Visual:             Sand-to-water transition, light colors
```

### Tundra
```
Walkable Tiles:     Frozen ground, sparse vegetation
Non-Walkable:       Deep snow, ice cracks, frozen lakes
Features:           Sparse ice formations, frozen hollows
Resources:          Rare (Lichen, Mushrooms, Ice)
Elevation Variance: Minimal (0.4-0.6 mostly flat)
Visual:             White/blue palette, harsh appearance
```

### Polar
```
Walkable Tiles:     Hardened ice, rocky outcrops
Non-Walkable:       Crevasses, thin ice, blizzard zones
Features:           Ice caves, glaciers, extreme terrain
Resources:          Scarce (Ice shards, rare minerals)
Elevation Variance: Minimal variation, mostly flat
Visual:             Pure white/ice blue, barren
```

---

## Collision & Blocking System

### Features with Collision

**Trees, Rocks, Cave Entrances = BLOCKING**
- These features occupy the tile
- Player cannot move onto this tile
- Player **can stand adjacent** to harvesting/interacting

### Example: Tree on Tile (100, 50)
```
Player at (99, 50) or (101, 50) or (100, 49) or (100, 51):
  - Can reach/interact with tree
  - Can harvest resources
  - Can trigger interactions

Player attempts (100, 50):
  - BLOCKED - tree occupies tile
  - Movement fails
```

### Adjacency-Based Resource Harvesting

**Mechanic:**
1. Resource is on a tile (e.g., "wood" from tree)
2. Tree blocks that tile (collision = true)
3. Player stands **adjacent** to tree (1 tile away, all 4 directions)
4. Player can "interact" / "harvest" the resource
5. Resource depletes from that tile

**Resource Collection Example:**
```
Map layout:
  [Tree at 100,50: wood x 5]

Player movement:
  Move to (99, 50) - adjacent to tree, success

Player action:
  Press 'E' to interact
  → Harvest 1 wood from (100, 50)
  → Tree's resource_amount = 4

  Press 'E' again
  → Harvest 1 wood
  → Tree's resource_amount = 3

  Repeat until empty
  → Tree remains but resource_amount = 0
```

---

## Walkability Rules

### Determined By:
1. **Feature Type** (primary)
   - "none" = walkable (empty ground)
   - "tree" = **NON-WALKABLE** (blocks movement, collision active)
   - "rock" = **NON-WALKABLE** (blocks movement, collision active)
   - "cave" = **NON-WALKABLE** (cave entrance, blocks movement)

2. **Biome Rules** (secondary)
   - Some biomes have inherently unwalkable areas
   - Water tiles in coastal/tundra are non-walkable
   - Extreme slopes in mountain = non-walkable

3. **Elevation** (tertiary, for gameplay feel)
   - Very high elevations in mountains might be risky
   - Very low elevations might be water/swamps

### Result:
- Each tile: `walkable = true` or `false`
- Player can only move to walkable tiles
- Physics/collision system respects walkability

---

## Entity Slots

Each tile has **one entity slot** for gameplay objects:

```gdscript
entity_id: Optional[int]

// Can hold exactly one of:
// - Player (special case)
// - Enemy
// - NPC
// - Item pickup
// - Structure/obstacle
// - Resource node (tree, ore vein, etc.)
```

### Entity Placement Rules:
1. Only 1 entity per tile
2. Entities take up the tile space
3. Can only place on walkable tiles (usually)
4. Entities can be: enemies, NPCs, items, structures, resources

### Example Scenarios:
```
Forest Tile with Tree at (100, 50):
  Biome: Forest
  Elevation: 0.5
  Feature: Tree
  Walkable: false (BLOCKED - tree occupies this tile, collision active)
  Entity: null (no entity on this tile yet)
  Resource: "wood" (x5 units available)

  Player can:
    - Stand at (99,50), (101,50), (100,49), or (100,51) - ADJACENT
    - Interact: Press 'E' to harvest wood
    - Cannot: Move to (100,50) - BLOCKED by tree collision

Desert Tile:
  Biome: Desert
  Elevation: 0.7
  Feature: Rock
  Walkable: false (rock blocks movement)
  Entity: null
  Resource: "mineral" (ore in the rock)

Mountain Tile:
  Biome: Mountain
  Elevation: 0.95 (peak)
  Feature: Cave
  Walkable: false (cave entrance, needs interaction)
  Entity: null
  Resource: "ore"

Coastal Tile:
  Biome: Coastal
  Elevation: 0.3
  Feature: none
  Walkable: true
  Entity: null (or could have item pickup)
  Resource: "fish" (water-based resource)
```

---

## Rendering System

### Tile Rendering (in Godot 3D Engine)

**Visual Composition (per tile) - Rendered as 3D quads with 2D textures:**

```
Layer 1 (Base Terrain):
  - Biome color/sprite as textured quad
  - Determined by biome_type
  - Positioned in 3D space via GridMap

Layer 2 (Elevation):
  - Shading based on elevation
  - Higher = lighter, Lower = darker (rough terrain)
  - Applied via shader on base quad

Layer 3 (Feature):
  - Feature sprite overlaid as secondary quad
  - Tree, rock, cave entrance, etc.
  - Positioned as 3D quad above base layer
  - Some features are overlays, some replace base

Layer 4 (Entity):
  - If entity_id is set, render entity sprite quad
  - Entities rendered on top of terrain quad
  - Positioned in 3D space

Layer 5 (Visual Effects):
  - GPU-accelerated particle systems for effects
  - Animations via AnimationPlayer
  - Walkability indicator if needed
```

### Tile Size (16x16 pixels):
- **16x16 is FIXED** for this project
- Small detailed tiles = 512 x 512 tiles per chunk = 8192 x 8192 pixels per chunk
- At typical 1080p resolution: shows ~67x60 tiles on screen
- Good balance between detail and performance
- Allows precise resource placement and collision

### Rendering Performance (3D Engine):
- Only visible tiles render (viewport culling via ChunkStreamingManager)
- Tiles rendered as 3D quads with GPU-accelerated batching
- GridMap system provides efficient grid-based rendering
- 3D engine's shader system allows for GPU-accelerated effects and lighting
- Godot 3D rendering highly optimized for modern GPUs

---

## Coordinate System

### Tile Coordinates:
```
Origin (0, 0) = center of map (can be anywhere)

X increases to the right
Y increases downward

Player position (50, 75) = specific tile 50 units right, 75 units down
```

### Chunk Coordinates:
```
Chunk containing tile (x, y):
  chunk_x = x // 512
  chunk_y = y // 512

Tile within chunk:
  tile_x = x % 512
  tile_y = y % 512

Reverse (get world coords from chunk + tile):
  world_x = chunk_x * 512 + tile_x
  world_y = chunk_y * 512 + tile_y
```

### Movement:
```
Player at (100, 50)

Move right: Player moves to (101, 50)
Move down: Player moves to (100, 51)
Move diagonally: Player moves to (101, 51) [if diagonal movement enabled]

Only move if destination tile is walkable
```

---

## Resource System

Resources are **tied to tiles** for collection and gameplay:

```gdscript
resource_type: String      // "wood", "ore", "berries", etc.
resource_amount: int       // Quantity remaining

// On resource collection:
resource_amount -= collected_amount
if resource_amount <= 0:
  resource_type = "none"
  // Tile becomes empty
```

### Resources by Biome:
**Forest:** Wood, Berries, Mushrooms
**Desert:** Minerals, Salt, Cactus
**Mountain:** Ore, Crystals, Stones
**Coastal:** Fish, Shells, Driftwood
**Tundra:** Lichen, Mushrooms (scarce)
**Polar:** Ice Shards (very scarce)

### Respawn:
- Resources can respawn over time (configurable per resource)
- Or be one-time pickups (for narrative items)

---

## Editor & Gameplay Integration

### Placing Objects:
```gdscript
// Place enemy on tile at (150, 200)
if world.get_tile(150, 200).walkable:
  world.get_tile(150, 200).entity_id = enemy.id
  enemy.position = world.tile_to_world_position(150, 200)

// Place item on tile
if world.get_tile(x, y).entity_id == null:
  world.get_tile(x, y).entity_id = item.id

// Check if can move player to tile
if world.get_tile(new_x, new_y).walkable and
   world.get_tile(new_x, new_y).entity_id == null:
  player.move_to(new_x, new_y)
```

### Movement Resolution:
1. Player presses move key (up/down/left/right)
2. Calculate destination tile
3. Check if walkable
4. Check if unoccupied (no entity)
5. If both true: move player
6. If false: no movement (or trigger interaction)

---

## Performance Considerations

**Chunk Size (512x512):**
- Chunk size = 512x512 tiles
- At 16x16 pixels per tile = 8192 x 8192 pixels per chunk
- Holds 262,144 tile data structures

**Memory per Chunk:**
- ~5-10 MB per chunk (depending on tile data size)
- Keep 3x3 chunk grid loaded (9 chunks) = ~50-90 MB
- Reasonable for modern devices

**Rendering Performance:**
- Only visible portion renders
- Typical viewport = 67x60 tiles (on screen at 1080p)
- Batch rendering handles efficiently

**Update Performance:**
- Tile updates (resource collection, entity placement) = constant time
- No global updates needed
- Highly scalable

---

## Future Extensions

The tile system supports:
- **Turn-based mechanics** (each action = 1 tile movement)
- **Line-of-sight** (calculate visible tiles from position)
- **Pathfinding** (A* on walkable tile grid)
- **Fog of War** (track explored tiles)
- **Dynamic events** (earthquakes, weather affecting tile states)
- **Procedural dungeons** (tile-based cave systems)

---

## Summary

✓ Tile-based world enables precise object placement
✓ Each tile has complete data (terrain, features, entities, resources)
✓ Seamless infinite world via coordinate-based generation with GPU acceleration
✓ Walkability rules determine movement
✓ Entity slots allow rich gameplay interactions
✓ Rendering is tile-optimized for performance via Godot 3D engine
✓ GridMap-based structure enables GPU-accelerated chunk streaming
✓ Extensible for future gameplay systems
✓ GPU compute shaders generate terrain and noise for procedural terrain

This tile system, implemented in Godot's 3D engine with GPU acceleration, is the foundation for all gameplay mechanics in Harsh New World.

