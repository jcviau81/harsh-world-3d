# Harsh World - Game Brainstorming Document

## Game Concept
- **Working Title:** Harsh World
- **High Concept:** A historically-inspired survival RPG set in 17th century North America where players take on the role of fur traders navigating the wilderness, building trading networks, and creating a life in the untamed frontier.
- **Genre:** Survival, RPG, Crafting, Trading
- **Target Audience:** Ages 8+, players interested in historical settings, survival games, and skill-based progression systems
- **Platform:** PC (primary), with potential console ports later

## Core Gameplay
- **Main Mechanics:** Top Down Survival RPG, Proceduraly generated world
- **Player Goals:** Build a successful fur trade business and maybe even start a family
- **Game Loop:** Survive, Forage, Gather, Fish, Hunt, Craft, Build, Explore, find friends or foes and trade.

## Multiplayer (Not Yet)
- We start singleplayer but always keep in mind the future multiplayer aspect.

## World Building
- **Setting:** Harsh World is set in the wilderness of 17th Century New France during the peak of the fur trade. Players take on the role of a coureur de bois (runner of the woods) - an independent fur trader who ventures into the untamed wilderness to trade with indigenous peoples and bring valuable furs back to European settlements.

- **Backstory:** In the early 1600s, French explorers established colonies along the St. Lawrence River, beginning what would become New France. The demand for beaver pelts in Europe drove an economic boom, with fur hats becoming the height of fashion. This created opportunities for bold individuals willing to risk everything in the harsh wilderness. Unlike the licensed voyageurs who worked for trading companies, the coureurs de bois operated independently, often living among indigenous peoples and adopting their survival techniques.

- **Atmosphere:** The game aims to capture both the beauty and danger of the North American wilderness. The atmosphere is one of isolation and self-reliance, where survival requires skill and determination. The world is simultaneously breathtaking and unforgiving - pristine forests and waterways teeming with life, but also filled with dangers from weather, wildlife, and sometimes hostile encounters. The mood shifts with the seasons, from the vibrant abundance of summer to the stark, desperate survival of winter.

## Characters
- **Player Character(s):**
  - **Coureur de Bois**: The player character is a free-spirited fur trader who has chosen to live outside the constraints of colonial society. Players can customize their background (French settler, mixed heritage Métis, or European immigrant), which provides different starting skills and relationships.
  - **Abilities**: Skills develop through practice rather than traditional leveling. Players begin as novices in most skills but can become masters through persistent use and training.
  - **Motivation**: While survival is the immediate concern, players are driven by various possible motivations: wealth accumulation through the fur trade, exploration and mapping of unknown territories, building relationships with indigenous peoples, or establishing a homestead and family in the wilderness.

- **NPCs/Enemies:**
  - **Indigenous Peoples**: Various nations including Huron-Wendat, Algonquin, Iroquois, and others. Some may be potential trading partners and allies, while others might be hostile depending on player actions and historical conflicts.
  - **Colonial Officials**: Representatives of the French crown who may offer missions or create obstacles for unlicensed traders.
  - **Rival Traders**: Both independent coureurs de bois and company voyageurs competing for the same resources and trade relationships.
  - **Wildlife**: From passive animals like deer and beaver (valuable for resources) to dangerous predators like wolves and bears that threaten survival.
  - **Merchants**: Based in settlements, they buy furs and sell supplies, with prices fluctuating based on supply, demand, and the player's bartering skill.

- **Character Development:**
  - Skills improve through practice and usage
  - Reputation systems with different factions affect trading prices and available quests
  - Physical attributes change based on activities and survival conditions (weight, strength, endurance)
  - Optional family system allows for legacy characters and generational gameplay

## Skill System
- Train and gain skills from 0 to 100 bt doing things related to the skill
### Survival Skills
  - **Hunting:** Ability to track, kill, and process animals for food and materials
  - **Fishing:** Catching and preparing fish using various methods
  - **Foraging:** Finding and identifying edible plants, berries, and resources
  - **Cooking:** Preparing and preserving food for consumption and storage
  - **Pathfinding:** Finding your way through wilderness using natural signs
### Crafting Skills
  - **Bushcrafting:** Creating and maintaining various tools
  - **Tanning and Leatherworking:** Processing animal hides into usable leather goods
  - **Construction:** Building larger structures and settlements using refined materials
  - **Smithing:** Crafting and maintaining various tools and weapons
### Trading and Social Skills
  - **Bartering:** Exchanging goods effectively without currency
  - **Languages:** Basic communication with different cultural groups
  - **Networking:** Building relationships with other traders and settlements
  - **Lumberjacking:** Cutting and processing wood for construction
  - **Mining:** Finding and extracting minerals and ores
  - **Mapmaking:** Creating and using maps for navigation
  - **Writing:** Understanding and using written communication






