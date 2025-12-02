# Harsh New World - Biome Specification
## Map Generation Blueprint (Godot 3D Engine)

**Purpose:** Guide GPU-accelerated procedural map generation for North American wilderness (late 1700s - early 1800s)
**Scope:** Continental scale with progressive difficulty from coast inland, implemented via GPU compute shaders in Godot 3D engine
**Status:** Quick Specification for Iterative Development
**Updated:** 2025-12-02 (Godot 3D Engine + GPU Acceleration)

---

## Biome Overview Map

```
[Arctic Tundra]
     ↓
[Boreal Forest] ← [Subarctic]
     ↓
[Temperate Forest] ← → [Great Lakes Region]
     ↓              ↓
[Coastal Atlantic] [Grasslands/Plains]
(EASY START)       ↓
                [Deciduous Forest]
                   ↓
              [Wetlands/Marsh]
              [Appalachian Mountains]
```

---

## Biome Progression (Easy → Hard)

| # | Biome | Difficulty | Region | Player Level | Starting Point |
|---|-------|-----------|--------|--------------|----------------|
| 1 | Coastal Atlantic | ⭐ | Eastern seaboard | Beginner | Yes |
| 2 | Temperate Forest | ⭐⭐ | Eastern inland | Early game | Adjacent to coast |
| 3 | Deciduous Forest | ⭐⭐ | Mid-Atlantic | Early game | Inland expansion |
| 4 | Great Lakes Region | ⭐⭐⭐ | Central | Mid game | Northwestern inland |
| 5 | Grasslands/Plains | ⭐⭐⭐ | Central/Western | Mid game | Western expansion |
| 6 | Appalachian Mountains | ⭐⭐⭐⭐ | Eastern highlands | Late game | Mountainous barrier |
| 7 | Wetlands/Marsh | ⭐⭐⭐ | Southern/scattered | Mid game | Low-lying areas |
| 8 | Boreal Forest | ⭐⭐⭐⭐ | Northern | Late game | Far north |
| 9 | Subarctic | ⭐⭐⭐⭐⭐ | Far north | Endgame | Extreme challenge |
| 10 | Arctic Tundra | ⭐⭐⭐⭐⭐ | Far far north | Endgame | Impossible without prep |

---


## Detailed Biome Specifications

### 1. COASTAL ATLANTIC (⭐ Easy Start)

**Geography:** Eastern seaboard (Maine to Carolina)
**Climate:** Temperate maritime, moderate seasons
**Difficulty:** Easiest - abundant resources, mild conditions

**Resources:**
- 🎣 Fish (abundant) - primary food source
- Frogs
- 🪵 Wood (dense forests nearby)
- 🧂 Salt (coastal salt marshes)
- 🦫 Beaver/Otter (moderate)
- 🌾 Wild grains (limited)
- 🪨 Stone (abundant)
- 🦪 Shellfish (clams, oysters - easy gathering)

**Weather/Climate:**
- Spring: 10-15°C, moderate rain, awakening
- Summer: 18-22°C, pleasant, low wind
- Autumn: 12-18°C, crisp, beautiful
- Winter: -5 to 0°C, snow moderate, some freezing rain

**Key Features:**
- ✅ River access (salmon runs)
- ✅ Tidal zones (rich resources)
- ✅ Easy food sources (fish, shellfish)
- ✅ Established European settlements
- ✅ Trade posts accessible

**Factions/Claims:**
- French colonial settlements
- English trading posts
- Pequot/Narragansett tribal lands
- Neutral trading zones

**Gameplay Feel:** Safe harbor, learning area, established society

---

### 2. TEMPERATE FOREST (⭐⭐ Early Game)

**Geography:** Eastern deciduous forests (inland from coast)
**Climate:** Humid continental, distinct seasons
**Difficulty:** Easy-moderate - good resources but more wildlife danger

**Resources:**
- 🪵 Wood (abundant - oak, maple, birch)
- 🦌 Deer (common hunting)
- 🦫 Beaver (good populations, valuable furs)
- 🌰 Nuts/Acorns (seasonal abundance)
- 🍄 Mushrooms (seasonal, varied)
- 🌾 Wild plants (berries, roots, medicinal)
- 🪨 Stone (moderate)

**Weather/Climate:**
- Spring: 5-12°C, rain, flooding possible
- Summer: 15-20°C, humid, occasional storms
- Autumn: 8-15°C, beautiful, harvest season
- Winter: -8 to -2°C, significant snow, harsh

