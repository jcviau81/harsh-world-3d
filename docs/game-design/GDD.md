# Harsh World - Game Design Document

## Executive Summary

**Harsh World** is a 2D top-down survival RPG set in 17th century North America, built with Godot's 3D Engine using 2D sprites in 3D space with GPU-exclusive procedural generation. Players navigate an infinitely procedurally generated wilderness, managing survival needs while building relationships, exploring cultural dynamics, and uncovering historical narratives. The game emphasizes cultural immersion through language barriers, religious tensions, and authentic period-appropriate mechanics, all powered by GPU compute shaders for terrain and noise calculations. **GPU compute support is REQUIRED to play.**

**Target Platform:** PC (Windows, Mac, Linux) via Godot 4.x 3D Engine
**Genre:** Survival RPG / Exploration
**Target Audience:** Players 12+ (with GPU) who like difficult and punishing games with realistic survival, social and cultural mechanics
**GPU Requirement:** GPU compute shader support is MANDATORY - CPU-only systems cannot run this game
**Estimated Development Time:** 12-18 months
**Team Size:** Solo developer with potential for small team expansion
**Technical Stack:** Godot 4.x 3D Engine, GDScript, GPU Compute Shaders (GLSL/WGSL) - EXCLUSIVE

## Game Overview

### Core Concept
Players assume the role of European settlers arriving in North America during the colonial period. The game focuses on the harsh realities of frontier life, where survival depends on mastering wilderness skills, navigating complex social dynamics, and making morally ambiguous decisions that shape the emerging colonies.

### Unique Selling Points
- **Cultural Immersion:** Authentic representation of 17th century North American cultures with language barriers and religious dynamics
- **Dynamic Social Systems:** Relationship-building mechanics that affect gameplay outcomes
- **Procedural Wilderness:** Infinite exploration with meaningful procedural generation
- **Skill Mastery:** Deep 0-100 skill progression system with realistic learning curves
- **Historical Narrative:** Branching storylines based on real historical events and figures

### Player Fantasy
- **Immersion in History:** Experience the challenges and triumphs of early colonial life
- **Mastery Through Struggle:** Build expertise in survival skills through persistent effort
- **Cultural Bridge-Builder:** Navigate, barter and mediate between different cultural groups
- **Legacy Builder:** Shape the development of colonial settlements through your actions

## Core Mechanics

### Survival System
- **Needs Management:** Hunger, thirst, warmth, health, and morale
- **Resource Gathering:** Hunting, fishing, foraging, crafting
- **Environmental Hazards:** Weather effects, wildlife encounters, seasonal changes
- **Rest and Recovery:** Camps, settlements, and safe havens

### Hydrology System
- **Water Sources:** Dynamic rivers, lakes, streams, and tributaries generated procedurally
- **Water Flow and Drainage:** Realistic water pathways following terrain elevation with GPU-computed flow simulation
- **Water Mechanics:**
  - Water availability for drinking and resource gathering
  - Seasonal water level fluctuations affecting traversal and fishing
  - Flash floods and flooding hazards during heavy rainfall
  - Water crossing mechanics (fording, building bridges, finding shallows)
- **Water Quality:** Fresh vs. stagnant water, pollution from settlements and industrial activities
- **Fishing and Aquatic Resources:** Fish populations, beaver trapping, aquatic plant gathering
- **Hydrological Features:** Waterfalls, rapids, wetlands, springs with distinct gameplay mechanics
- **Dynamic Water Simulation:** GPU-accelerated water flow computation for realistic environmental behavior

### Skill Progression System
- **0-100 Scaling:** Skills improve through practice with diminishing returns
- **Core Skills:**
  - Hunting (tracking, trapping, skinning)
  - Crafting (tools, weapons, shelters)
  - Social (negotiation, persuasion, cultural knowledge)
  - Survival (fire-making, navigation, first aid)
  - Combat (melee, ranged, tactics)
- **Skill Decay:** Unused skills gradually decrease over time
- **Mastery Bonuses:** Special abilities unlocked at skill milestones (25, 50, 75, 100)

### Social and Cultural Systems
- **Language Barriers:** Communication limited by language proficiency
- **Cultural Relationships:** Factions include Native American tribes, European settlers, religious groups
- **Reputation System:** Actions affect standing with different groups
- **Alliance Building:** Form trade agreements, marriages, and political alliances

### Exploration and World Generation
- **Procedural Terrain:** Biomes include forests, plains, mountains, rivers, lakes
- **Hydrological Generation:** Procedurally generated water systems with realistic drainage patterns and seasonal behavior
- **Point of Interest Generation:** Historical sites, settlements, ruins, wildlife hotspots, fishing grounds, fords, and water sources
- **Dynamic Events:** Random encounters, seasonal migrations, historical events, flooding events
- **Navigation:** Map system with landmarks and trail markers including water crossings and water features

