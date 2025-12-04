# Product Requirements Document: Harsh World

**Project:** harsh-world-3d
**Author:** JC
**Date:** 2025-12-03
**Version:** 1.0
**Status:** Ready for Architecture Review

---

## Executive Summary

Harsh World is a hardcore single-player survival simulator set in 17th-century colonial North America. The game prioritizes realistic mechanics-driven gameplay where food preparation, water management, and settlement placement directly impact survival success. Players must master complex survival knowledge through discovery and failure to progress—permadeath prevents recklessness, and food scarcity forces constant decision-making.

**Target Player:** Experienced gamers (15-50+) who crave steep learning curves, permadeath mechanics, and mastery-based progression. Market positioning: "Like Don't Starve meets Dwarf Fortress in colonial North America."

**MVP Launch:** Single-player Early Access with core survival loop, 10 food types, 10+ NPCs, permadeath system, and large procedural world. No combat, no magic, no sci-fi.

---

## Product Scope

### What's Included (MVP)

**Core Gameplay Loop:**
- Forage, hunt, and fish for food
- Prepare meals with multiple preparation methods (boiling, cooking, drying, fermenting)
- Build and maintain settlement with fire, shelter, and storage
- Trade with NPCs for complex tools and resources
- Explore procedurally generated world to discover resources and trading partners
- Manage stamina, health, and starvation
- Permadeath with world reset, but settlement structures persist

**Content:**
- 10 MVP food types with nutritional complexity and side effects
- 10+ NPCs with individual trading requirements and locations
- 3-4 core biomes (temperate forest, boreal forest, coast, mountains)
- Water system (rivers, lakes, fishing, canoe travel)
- Seasonal visual indicators (spring, summer, autumn, winter)
- Basic tribal territories with reputation foundation

**Technical:**
- Procedurally generated island world (deterministic seed-based)
- GPU compute shader terrain generation (mandatory for performance)
- Permadeath + settlement persistence architecture
- 60 FPS performance target on Windows 64-bit

**UI/UX:**
- Inventory system (items, capacity management)
- Food preparation menu
- Trading interface with NPCs
- Settlement building UI
- Minimal HUD (no quest markers, no tutorials)

### What's Deferred (Post-Launch)

- Full 20-30 food type library (MVP: 10-15 types)
- Advanced seasonal mechanics affecting food availability (MVP: visual only)
- Religious group territories and conflict mechanics
- Multiplayer co-op system (8+ players)
- Platform ports (Mac, Linux, consoles)
- Advanced accessibility options (high-contrast mode, colorblind support)
- Speedrun leaderboards and achievement tracking
- Quest system or narrative branching
- Combat system

---

## Functional Requirements

### F1: Core Survival Loop

**F1.1: Foraging**
- Player can interact with vegetation to gather plants, berries, and seeds
- Different biomes have different forage availability
- Forage items are discoverable through interaction (trial-and-error learning)
- No tutorials; players must experiment to learn what's edible

**F1.2: Hunting & Fishing**
- Player can hunt animals (deer, moose, rabbits, birds)
- Player can fish in rivers and lakes using basic tools
- Different seasons affect animal availability
- Hunting and fishing return raw meat/fish requiring preparation
- Success is based on preparation (patience, equipment, technique)

**F1.3: Food Preparation**
- Player can boil, cook, dry, or ferment food items
- Each preparation method affects nutritional value, freshness duration, and side effects
- Preparation requires fuel (fire) and tools (pots, drying racks, fermentation containers)
- Complex tools (steel pots, iron tools) can ONLY be obtained through NPC trading
- Prepared food has limited shelf life (spoilage system)

**F1.4: Food Consumption & Nutrition**
- Player has stamina and health bars
- Eating replenishes stamina and provides nutritional benefits
- Food has specific nutritional properties (proteins, minerals, vitamins)
- Eating wrong foods causes side effects (constipation, vitamin deficiency, food poisoning)
- Starvation damages health and eventually causes death

**F1.5: Fire & Shelter Management**
- Player must maintain fire at settlement to cook food and stay warm
- Fire requires fuel (wood, coal)
- Shelter provides warmth and rest (sleep system)
- Poor sleep condition reduces stamina recovery
- Shelter can be damaged and requires maintenance

**F1.6: Settlement Building**
- Player can build basic structures (fire pit, storage, shelter, crafting area)
- Structures improve settlement functionality
- Settlement location is persistent across permadeath
- Player can expand settlement over time
- Settlement size/structure capacity TBD

### F2: Permadeath & Respawn System

**F2.1: Character Death**
- Player character death triggers permadeath state
- Cause of death recorded (starvation, poison, cold, injury)
- All inventory items lost upon death
- Experience/knowledge learned persists in player memory only (no meta-progression)

