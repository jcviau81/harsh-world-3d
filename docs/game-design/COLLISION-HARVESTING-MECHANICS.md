# Collision & Harvesting Mechanics (Godot 3D Engine)

**Project:** Harsh New World
**Date:** 2025-11-19
**Updated:** 2025-12-02 (Godot 3D Engine Context)
**Purpose:** Define how trees, resources, and player interaction work in the 3D engine environment

---

## Quick Summary

**16x16 pixel tiles. Trees/rocks = BLOCKING. Player stands adjacent to harvest.**

---

## The Mechanics

### 1. Features with Collision (BLOCKING)

Trees, rocks, and cave entrances **occupy their tile** and block movement.

```
Tile (100, 50) has a Tree:
  feature_type: "tree"
  walkable: FALSE (blocked)
  resource_type: "wood"
  resource_amount: 5

Player cannot move to (100, 50) - BLOCKED by tree collision
```

### 2. Adjacent-Based Interaction

Player can only interact with blocking features from **adjacent tiles** (1 tile away in cardinal directions).

```
Tree at (100, 50):

Valid adjacent tiles (can interact from here):
  ✓ (99, 50)  - left of tree
  ✓ (101, 50) - right of tree
  ✓ (100, 49) - above tree
  ✓ (100, 51) - below tree

Invalid (too far):
  ✗ (99, 49)  - diagonal (not adjacent)
  ✗ (102, 50) - 2 tiles away
  ✗ (100, 50) - ON the tree (blocked)
```

### 3. Resource Harvesting Flow

**Step 1: Player Movement**
```
Player at (98, 50)
Press "move right" → Player moves to (99, 50)

Now player is ADJACENT to tree at (100, 50)
```

**Step 2: Player Interaction**
```
Player at (99, 50) (adjacent to tree)
Press 'E' (interact) → Harvest resource

What happens:
  - Check: Is there a tree at (100, 50)? YES
  - Check: Am I adjacent? YES (1 tile away)
  - Check: Does it have resources? YES (wood x 5)

  HARVEST:
    - Take 1 wood
    - Tree's resource_amount: 5 → 4
    - Add wood to player inventory
```

**Step 3: Repeat or Move**
```
Press 'E' again → Harvest another wood (wood x 4)
Press 'E' again → Harvest another wood (wood x 3)

Eventually:
  - Wood depleted (resource_amount = 0)
  - Tree still blocks the tile
  - Tree is now "harvested" / "dead"
```

---

## Collision System Details

### What BLOCKS Movement

**Trees:**
- Occupy tile
- Have collision
- Can harvest adjacent
- Resource: wood

**Rocks:**
- Occupy tile
- Have collision
- Cannot harvest (rocks are permanent obstacles)
- No resource (or rare minerals only in mountains)

**Cave Entrances:**
- Occupy tile
- Have collision
- Might trigger dungeon entry (future)
- No standalone resource

### What Doesn't Block

**Empty Tiles:**
- "none" feature
- Walkable
- No interaction

---

## Movement Resolution

**Player Input:** "Move to (100, 50)"

**System Check:**
```
tile_at_destination = world.get_tile(100, 50)

if tile_at_destination.walkable == true:
  if tile_at_destination.entity_id == null:
    // Safe to move
    player.position = (100, 50)
  else:
    // Occupied (enemy, item, NPC)
    // Movement fails or trigger interaction
else:
  // Tile is blocked (tree, rock, cave)
  // Movement fails (or trigger interaction if adjacent)
```

---

## Interaction System

**Player at adjacent tile, presses 'E':**

```
adjacent_tiles = [
  (player_x - 1, player_y),
  (player_x + 1, player_y),
  (player_x, player_y - 1),
  (player_x, player_y + 1)
]

for tile in adjacent_tiles:
  if tile.has_blocking_feature:
    if tile.has_resources:
      // Can harvest
      show_interaction_prompt("E to harvest wood")
    else:
      // Cannot harvest (rock, cave)
      show_interaction_prompt("E to interact")

// On player press 'E':
if tile.resource_amount > 0:
  player.inventory.add(tile.resource_type, 1)
  tile.resource_amount -= 1
```

---

## Game Flow Example

### Scenario: Harvesting a Tree

**Initial State:**
```
Forest biome, coordinates:
  Tile (50, 50): Empty ground, walkable
  Tile (51, 50): Tree, NOT walkable, wood x 5
  Tile (52, 50): Empty ground, walkable
```