**Key Features:**
- 🌲 Dense mixed forests
- 🏞️ Creeks and small rivers
- 🦅 Indigenous settlements nearby
- 📍 Point of interest clusters
- 🏘️ Scattered colonist camps

**Gameplay Feel:** Wilderness with familiar rules, first real survival challenges

---

### 3. DECIDUOUS FOREST (⭐⭐ Early-Mid Game)

**Geography:** Mid-Atlantic region (Pennsylvania to Virginia)
**Climate:** Humid subtropical transitioning to continental
**Difficulty:** Moderate - balanced resources and danger

**Resources:**
- 🪵 Wood (hardwoods - walnut, ash, hickory)
- 🦌 Deer (abundant)
- 🐻 Black bears (dangerous but valuable)
- 🦫 Beaver (moderate populations)
- 🌰 Chestnuts, walnuts, hickory nuts
- 🌾 Wild plants (ginseng, valuable)
- 🪨 Stone (good)
- 🌾 Tobacco (wild, valuable trade good)

**Weather/Climate:**
- Spring: 8-15°C, heavy rains, spring flooding
- Summer: 18-24°C, humid, afternoon storms
- Autumn: 10-18°C, extended beautiful season
- Winter: -5 to 2°C, variable (ice, rain, some snow)

**Key Features:**
- 🌳 Mixed deciduous and evergreen
- 💧 Rivers with moderate current
- 🏔️ Appalachian foothills visible
- 🏠 Colonial settlements begin
- 🗡️ Increased conflict zones

**Gameplay Feel:** The frontier - more danger, more opportunities, real settlement presence

---

### 4. GREAT LAKES REGION (⭐⭐⭐ Mid Game)

**Geography:** Around Great Lakes (Ontario, Michigan, Superior)
**Climate:** Continental, significant seasonal extremes
**Difficulty:** Moderate-hard - resource-rich but harsh winters

**Resources:**
- 🦫 Beaver (EXCELLENT - peak fur trade region)
- 🎣 Fish (pike, walleye, trout from lakes)
- 🪵 Wood (vast forests, softwoods dominant)
- 🦌 Deer (moderate)
- 🐻 Bears (various types, dangerous)
- 🦌 Moose (northern sections)
- 🪨 Stone (moderate)
- 🌾 Wild rice (aquatic, marsh areas)

**Weather/Climate:**
- Spring: 0-8°C, heavy snow melt, ice breaks
- Summer: 14-18°C, brief warm period, many insects
- Autumn: 5-12°C, early frost threat, beautiful
- Winter: -15 to -5°C, HARSH, heavy snow, ice storms

**Key Features:**
- 🌊 Large lakes (major travel routes)
- 🛶 Canoe travel essential
- 🏔️ Mixed boreal/temperate forests
- 🏘️ Major trading post hubs
- ❄️ Winter becomes serious threat

**Factions/Claims:**
- Huron-Wendat confederacy
- Ojibwe territories
- North West Company trading posts
- Hudson's Bay Company influence
- Independent fur trader routes

**Gameplay Feel:** Major hub for fur trading, winter becomes dangerous, canoe travel starts

---

### 5. GRASSLANDS/PLAINS (⭐⭐⭐ Mid-Late Game)

**Geography:** Central North America (Great Plains, prairies)
**Climate:** Continental, extreme seasonal variation
**Difficulty:** Hard - resource scarcity, weather extremes, vast distances

**Resources:**
- 🦬 Buffalo (massive herds, valuable but hard to hunt)
- 🦌 Elk (scattered)
- 🦡 Beaver (limited - prairie rivers only)
- 🌾 Prairie grass (limited use)
- 🪨 Stone (scarce)
- 🪵 Wood (very scarce - river valleys only)
- 🌾 Prairie plants (medicinal, seasonal)

**Weather/Climate:**
- Spring: 5-15°C, violent thunderstorms, tornadoes possible
- Summer: 20-28°C, dry, occasional drought, intense heat
- Autumn: 8-18°C, rapid cooling, early frost
- Winter: -15 to -5°C, blizzards, wind-chill extreme

**Key Features:**
- 📦 Vast open spaces (navigation by stars/landmarks)
- 💨 Constant wind
- 🏞️ River valleys with concentrated resources
- 🏕️ Scattered tribal encampments
- 🐴 Indigenous horse cultures
- 🏘️ Few European settlements

**Factions/Claims:**
- Lakota/Dakota/Nakota territories
- Cheyenne lands
- Comanche (southern)
- Crow Nation
- Spanish/French trading posts (rare)