## Visual Style
- **Art Direction:** 2D top-down view rendered in Godot 3D engine using sprite billboards in 3D space. The art style balances historical accuracy with readability and performance. Character and object sprites are detailed enough to convey information about their state and function while maintaining a consistent aesthetic. 2D sprites are positioned in a grid system similar to TileMap but in 3D space for GPU-accelerated rendering.

- **Color Palette:**
  - **Seasonal Variations**: Vibrant greens and blues in summer, rich oranges and reds in autumn, stark whites and pale blues in winter, and fresh pastel colors in spring.
  - **Environmental Contrast**: Deep forest greens against the blue of rivers and lakes, with earth tones for terrain.
  - **Cultural Distinctions**: Different color schemes for French colonial items versus indigenous crafts, helping players visually distinguish origins.

- **Reference Inspirations:**
  - **Games**: Don't Starve (for its distinctive art style and survival elements), Rimworld (for its top-down colony management), Stardew Valley (for its seasonal changes and detailed sprites)
  - **Historical Art**: Period illustrations from 17th century New France, indigenous art styles from relevant nations
  - **Natural References**: North American wilderness photography focusing on the St. Lawrence River valley, Great Lakes region, and northern forests

## Audio
- **Music Style:**
  - **Ambient Wilderness**: Subtle, atmospheric tracks featuring natural instruments (wooden flutes, strings, soft percussion) that blend with environmental sounds
  - **Cultural Influences**: Blend of period-appropriate French colonial music with indigenous musical traditions
  - **Adaptive System**: Music that responds to game situations (danger, discovery, trading) and time of day/season
  - **References**: The soundtrack from "The Revenant" for wilderness atmosphere, traditional Huron-Wendat and Algonquin music, early French colonial folk music

- **Sound Effects:**
  - **Environmental Audio**: Detailed soundscapes for different biomes and weather conditions (forest rustling, river sounds, wind through trees, rain, thunder)
  - **Wildlife Sounds**: Distinctive calls and movements for different animals, serving both as atmosphere and gameplay information
  - **Crafting and Tool Sounds**: Authentic sounds for different materials and crafting processes
  - **Weapon and Combat Audio**: Distinctive sounds for different weapons and combat actions

- **Voice Acting:**
  - Limited voice acting for key NPCs, focusing on authentic accents and languages
  - Option for basic phrases in multiple languages (French, various indigenous languages)
  - Narrator for tutorial elements and major discoveries
  - Most dialogue presented as text to allow for more extensive content

## Technical Considerations
- **Godot Features to Use:**
  - Godot 4.x 3D engine with orthographic camera for 2D-like gameplay
  - GPU compute shaders for procedural terrain generation and noise calculations
  - GridMap-style grid system for sprite placement in 3D space
  - GDScript for game logic with potential C# integration for performance-critical systems
  - Godot's built-in 3D physics for character movement and object interactions
  - Custom shaders for environmental effects (water, weather, seasons)
  - AnimationPlayer for character and creature animations
  - GPU-accelerated particle systems for weather and atmospheric effects

- **Performance Targets:**
  - 60 FPS on mid-range hardware
  - Support for various resolutions with UI scaling
  - Optimized for desktop platforms with keyboard/mouse controls
  - Efficient memory usage to support large procedurally generated worlds
  - Scalable graphics settings to accommodate different hardware capabilities

- **Potential Challenges:**
  - Managing GPU shader development for procedural terrain and noise generation
  - Implementing efficient chunk streaming with GPU-accelerated generation
  - Synchronizing world state in multiplayer across large distances
  - Balancing historical accuracy with engaging gameplay
  - Creating AI systems for wildlife and NPCs that feel natural and responsive
  - Designing systems that allow for emergent gameplay without overwhelming complexity
  - Optimizing GPU compute shaders for cross-platform compatibility (Windows, Mac, Linux)

## Development Roadmap

### Phase 1: Core Systems Prototype (Current Phase)
- **World Generation**
  - ✅ Basic Procedural terrain generation with configurable parameters
  - ✅ Basic Object placement system (trees, rocks)
  - ✅ Distance-based culling and object pooling for performance
  - ⬜ Biome system (boreal forest, plains, mountains, rivers, tundra, lakes, marsh, artic)
  - ⬜ Weather system with seasonal changes

- **Player Systems**
  - ✅ Basic movement and controls
  - ✅ Camera following with zoom functionality
  - ✅ Cursor system with different tool visuals
  - ✅ Basic weapon system (bow and arrows)
  - ✅ Skill system framework with experience gain
  - ⬜ Inventory system
  - ⬜ Health, hunger, and stamina systems

- **Wildlife**
  - Basic animal AI (moose, rabbit)
  - ⬜ More diverse wildlife (deer, wolves, bears, birds)
  - ⬜ Animal behavior patterns (grazing, hunting, fleeing)
  - ⬜ Animal resources (meat, hide, bones)