## Character Creation and Progression

### Character Backgrounds
- **Fur Trapper:** Expert in wilderness survival, starts with hunting/crafting bonuses
- **Priest/Missionary:** Strong social skills, religious influence abilities
- **Soldier:** Combat-focused, leadership potential
- **Merchant:** Trade and negotiation expertise
- **Scholar:** Knowledge-based skills, research abilities
- **Artisan:** Crafting specialization, settlement development focus

### Character Development
- **Experience System:** Earned through activities, quests, and discoveries
- **Trait System:** Personality traits that affect dialogue and outcomes
- **Legacy System:** Long-term consequences of major decisions
- **Companions:** Recruit NPCs who develop their own goals and relationships

## World Design

### Geographic Scope
- **Regional Focus:** Northeastern North America (New England, New France, New Netherlands)
- **Biome Variety:** Temperate forests, coastal regions, inland waterways
- **Seasonal Changes:** Dynamic weather and resource availability

### Settlements and Factions
- **European Settlements:** Forts, trading posts, colonial towns
- **Native Communities:** Villages with unique cultural practices
- **Religious Centers:** Missions, monasteries, sacred sites
- **Economic Hubs:** Trading centers, resource extraction sites

### Historical Integration
- **Timeline Accuracy:** Events tied to real historical periods (1600s-1700s)
- **Cultural Representation:** Authentic depictions of indigenous cultures and colonial dynamics
- **Moral Complexity:** No clear "good vs evil" - all factions have valid perspectives

## Art and Visual Design

### Art Style
- **2D Sprites in 3D Space:** Pixel art sprites rendered as textured quads in Godot's 3D engine using GridMap-style grid system
- **Isometric/Top-Down Perspective:** 3D orthographic/isometric camera viewing 2D sprites in grid cells for depth and immersion
- **Color Palette:** Earthy tones with seasonal variations, enhanced by 3D lighting and dynamic shadows
- **GPU-Accelerated Rendering:** All terrain and visual effects leveraging GPU for performance and scalability

### Key Visual Elements
- **Character Sprites:** Detailed pixel art animations positioned in 3D grid space
- **Environmental Sprites:** Vegetation, buildings, rocks, and terrain objects rendered as textured quads in grid cells
- **Terrain System:** GPU-generated procedurally textured terrain with shader-based heightmap and detail mapping
- **UI Design:** Clean, period-appropriate interface elements overlaid on 3D viewport
- **Special Effects:** GPU-accelerated particle systems for weather, fire, water, dust, and atmospheric effects

## Audio Design

### Soundscape
- **Ambient Audio:** Nature sounds, weather effects, settlement activity
- **Cultural Music:** Period-appropriate folk music from different cultures
- **Sound Effects:** Authentic tool/weapon sounds, animal calls, environmental audio

### Voice Acting
- **Language Diversity:** Multiple languages with subtitle options
- **Emotional Range:** Voice acting for key characters and major events
- **Cultural Authenticity:** Native language consultants for accuracy

## Technical Specifications

### Engine and Tools
- **Primary Engine:** Godot 4.x 3D Engine
- **Programming Language:** GDScript with GLSL/WGSL for GPU shaders
- **Version Control:** Git
- **Asset Creation:** Aseprite (sprites), Blender, Audacity
- **GPU Architecture:** Shader-based procedural generation for terrain and noise calculations

### Performance Targets
- **Resolution:** 1920x1080 minimum, scalable to 4K
- **Frame Rate:** 60 FPS target
- **Platform Support:** Windows 10+, macOS 10.15+, Linux (Ubuntu 18.04+)
- **File Size:** <2GB download size

### System Requirements
- **MINIMUM GPU REQUIRED:** GPU compute shader support is MANDATORY
  - NVIDIA: GeForce GTX 750+ (Kepler or newer)
  - AMD: Radeon RX series (RDNA or newer)
  - Intel: Arc series or Intel UHD 730+
  - Apple: Apple Silicon (M1+)
- **Minimum CPU:** Intel Core i3 or equivalent
- **RAM:** 4GB minimum, 8GB recommended
- **Dedicated GPU:** Strongly recommended for performance