**Player Actions:**
```
1. Player at (49, 50)
   Action: Move right
   Result: Move to (50, 50) ✓ walkable

2. Player at (50, 50)
   Action: Move right
   Result: Try move to (51, 50) → BLOCKED by tree ✗

3. Player at (50, 50)
   Action: Move right (again)
   Result: Still blocked ✗

4. Player at (50, 50)
   Action: Interact (press 'E')
   Check: Are adjacent tiles interactable?
   Result: YES - tree at (51, 50) is adjacent
   Prompt: "E to harvest wood"

5. Player at (50, 50)
   Action: Press 'E' to harvest
   Result:
     - Harvest 1 wood
     - Add to inventory
     - Tree resource_amount: 5 → 4
     - Prompt shows "4 wood remaining"

6. Press 'E' multiple times
   Result: Wood x 4 → x 3 → x 2 → x 1 → x 0

7. After last harvest:
   Prompt: "Tree fully harvested"
   Tree remains (blocking tile)
   Tree has no more resources
```

---

## Implementation Considerations

### Tile Data Structure
```gdscript
class TileData:
  feature_type: String          # "tree", "rock", "cave", "none"
  walkable: bool                # Determined by feature
  resource_type: String         # "wood", "ore", etc.
  resource_amount: int          # Quantity available

  // Collision
  has_collision: bool           # true if feature blocks
```

### Movement System
```gdscript
func can_move_to(destination: Vector2i) -> bool:
  tile = world.get_tile(destination)
  return tile.walkable and tile.entity_id == null
```

### Interaction System
```gdscript
func get_adjacent_tiles(position: Vector2i) -> Array[Vector2i]:
  return [
    position + Vector2i(-1, 0),  # left
    position + Vector2i(1, 0),   # right
    position + Vector2i(0, -1),  # up
    position + Vector2i(0, 1)    # down
  ]

func try_harvest(player_pos: Vector2i):
  for adjacent_tile_pos in get_adjacent_tiles(player_pos):
    tile = world.get_tile(adjacent_tile_pos)
    if tile.resource_amount > 0:
      player.inventory.add(tile.resource_type, 1)
      tile.resource_amount -= 1
```

---

## Visual Feedback

### Walkable vs Non-Walkable Tiles

**Walkable (can move here):**
- Clear green/brown terrain
- No blocking sprite
- Transparent/pathable

**Non-Walkable (blocked):**
- Tree sprite overlaid (clearly visible)
- Rock sprite (clearly solid)
- Red tint or "X" indicator (optional)

### Adjacent Interaction Prompt

When player stands adjacent to interactable tile:
```
┌─────────────────┐
│ 🌳 Oak Tree     │
│ Wood x4 left    │
│ Press E to ↓    │
└─────────────────┘
```

---

## Edge Cases Handled

**Q: Can player push/move a tree?**
A: No. Trees are permanent world fixtures. Cannot be destroyed, only harvested.

**Q: What if player stands diagonal from tree?**
A: No adjacency. Cannot interact with tree from diagonal.

**Q: Can multiple players harvest same tree?**
A: Yes (if multiplayer later). Each harvests 1 at a time. Resource depletes.

**Q: What if resources respawn?**
A: Configurable per resource. Some respawn over time, some are one-time pickups.

**Q: Can enemies block tiles?**
A: Yes. Enemies occupy tiles, block movement, but no harvesting.

---

## Tile Scale Reference

**At 16x16 pixels per tile:**
- 1 tree = 1 tile of space
- Forest: Many trees = many blocked tiles
- Open area: Walkable tiles dominate
- Mountain: Mostly blocked (rocks, caves)

**Viewing Area (1080p):**
- ~67 tiles width x ~60 tiles height visible
- Player sees ~4000 tiles on screen
- Balance of walkable vs blocked for exploration

---

## Summary

✓ **Blocking collision** for trees/rocks
✓ **Adjacent harvesting** from 1 tile away
✓ **Resource depletion** over multiple interactions
✓ **Clear visual distinction** walkable vs blocked
✓ **Simple interaction system** press 'E' when adjacent
✓ **Tile-based movement** no diagonal adjacency

This creates engaging roguelike gameplay: explore, find resources, harvest adjacent, manage inventory.