**F2.2: World Reset**
- Upon death, new world generated with different procedural seed
- New world has different biome layout, resource distribution, NPC locations
- Previous world is abandoned and unrecoverable

**F2.3: Settlement Persistence**
- Settlement structures from previous world are preserved in new world
- Settlement location randomized in new world (not same location)
- Settlement inventory items are preserved
- Storage and materials are recovered

**F2.4: Respawn Mechanics**
- Player respawns at settlement from previous world
- Respawn is automatic; player starts new character at settlement
- No resurrection mechanic; respawn is one-way progression

### F3: NPC Trading System

**F3.1: NPC Discovery**
- NPCs are scattered across the world
- NPCs have fixed locations (trading posts, camps) or wandering routes (TBD)
- Player discovers NPCs through exploration
- NPC locations are not marked on map; player must remember or re-discover

**F3.2: NPC Trade Mechanics**
- Each NPC has specific items they want and items they offer
- Trading requires acceptable terms (fair exchange rate)
- Multiple NPCs have overlapping trade options (alternative paths)
- Trade completeness: all essential items can be obtained through trade chains

**F3.3: NPC Reputation System**
- Player reputation with each NPC or tribal group (TBD detail)
- Actions affect reputation (positive: trading, helping; negative: theft, violence)
- Reputation affects NPC availability and trade terms (TBD specific mechanics)
- No permanent NPC locks in MVP (all NPCs remain accessible)

**F3.4: Required NPC Trades (MVP)**
- Complex tools cannot be crafted; must be traded for
- Examples: steel pots, muskets, iron tools, advanced fishing equipment
- Trade chains exist to enable player to obtain necessary tools
- Trading is core progression mechanic, not optional convenience

### F4: Procedural World Generation

**F4.1: Terrain Generation**
- World is an island bounded by ocean (not infinite)
- Terrain generated via GPU compute shaders (Godot 4.x RenderingDevice API)
- Deterministic generation: same seed produces same world
- Different seeds produce different biome layouts and resource distribution

**F4.2: Biome System**
- 3-4 MVP biomes: temperate forest, boreal forest, coast/shoreline, mountains
- Each biome has unique:
  - Forage items (plants, berries, mushrooms)
  - Huntable animals
  - Water features (rivers, lakes)
  - Resource nodes (wood types, stones)
  - Climate difficulty (temperature, precipitation)

**F4.3: Water System**
- Procedurally generated rivers and streams
- Lakes and ponds scatter across world
- Water is essential resource (drinking, fishing, canoe travel)
- Rivers affect world navigation (must find crossings or use canoe)

**F4.4: NPC Location Generation**
- 10+ NPCs placed at procedurally determined locations
- Trading posts spawn near water and resources
- Tribal villages spawn in specific biomes
- NPC locations vary by seed (player must rediscover in new world)

### F5: Player Character System

**F5.1: Character Attributes**
- Stamina (depletes with exertion, replenishes with food/rest)
- Health (depletes from starvation, poison, injury)
- Hunger (tracks food need; starvation begins at 0 food for X hours)

**F5.2: Character Progression (Knowledge-Based)**
- No XP or skill points
- Player learns food types through discovery (eat and survive/fail)
- Player learns NPC locations through exploration
- Player learns recipes and preparation methods through experimentation
- Knowledge persists only in player memory (not saved in-game)

**F5.3: Equipment System**
- Player carries inventory with weight/capacity limits (TBD specifics)
- Equipment affects carrying capacity and tool availability
- Basic tools (stick, stone knife) available at start or through crafting
- Advanced tools only available through NPC trading

### F6: Time & Weather System

**F6.1: Day/Night Cycle**
- Game has day/night with visual indicators
- Different activities possible during day vs. night
- Sleep required to restore stamina

**F6.2: Seasonal System (MVP)**
- Visual seasonal changes (biome colors shift with season)
- Seasonal indicators visible (snow in winter, flowers in spring)
- Food availability changes seasonally (visual feedback, no gameplay impact in MVP)
- Full seasonal mechanics (gameplay impact on food availability) deferred to post-launch

**F6.3: Weather**
- Random weather events (rain, snow, storms)
- Weather affects visibility and player safety (TBD detail)
- Weather impacts forage and hunting success rates

### F7: User Interface

**F7.1: Inventory Screen**
- Display carried items with weights/quantities
- Allow item management (drop, organize, use)
- Show equipment slots

**F7.2: Food Preparation Menu**
- Display available food items
- Show preparation methods available (boiling, cooking, drying, fermenting)
- Display preparation time and resulting food
- Show tool/fuel requirements

