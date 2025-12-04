# Biome System Design Document - Story 2.1

## Overview

The Biome System creates 7 unique environments, each with distinct resource distribution, difficulty, and gameplay characteristics. Biomes are assigned deterministically using noise + elevation, ensuring reproducible world generation across sessions.

## Architecture

### Core Components

**BiomeDefinition** (`biome_data.gd`)
- Resource class storing biome properties
- 7 instantiated resources (Coastal Atlantic, Temperate Forest, Deciduous Forest, Grasslands, Appalachian Mountains, Boreal Forest, Wetlands)
- Properties: spawn_rates, forage_items, huntable_animals, terrain_types, base_temperature, difficulty_tier, seasonal_variations

**BiomeGenerator** (`biome_generator.gd`)
- Assigns biome types deterministically using 2D Perlin noise + heightmap elevation
- Selects terrain type within biome based on local height
- Provides movement speed modifiers per terrain
- Validated for determinism

**BiomeDefinitions** (`biome_defs.gd`)
- Utility class providing static access to biome data
- Loads all biome resources on initialization
- Methods: get_spawn_rates(), get_density(), get_base_temperature(), get_forage_items(), etc.

**BiomeProperties** (`biome_properties.gd`)
- Gameplay mechanics handlers
- Temperature effects on stamina/health
- Difficulty adjustments and resource scarcity
- Danger levels and visibility modifiers

**BiomeVisuals** (`biome_visuals.gd`)
- Visual configuration and sprite mapping
- Seasonal variants with color/brightness adjustments
- Tree type selection per biome

**BiomeResourceSpawner** (`biome_resource_spawner.gd` - from Story 1.3)
- Spawns WorldObjects using biome spawn_rates
- Deterministic per chunk via seeded PRNG
- Integrated with biome definitions

## Biome Details

### Coastal Atlantic
- **Temperature:** +2°C
- **Difficulty:** Moderate
- **Resources:** Kelp, shells, sea grass, seals
- **Forage:** Kelp, shells, crabs, fish, salt
- **Movement:** Rocky shore 0.6x, sand beach 0.9x
- **Unique:** Water navigation available

### Temperate Forest
- **Temperature:** 0°C (baseline)
- **Difficulty:** Easy (most forgiving)
- **Resources:** Maple, oak trees, mushrooms, berries
- **Forage:** Berries, mushrooms, roots, seeds, nuts, herbs
- **Movement:** Dense forest 0.7x, sparse forest 0.9x
- **Best for:** Starting players

### Deciduous Forest
- **Temperature:** -1°C
- **Difficulty:** Easy
- **Resources:** Birch, aspen trees, mushrooms
- **Forage:** Mushrooms, berries, bark, leaves, herbs
- **Movement:** Dense birch 0.75x, aspen grove 0.85x
- **Note:** Visual seasonal variation (spring budding → winter bare)

### Grasslands
- **Temperature:** +1°C
- **Difficulty:** Easy
- **Resources:** Sparse trees, grains, wildflowers
- **Forage:** Grains, wildflowers, roots, seeds, berries
- **Movement:** Tall grass 0.9x, short grass 1.1x (fastest terrain)
- **Unique:** Best visibility (1.2x)

### Appalachian Mountains
- **Temperature:** -5°C (cold)
- **Difficulty:** Hard (most challenging)
- **Resources:** Pine, spruce, rare herbs
- **Forage:** Rare herbs, lichen, mountain berries
- **Movement:** Rocky peak 0.5x (slowest), meadow 0.8x
- **Unique:** Harsh but resource-rich for prepared players

### Boreal Forest
- **Temperature:** -8°C (very cold)
- **Difficulty:** Hard
- **Resources:** Spruce, fir trees, lichen
- **Forage:** Lichen, berries, mushrooms, pine nuts
- **Movement:** Dense taiga 0.6x, spruce stand 0.75x
- **Unique:** Very dense, reduced visibility