**Gameplay Feel:** Extreme frontier, navigation challenges, resource scarcity forces planning, tribal cultures

---

### 6. APPALACHIAN MOUNTAINS (⭐⭐⭐⭐ Late Game)

**Geography:** Appalachian mountain chain (north to south)
**Climate:** Temperate mountain, highly variable by altitude
**Difficulty:** Hard - navigation, isolation, resource limitations at height

**Resources:**
- 🪨 Stone/minerals (excellent - iron, coal present)
- 🪵 Wood (mixed, good hardwoods in valleys)
- 🦌 Deer (valley populations)
- 🦬 elk (rare, mountain)
- 🐻 Black bears (common, dangerous)
- 🌾 Wild plants (medicinal herbs valuable)
- 💧 Fresh water (abundant springs)
- ⛏️ Minerals (iron, lead, copper)

**Weather/Climate:**
- Spring: 5-12°C, fog, frequent rain, avalanche risk early spring
- Summer: 15-20°C, cool at altitude, morning fog
- Autumn: 8-15°C, beautiful, early snow at peaks
- Winter: -10 to 0°C, heavy snow at altitude, extreme wind

**Key Features:**
- ⛰️ Extreme terrain (limiting movement)
- 🏔️ Mountain passes (choke points)
- 💧 Spring-fed streams (pure water)
- 🏘️ Isolated settlements in valleys
- 🗡️ Natural defensive positions
- 🌫️ Frequent fog/visibility limitations

**Factions/Claims:**
- Cherokee heartland (south)
- Shawnee (north)
- Isolated European settlers
- Frontier families (2nd/3rd generation)
- Mineral prospectors (emerging)

**Gameplay Feel:** Isolated, dangerous, mineral wealth, hard to traverse, established frontier presence

---

### 7. WETLANDS/MARSH (⭐⭐⭐ Variable)

**Geography:** Scattered throughout (Carolina swamps, Mississippi delta, northern wetlands)
**Climate:** Variable based on location (warm/humid south, cool north)
**Difficulty:** Hard - navigation, disease risk, isolation

**Resources:**
- 🎣 Fish (catfish, pike - abundant in water)
- 🦆 Waterfowl (geese, ducks - seasonal)
- 🦫 Beaver (excellent populations)
- 🌾 Wild rice (northern marshes)
- 🌿 Medicinal plants (unique wetland herbs)
- 🪵 Wood (cypress, tupelo - specialized)
- 🦗 Alligators (southern, dangerous and valuable)

**Weather/Climate:**
- Spring: 10-18°C, flooding season, heavy rain
- Summer: 20-28°C, HUMID, insects severe, disease risk
- Autumn: 12-20°C, better travel season
- Winter: -5 to 5°C, variable (water limits freezing)

**Key Features:**
- 💦 Water-heavy terrain (difficult movement)
- 🦟 Insect swarms (health hazard)
- 🌿 Dense vegetation (visibility poor)
- 🌊 Interconnected waterways (canoe travel)
- 🦗 Unique wildlife
- 🏘️ Indigenous settlements (better adapted)

**Factions/Claims:**
- Seminole territories (south)
- Choctaw lands
- Isolated fur traders
- River pirate/outlaw communities (possible)

**Gameplay Feel:** Dangerous, claustrophobic, insect hazards, waterborne gameplay

---

### 8. BOREAL FOREST (⭐⭐⭐⭐ Late Game)

**Geography:** Northern forests (Canada, northern US states)
**Climate:** Subarctic, long cold winters, brief summers
**Difficulty:** Very hard - extreme cold, long nights, resource scarcity

**Resources:**
- 🦫 Beaver (excellent, cold-weather premium furs)
- 🦌 Moose (primary large game)
- 🦅 Fur-bearing animals (lynx, wolverine, marten)
- 🌲 Softwood (spruce, pine - good for building)
- 🪨 Stone (moderate)
- 🌾 Berries (seasonal - wild blueberries, cloudberries)
- 🦟 Insects (summer plague)

**Weather/Climate:**
- Spring: -5 to 5°C, late snow, flooding risk
- Summer: 10-15°C, brief window, midnight sun, insect plague
- Autumn: 0 to 8°C, rapid freeze
- Winter: -25 to -10°C, EXTREME, short daylight, darkness dominates