### Phase 2: Gameplay Systems Alpha
- **Survival Mechanics**
  - ⬜ Hunger and thirst mechanics
  - ⬜ Temperature and weather effects
  - ⬜ Day/night cycle with lighting changes
  - ⬜ Seasons affecting environment and resources
  - ⬜ Illness and injury system

- **Crafting and Building**
  - ⬜ Resource gathering (wood, stone, plants)
  - ⬜ Basic crafting system for tools and items
  - ⬜ Simple shelter construction
  - ⬜ Cooking and food preservation
  - ⬜ Tool durability and maintenance

- **Skill Implementation**
  - ⬜ Complete all skill mechanics with progression
  - ⬜ Skill-based bonuses and abilities
  - ⬜ Skill challenges and achievements
  - ⬜ Skill-based dialogue options

### Phase 3: Content and Progression Beta
- **World Expansion**
  - ⬜ Multiple biome types with unique resources
  - ⬜ Points of interest (abandoned camps, native villages)
  - ⬜ Hidden locations and treasures
  - ⬜ Dynamic events (storms, animal migrations)

- **NPC Systems**
  - ⬜ Native tribes with unique cultures
  - ⬜ French settlers and trading posts
  - ⬜ Basic dialogue system
  - ⬜ Trading and bartering mechanics
  - ⬜ Reputation system with different factions

- **Progression**
  - ⬜ Quest/mission system
  - ⬜ Economic progression (wealth accumulation)
  - ⬜ Settlement development
  - ⬜ Story elements and narrative progression

### Phase 4: Polishing

- **UI and Experience**
  - ⬜ Complete UI overhaul with period-appropriate design
  - ⬜ Tutorial system and help guides
  - ⬜ Map and navigation tools
  - ⬜ Settings and accessibility options

- **Audio and Visual Polish**
  - ⬜ Complete soundtrack
  - ⬜ Ambient sound effects
  - ⬜ Visual effects for weather, time, and actions
  - ⬜ Animation improvements

### Phase 5: Release and Beyond
- **Release Preparation**
  - ⬜ Comprehensive testing and bug fixing
  - ⬜ Performance optimization
  - ⬜ Server infrastructure (if multiplayer)
  - ⬜ Documentation and player guides

- **Post-Launch Content**
  - ⬜ New biomes and regions
  - ⬜ Additional wildlife and resources
  - ⬜ Expanded crafting recipes
  - ⬜ Seasonal events and challenges
  - ⬜ Community-requested features

## Ideas to Explore

### Gameplay Mechanics
- **Canoe Travel System**: Implement canoes for faster river travel, with mechanics for paddling, portaging, and navigating rapids.
- **Seasonal Fur Quality**: Animal fur quality changes with seasons, affecting trade values and encouraging strategic hunting.
- **Family System**: Allow players to start families, with children that can be taught skills and eventually become playable characters.
- **Permadeath with Legacy**: When a character dies, their children or apprentices can inherit some skills and possessions.

### World Building
- **Historical Events**: Incorporate real historical events from the fur trade era that affect gameplay.
- **Indigenous Knowledge**: Learn special skills and knowledge from indigenous characters that help with survival.
- **Competing Trading Companies**: Hudson's Bay Company vs. North West Company rivalry affecting prices and available goods.
- **Settlement Development**: Player-built trading posts can grow into settlements with NPCs moving in.

### Multiplayer Features
- **Trading Caravans**: Groups of players can form trading caravans for protection and better trading prices.
- **Shared Settlements**: Multiple players can contribute to building and maintaining a settlement.
- **Skill Teaching**: Players with high skills can teach other players, accelerating their learning.
- **Faction Warfare**: Optional PvP between players aligned with different trading companies or nations.

## Questions to Answer

### Game Design
- How historically accurate should the game be versus taking creative liberties for gameplay?
- Should there be a main storyline, or should it be entirely sandbox/emergent gameplay?
- How will player progression be balanced to maintain challenge throughout the game?
- What will be the primary motivator for players in the mid to late game?

### Technical Implementation
- How will we handle multiplayer synchronization in a large procedurally generated world?
- What's the best approach for saving and loading such a complex world state?
- How can we optimize the game to run well on lower-end hardware?
- What's the maximum number of concurrent players we should support per server?

### Art and Audio
- What art style will best balance historical authenticity with technical constraints?
- How will we handle the transition between seasons visually?
- What music style would best complement the 17th century North American wilderness setting?
- How detailed should character customization be?

## Notes & References

### Historical References
- **Books**: "The Voyageur" by Grace Lee Nute, "The Fur Trade in Canada" by Harold Innis
- **Museums**: Canadian Museum of History, North West Company Fur Post
- **Games with Similar Themes**: Red Dead Redemption 2 (hunting/survival), Valheim (building/progression), New World (colonial setting)

### Technical Inspirations
- **Procedural Generation**: Minecraft, No Man's Sky
- **Survival Systems**: Don't Starve, The Long Dark
- **Skill Systems**: Skyrim, RuneScape
- **Economy Systems**: EVE Online, Albion Online