**F7.3: Trading Interface**
- Display NPC's wanted items and offered items
- Show player inventory for trade selection
- Confirm trade before completion
- Show trade history (optional)

**F7.4: Settlement Building Menu**
- Display available structures to build
- Show resource requirements for each structure
- Display current settlement structures
- Allow placement (snap-to-grid, with collision detection)

**F7.5: HUD (Minimal)**
- Stamina bar (upper left)
- Health bar (upper left)
- Time of day indicator (upper right)
- Current season indicator (upper right)
- Quick-access hotbar (optional, TBD)

**F7.6: No Features**
- No quest markers or objectives
- No minimap or world map
- No tutorial system
- No dialogue trees
- No character customization screen

### F8: Save & Load System

**F8.1: Save Data**
- Persistent settlement data (structures, inventory, location)
- Character state (health, stamina, inventory)
- World seed (for regenerating same world if needed)
- Playtime tracking

**F8.2: Save Mechanics**
- Auto-save on settlement (frequent, non-intrusive)
- Manual save possible at any time
- One active save slot per character
- Previous saves overwritten (no branching/multiple saves)

**F8.3: Load Mechanics**
- Load settlement from save
- Load world from seed
- Load character state
- No save corruption tolerance (lost saves are permanent)

### F9: Audio & Localization

**F9.1: Music**
- Background music (5-10 tracks minimum) in folk/17th-century style
- Context-sensitive (settlement theme, exploration theme, danger theme)
- Generated via Suno AI with manual curation

**F9.2: Sound Effects**
- Environmental sounds (wind, water, rain, fire)
- Animal sounds (birds, deer, predators)
- Action sounds (chopping, cooking, building)
- From free-licensing sound libraries

**F9.3: Dialogue**
- Text-based, silent dialogue delivery
- NPCs communicate via text display
- Language barriers represented through text formatting (partial comprehension, accent markers)

**F9.4: Accessibility**
- Full subtitle support for all dialogue
- Color-blind support (TBD post-launch)
- High-contrast mode (TBD post-launch)
- No audio-only critical information

---

## Non-Functional Requirements

### N1: Performance

**N1.1: Frame Rate**
- Target: 60 FPS minimum in-field
- Acceptable: 45+ FPS in dense resource areas
- Testing hardware: Windows 64-bit with GPU compute support (NVIDIA, AMD, Intel)

**N1.2: Load Times**
- World generation: < 30 seconds for new world
- Settlement load: < 5 seconds
- Biome transition: < 2 seconds

**N1.3: Memory Usage**
- Target: < 4GB RAM on average system
- Streaming system for infinite world (chunk-based loading)

### N2: Compatibility

**N2.1: Platform (MVP)**
- Windows 64-bit (primary launch platform)
- Requires GPU with compute shader support
- Minimum: 4GB RAM, 10GB disk space
- Supported GPUs: NVIDIA (GTX 900 series+), AMD (Polaris+), Intel (Iris Pro+)

**N2.2: Engine**
- Godot 4.x with GDScript
- No external C++ plugins for MVP
- Self-contained executable

### N3: Stability & Quality

**N3.1: Crash Rate**
- Target: < 2% crash rate per 10-hour gameplay session
- No save corruption
- Graceful error handling

**N3.2: Bug Tolerance**
- No game-breaking bugs at launch
- Permadeath system fully tested
- Settlement persistence fully tested
- Trade chain completion verified

### N4: Security

**N4.1: Save File Integrity**
- Save files cannot be corrupted by normal gameplay
- No cheat detection required (single-player game)
- No online connectivity required

---

## User Stories (MVP Breakdown)

### Epic 1: Core Survival Loop

**Story 1.1: Player can forage for food**
- As a player, I want to gather plants and forage items from the environment, so I can survive without hunting.
- AC: Can interact with vegetation, receive items, items vary by biome.

**Story 1.2: Player can hunt animals**
- As a player, I want to hunt animals for meat, so I have a food source requiring more preparation.
- AC: Can find and hunt specific animals, meat requires cooking.

**Story 1.3: Player can prepare food**
- As a player, I want to cook, boil, dry, or ferment food, so I can preserve it and gain nutritional benefits.
- AC: All 4 preparation methods implemented, each affects nutrition/freshness.

**Story 1.4: Player character has stamina & hunger**
- As a player, I want stamina to deplete with activity, so survival requires constant food/rest management.
- AC: Stamina bar visible, depletes with activity, replenished by eating/sleeping.

**Story 1.5: Player can build settlement structures**
- As a player, I want to build a fire, shelter, and storage, so I have a safe base camp.
- AC: Basic structures buildable, improve settlement functionality.

### Epic 2: Permadeath & World Reset