**Key Features:**
- 🌙 Day/night extremes (midnight sun in summer, near-darkness in winter)
- ❄️ Permafrost areas
- 🌲 Endless coniferous forest
- 🏘️ Trading posts and fur company outposts (limited)
- 🦌 Wildlife concentrated
- 🧭 Navigation difficult (flat, uniform landscape)

**Factions/Claims:**
- Cree territories
- Inuit peoples (far north)
- Hudson's Bay Company posts
- North West Company operations
- Independent trappers (hardy explorers only)

**Gameplay Feel:** Extreme survival, isolation, premium fur trading, winter is constant threat

---

### 9. SUBARCTIC (⭐⭐⭐⭐⭐ Late Game)

**Geography:** Far northern regions (Yukon, far north territories)
**Climate:** Subarctic extreme, permafrost dominates
**Difficulty:** Extreme - survival challenge, extreme cold, isolation

**Resources:**
- 🦌 Caribou (migrating herds)
- 🦫 Beaver (premium cold-weather fur)
- 🦊 Fox/wolves (valuable furs)
- 🌲 Sparse stunted trees
- 🪨 Stone (limited)
- 🌾 Arctic plants (very limited)
- 🎣 Fish (arctic char in rivers)

**Weather/Climate:**
- Spring: -10 to 0°C, rapid melt dangerous, flooding
- Summer: 5-10°C, brief warmth, continuous daylight, mosquitoes unbearable
- Autumn: -5 to 5°C, rapid freeze, darkness increases
- Winter: -30 to -15°C, EXTREME COLD, total darkness for weeks, survival challenge

**Key Features:**
- 🌙 Extreme day/night cycles
- ❄️ Permafrost (travel hazards)
- 🌍 Vast, featureless landscape (navigation by landmarks only)
- 🏘️ Extremely isolated (few if any settlements)
- 🦌 Migrating herds (timing-dependent)
- ⛺ Minimal shelter options

**Factions/Claims:**
- Inuit/Inuvik peoples
- Gwich'in territories
- Occasional fur company explorer
- Virtually no European settlement

**Gameplay Feel:** Extreme survival, isolation intense, permadeath likely, only for hardened players

---

### 10. ARCTIC TUNDRA (⭐⭐⭐⭐⭐ Endgame)

**Geography:** Far Arctic (Arctic Archipelago, Greenland edges)
**Climate:** Arctic, hostile, barely survivable
**Difficulty:** Nearly impossible - extreme environment

**Resources:**
- 🦭 Seal/walrus (dangerous hunting, valuable)
- 🐳 Whale (rare, extremely valuable)
- 🐻‍❄️ Polar bears (apex predator, dangerous)
- 🪨 Limited stone
- 🌾 Virtually no plant material
- 🐟 Limited fish (under ice)
- ❄️ Ice (survival tool/building material)

**Weather/Climate:**
- Spring: -20 to -10°C, endless daylight, ice breakup hazardous
- Summer: -5 to 5°C, no darkness, wet, marshy, brief
- Autumn: -10 to -5°C, freeze approaching, darkness returns
- Winter: -40 to -20°C, EXTREME, total darkness, barely survivable

**Key Features:**
- 🏔️ Flat, barren ice and rock
- 🌙 Extreme day/night (6 months each)
- 🧊 Sea ice (travel and hazard)
- 🦭 Marine fauna (hunting risk/reward)
- ❌ No settlements
- 🧭 Navigation by stars/sun angle only

**Factions/Claims:**
- Inuit only
- Virtually no colonial presence

**Gameplay Feel:** Extreme endgame challenge, mostly for exploration, survival is primary mechanic

---

## Terrain Generation Rules

### Biome Adjacency (Transition Logic)

**Valid Adjacent Biomes:**
- Coastal Atlantic → Temperate Forest, Deciduous Forest
- Temperate Forest → Coastal Atlantic, Deciduous Forest, Great Lakes
- Deciduous Forest → Temperate Forest, Appalachian Mountains, Temperate Forest
- Great Lakes → Temperate Forest, Grasslands, Boreal Forest
- Grasslands → Great Lakes, Boreal Forest, Appalachian (edge)
- Appalachian → Deciduous Forest, Grasslands (rare edge)
- Wetlands → Can border most biomes (water-based)
- Boreal Forest → Great Lakes, Grasslands, Subarctic
- Subarctic → Boreal Forest, Arctic Tundra
- Arctic Tundra → Subarctic only

### Difficulty Wave Pattern