### Wetlands
- **Temperature:** -2°C
- **Difficulty:** Moderate
- **Resources:** Willows, cattails, water plants
- **Forage:** Cattails, reeds, water plants, marsh berries, fish
- **Movement:** Deep marsh 0.4x (very slow), shallow water 0.6x
- **Unique:** Water navigation, hazardous terrain

## Biome Assignment Algorithm

```
elevation_0.0_to_0.2 → Coastal Atlantic
elevation_0.2_to_0.4 → Noise-based: Deciduous/Temperate/Grasslands
elevation_0.4_to_0.7 → Noise-based: Temperate/Boreal/Grasslands
elevation_0.7_to_1.0 → Noise-based: Mountains/Boreal
```

**Determinism:** `chunk_seed = world_seed ^ (chunk_x << 16) ^ chunk_y`

Same inputs always produce same biome, enabling:
- World reproducibility from seed
- Consistent cross-session exploration
- Reliable testing and development

## Gameplay Integration

### Temperature System
```
Player exposed temperature = biome.base_temperature
Health drain modifier = 1.0 - (temperature / 30.0), clamped 0.5-1.5
Stamina regen modifier = max(0.5, 1.0 + (temperature / 20.0))
```

Cold biomes:
- Increase health drain (starvation/hypothermia)
- Reduce stamina regeneration
- Require thermal management (fire, shelter)

### Difficulty Tiers
- **Easy:** Abundant resources, moderate temperature, high visibility
- **Moderate:** Balanced resources, variable temperature, normal visibility
- **Hard:** Scarce resources, cold temperature, reduced visibility

### Movement System
Terrain type within biome affects movement speed:
- Dense forest: 0.7x (terrain difficulty)
- Grassland: 1.0-1.1x (easy movement)
- Rocky terrain: 0.5x (very difficult)

### Resource Scarcity
```
easy_biome → 0.8x spawn (abundance)
moderate_biome → 1.0x spawn
hard_biome → 1.3x spawn (scarcity)
```

Hard biomes compensate with rare resources (mountain herbs, quality ore).

## Seasonal Variations

All biomes support 4 seasons with spawn rate modifiers:
- **Spring:** 1.3-1.5x (growth period)
- **Summer:** 1.4-1.5x (peak abundance)
- **Fall:** 0.7-1.0x (harvest decline)
- **Winter:** 0.2-0.4x (resource scarcity)

Visual variants defined per biome (implemented in Story 2.4).

## Testing

**Unit Tests** (`test_biome_system.gd`):
- Biome assignment correctness
- Determinism validation (10+ chunks)
- Terrain type assignment
- Movement speed modifiers
- Spawn rates configuration
- Temperature tracking
- Seasonal modifiers

**Integration Tests** (`test_biome_integration.gd`):
- Complete chunk generation
- Biome transitions
- Difficulty affects availability
- Seasonal variations
- Animal distribution
- Visual properties
- Large-scale consistency (11x11 world)

**Performance Targets:**
- Biome assignment: < 50ms per chunk
- Resource spawning: < 100ms per chunk
- Memory: < 1MB per biome definition

## Future Work (Post-MVP)

1. **Story 2.2 (Water System):** River generation, water routing based on biome
2. **Story 2.4 (Seasons):** Visual variants, seasonal weather effects
3. **Story 3.x (Survival):** Integration with hunger, disease from biome hazards
4. **Biome Variants:** Introduce biome subtypes (tropical vs temperate forest)
5. **Climate Zones:** Global temperature gradients (equator warmer than poles)

## References

- **Architecture:** docs/game-architecture.md (Biome System section)
- **Epics:** docs/epics.md (Story 2.1 context)
- **GPU Terrain:** docs/sprint-artifacts/tech-spec-phase1-core-prototype.md
- **Story 1.4:** docs/sprint-artifacts/1-4-chunk-manager-streaming.md (chunk system learnings)