**Story 2.1: Player character can die**
- As a player, I want permadeath mechanics so failure has real consequences.
- AC: Death triggers on starvation/poison/cold, inventory lost.

**Story 2.2: New world generates on respawn**
- As a player, I want a new procedurally generated world after death, so each playthrough is unique.
- AC: New world generated with different seed, same biome types but different layout.

**Story 2.3: Settlement persists across permadeath**
- As a player, I want my settlement from the previous world to carry over, so progress isn't completely lost.
- AC: Settlement inventory preserved, structures recovered in new world.

### Epic 3: NPC Trading System

**Story 3.1: NPCs exist in the world**
- As a player, I want to discover NPCs through exploration, so trading is a discovered mechanic, not gifted.
- AC: 10+ NPCs placed at procedural locations, discoverable through exploration.

**Story 3.2: Player can trade with NPCs**
- As a player, I want to exchange items with NPCs for tools I can't craft, so progression requires strategic trading.
- AC: Trading interface functional, trade chains verified complete.

**Story 3.3: Reputation affects NPC interactions**
- As a player, I want my actions to matter socially, so reputation mechanics add depth.
- AC: Reputation system functional, affects trade availability (detail TBD).

### Epic 4: Procedural World Generation

**Story 4.1: World generates procedurally**
- As a player, I want infinite island world that's procedurally generated, so exploration is rewarding.
- AC: GPU compute shaders functional, deterministic generation works.

**Story 4.2: Biomes have unique properties**
- As a player, I want different biomes with unique resources and challenges, so exploration matters.
- AC: 3-4 biomes implemented with unique forage, animals, and visuals.

**Story 4.3: Water system functional**
- As a player, I want rivers, lakes, and canoe travel to be core mechanics, so water navigation matters.
- AC: Procedural water generation, fishing functional, canoe mechanics implemented.

### Epic 5: UI & Gameplay Support

**Story 5.1: Inventory system**
- As a player, I want to manage inventory with capacity limits, so resource management matters.
- AC: Inventory displays items, shows capacity, allows item management.

**Story 5.2: Minimal HUD**
- As a player, I want minimal UI so immersion isn't broken by markers/tutorials.
- AC: Stamina, health, time visible; no quest markers or unnecessary UI.

**Story 5.3: Save/Load system**
- As a player, I want to save my progress so I don't lose work.
- AC: Auto-save on settlement, manual save available, load functional.

---

## Acceptance Criteria (Overall)

### Technical Acceptance

- [ ] Game runs at 60 FPS on target hardware
- [ ] Permadeath system tested extensively (settlement persistence verified)
- [ ] No game-breaking bugs
- [ ] World generation deterministic (same seed = same world)
- [ ] All save data persists correctly
- [ ] No save corruption after 50 hours of playtesting

### Content Acceptance

- [ ] Core survival loop playable end-to-end (forage → cook → eat → sleep → repeat)
- [ ] All 10 NPCs discoverable in single playthrough
- [ ] Trade chains verified complete (all essential items obtainable)
- [ ] Minimum 10-hour first playthrough without softlocks

### Quality Acceptance

- [ ] Pixel art visually consistent across sprites
- [ ] Audio immersive (player feedback emphasizes quality)
- [ ] UI intuitive enough that < 10% of players need external guides
- [ ] Player reviews average 4.0+ stars

---

## Success Metrics

### Launch (Early Access Release)
- 500+ concurrent players within first month
- 4.0+ star average review rating
- Player feedback: "Core survival loop is compelling"
- No major stability issues reported in first 30 days

### Post-Launch (Months 3-6)
- 1,000-2,000 active monthly players
- Community wiki/guides created by players
- 5-10 content creators producing 100+ hours coverage
- Speedrun community established with leaderboards

---

## Out of Scope (Explicitly NOT Included)

- Combat system
- Magic or fantasy elements
- Multiplayer (Phase 2 post-launch)
- Sci-fi technology
- Quests or narrative branching
- Character customization
- Cosmetic/fashion systems
- Seasonal gameplay impact (MVP: visual only)
- Advanced accessibility modes
- Platform ports (Mac, Linux, consoles)

---

## Assumptions & Dependencies

### Assumptions
- Target player already has understanding of survival game concepts
- GPU compute shader support is available on target hardware
- Player prefers discovery over tutorials
- Historical setting appeals to target audience

### Dependencies
- Godot 4.x stable release
- GPU compute shader documentation/samples
- Free sound effect libraries with appropriate licensing
- No external publishing dependencies for MVP launch

---

## Revision History

| Version | Date | Author | Changes |
|---------|------|--------|---------|
| 1.0 | 2025-12-03 | JC | Initial PRD from Game Brief |

---

_PRD ready for Architecture Review and Epic/Story breakdown._