### GPU-Based Procedural Generation (EXCLUSIVE)
- **Terrain Generation:** All heightmap and terrain mesh generation computed EXCLUSIVELY on GPU using compute shaders
- **Noise Calculations:** Perlin noise, Voronoi, and other procedural noise functions implemented as GPU shaders (NO CPU fallback)
- **Real-Time Generation:** Infinite world generation with streaming chunks computed entirely on GPU
- **LOD System:** GPU-driven Level of Detail system for terrain and mesh complexity scaling
- **Dynamic Texturing:** Shader-based terrain texturing using noise patterns and material blending
- **Hydrology Simulation:** GPU-computed water flow algorithms for realistic river generation, drainage basins, and water level determination
- **GPU Mandate:** GPU compute support is required to run the game - CPU-only systems cannot play this game
- **Performance Benefit:** GPU acceleration provides seamless world generation with no CPU bottlenecks

## Development Roadmap

### Phase 1: Core Prototype (Months 1-3)
- 3D engine setup with orthographic camera and grid system
- GPU-based terrain generation system with compute shaders
- Basic Perlin noise shader implementation
- 2D sprite rendering pipeline in 3D space (GridMap setup)
- Basic character movement and sprite positioning
- Initial UI framework adapted for 3D viewport
- Hydrology system foundation: water data structures and basic rendering

### Phase 2: Core Gameplay (Months 4-8)
- Advanced GPU shader development (biome generation, noise combinations)
- GPU-based water flow simulation and river generation
- Water quality mechanics and seasonal water level fluctuations
- Fishing mechanics and aquatic resource gathering
- Hydrology-based point-of-interest generation (fords, fishing grounds, water sources)
- Skill progression system
- Social interaction mechanics
- Quest and narrative framework
- GPU-optimized sprite batch rendering and LOD systems
- Procedural point-of-interest generation with GPU acceleration

### Phase 3: World Building (Months 9-12)
- Expanded GPU-accelerated world generation with streaming and culling
- Advanced hydrology features: waterfalls, rapids, wetlands, springs, flood events
- Water crossing mechanics: fording, bridge-building, finding shallow passages
- Settlement water dependency systems and pollution mechanics
- Settlement systems with GPU-driven placement and rendering
- Cultural faction mechanics
- GPU particle effects for weather, fire, water, and environmental effects
- Audio implementation
- Optimized terrain LOD and chunk generation pipeline

### Phase 4: Polish and Content (Months 13-16)
- Balance tuning
- Additional content creation
- Bug fixing and optimization
- Beta testing

### Phase 5: Launch and Post-Launch (Months 17-18+)
- Marketing and community building
- Launch preparation
- Post-launch support and updates

## Monetization Strategy

### Revenue Model
- **Primary:** Direct sale on Steam/Epic Games ($19.99 MSRP)
- **Secondary:** DLC content packs for additional regions/cultures
- **Tertiary:** Merchandise and community-supported development

### Marketing Approach
- **Target Demographics:** Historical simulation enthusiasts, RPG fans, educational gaming community
- **Platforms:** Steam, itch.io, official website
- **Community Building:** Discord server, development blogs, historical accuracy discussions

## Risk Assessment

### Technical Risks
- Procedural generation complexity
- Performance optimization for large worlds
- Cultural representation accuracy

### Content Risks
- Historical sensitivity and accuracy
- Balancing educational value with entertainment
- Scope creep in world-building features

### Mitigation Strategies
- Regular playtesting for balance
- Historical consultant collaboration
- Modular feature development
- Community feedback integration

## Success Metrics

### Quantitative Goals
- **User Acquisition:** 10,000+ initial sales
- **Retention:** 70% day-1 retention, 40% week-1 retention
- **Monetization:** $50,000+ first-year revenue
- **Community:** 1,000+ active Discord members

### Qualitative Goals
- **Critical Reception:** 80+ Metacritic score
- **Educational Impact:** Positive reviews for historical accuracy
- **Community Engagement:** Active modding community development

## Conclusion

Harsh World represents an ambitious vision for historical simulation gaming, combining survival mechanics with deep cultural exploration. By focusing on authentic representation and meaningful player choices, the game aims to create an immersive experience that educates while entertaining. The modular development approach and clear technical foundation position the project for successful completion within the planned timeline.

---

**Document Version:** 2.1
**Last Updated:** December 2, 2025
**Author:** BMAD Product Management Team

### Version History
- **v2.1:** Added comprehensive hydrology system to development scope, including GPU-computed water flow simulation, water mechanics, fishing systems, and hydrology-related point-of-interest generation integrated throughout the development roadmap
- **v2.0:** Updated architecture to use Godot 3D Engine with GPU-accelerated procedural generation, 2D sprites in 3D space with GridMap system, and shader-based terrain and noise calculations
- **v1.0:** Original 2D top-down design with CPU-based procedural generation