```
Difficulty increases as player moves:
- WEST from coastal Atlantic
- NORTH from temperate zones
- HIGHER in elevation (Appalachian)
- INTO isolated regions (far north)

Mixing rule: Easier biomes more common in generated world
Harder biomes rarer and more distant
```

### Resource Distribution Pattern

**High-Value Resources by Biome:**
- Coastal: Fish and salt
- Temperate/Deciduous: Beaver, wood
- Great Lakes: Beaver (premium), canoe routes
- Grasslands: Buffalo hides
- Appalachian: Minerals
- Wetlands: Beaver (premium), aquatic resources
- Boreal: Fur-bearing animals (premium pelts)
- Subarctic/Arctic: Premium furs

---

## Weather System Integration

### Seasonal Impact by Biome

| Biome | Spring Risk | Summer Challenge | Autumn Bonus | Winter Threat |
|-------|-------------|-----------------|--------------|---------------|
| Coastal | Moderate | Insects | Trade season | Ice, wind |
| Temperate | Flooding | Storms | Harvest | Heavy snow |
| Deciduous | Heavy rain | Humid | Extended harvest | Variable ice |
| Great Lakes | Snow melt | Brief window | Early frost | EXTREME |
| Grasslands | Tornadoes | Drought | Rapid cool | Blizzard |
| Appalachian | Avalanche risk | Cool | Beautiful | Heavy snow |
| Wetlands | Severe flood | Disease risk | Best season | Moderate |
| Boreal | Late snow | Insect plague | Brief | EXTREME |
| Subarctic | Flooding | Unbearable insects | Darkness grows | EXTREME |
| Arctic | Rapid melt | Continuous day | Freeze begins | EXTREME |

---

## NPC/Faction Distribution

### Population Density by Biome

| Biome | European Presence | Indigenous Presence | Settlement Type |
|-------|-------------------|-------------------|-----------------|
| Coastal | Heavy | Moderate | Trade posts, towns |
| Temperate | Moderate | Moderate | Trading posts, camps |
| Deciduous | Moderate | Heavy | Tribal settlements, colonial |
| Great Lakes | Moderate-Heavy | Heavy | Major trading hubs |
| Grasslands | Light | Heavy | Tribal camps, rare posts |
| Appalachian | Moderate | Light | Isolated settlements |
| Wetlands | Light | Moderate | Seasonal camps |
| Boreal | Light | Light | Fur company posts |
| Subarctic | Very light | Light | Isolated posts |
| Arctic | None | Light | Inuit settlements only |

---

## Map Generation Parameters (For Implementation)

### World Size
- Recommended: 4096 x 4096 to 8192 x 8192 tiles
- Allows North America representation at functional scale
- Procedurally chunked for memory management

### Tile Properties
- Each tile has: Biome type, elevation, moisture, temperature
- Affects: Resource availability, movement cost, weather effects

### Procedural Rules
1. **Coastline Generation:** Create Atlantic coast, Great Lakes
2. **Biome Layers:** Assign biomes based on latitude/longitude/elevation
3. **Resource Seeding:** Place resources per biome rules
4. **Settlement Placement:** Place factions per population density rules
5. **River Generation:** Create river systems, water bodies
6. **Point of Interest:** Scatter historical locations, ruins, camps

### Performance Optimization
- GPU compute shaders for all terrain generation and noise calculations (REQUIRED)
- Tile-based LOD (level of detail) system
- Chunk loading based on player position via GPU-accelerated ChunkStreamingManager
- Biome data computed entirely on GPU, resources dynamically generated
- GPU support is mandatory - no CPU-only systems supported

---

## Player Progression Example Path

1. **Start:** Coastal Atlantic (safe, learning area)
2. **Early Game:** Temperate/Deciduous forests (inland exploration)
3. **Mid Game:** Great Lakes region OR Grasslands (trade hubs, new challenges)
4. **Late Game:** Appalachian OR Boreal forest (resources, difficulty)
5. **Endgame:** Subarctic/Arctic (extreme challenge, premium rewards)

---

## Notes for Implementation

- This spec is a **guide, not law** - adjust based on gameplay feel
- Start with 5-6 biomes in first iteration, expand later
- Test biome transitions for visual/gameplay smoothness
- Weather system should be global but biome-specific in intensity
- Resource distribution should encourage exploration but be understandable
- Factions should create natural conflict zones for player navigation

---

**Document Version:** 1.0 - Quick Specification
**Created:** 2025-11-15
**Purpose:** Map generation development blueprint
**Next Update:** After initial map generation implementation
