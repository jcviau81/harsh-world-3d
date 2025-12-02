

# **Hydrological Realism in Godot 4.5: A Guide to GPU-Accelerated Procedural Drainage Network Generation Using Raster GIS Techniques**

**Updated for Godot 3D Engine with GPU Compute Shaders (December 2, 2025)**

## **I. Architectural Foundation: GPU-Accelerated Flow Calculation in 3D Space**

The creation of a hydrologically realistic system within a procedurally generated 3D environment requires adopting advanced computational geoscience techniques, specifically those used in Geographic Information Systems (GIS) analysis, combined with GPU compute shader acceleration. The primary architectural consideration must be leveraging GPU compute shaders for all elevation data processing and flow calculations, while using the 3D engine to render 2D sprites positioned in 3D GridMap-style grid space. This approach allows the system to achieve realistic, globally coherent water flow with performance optimizations through GPU parallelization.

### **Conceptualizing the Digital Elevation Model (DEM) in a 3D GridMap Context**

The core of the system is the conceptual Digital Elevation Model (DEM), which stores elevation values ($Z$) derived from GPU-accelerated noise generation (Perlin, Voronoi, FBM). This conceptual grid acts purely as a calculation layer, processed entirely on the GPU. For the flow results to appear organic and high-fidelity, the resolution of this calculation grid must be significantly finer than the final GridMap resolution (e.g., $1024 \\times 1024$ for GPU calculation versus $256 \\times 256$ tiles for GridMap rendering). A higher resolution minimizes the angular artifacts inherent in grid-based flow modeling and provides more data points for shoreline complexity. All DEM processing is performed via GPU compute shaders for maximum performance.

### **Data Decoupling and Required Hydrology Data Grids**

Because the game’s elevation is primarily used for biome diversity and the visual terrain is flat, the integrity of the abstract DEM must be protected from the 2D rendering layer. This involves maintaining separate interpretations of the elevation data: one functional for hydrological modeling and one purely descriptive for biome assignment and game logic.2 The procedural generation process demands three primary output grids derived from the conceptual DEM, all stored at the high calculation resolution:

1. **Flow Direction Grid ($D\_{dir}$):** This raster stores the specific direction water would flow from any given cell.  
2. **Flow Accumulation Grid ($FA$):** This raster records the total number of upslope cells contributing water to the current cell, serving as a proxy for stream magnitude.  
3. **Water Depth/Level Grid ($W\_{depth}$):** This grid records the depth of standing water (lakes and ponds) relative to the surrounding conceptual terrain.

### **Defining Map Boundaries and the Global Sink (The Ocean)**

For the hydrology network to be cohesive and finite, all water flow must ultimately terminate at a single, known sink.4 In a world featuring oceans, the ocean must be defined as the ultimate lowest-elevation point, or the global sink.

This requires a post-processing step on the initial Perlin noise generation to enforce boundary conditions. A low-elevation skirt must be established around the perimeter of the map, guaranteeing that all flow paths, regardless of their origin, converge toward the map edges, where the Sea Level threshold ($E\_{sea}$) is defined.5 This enforcement ensures connectivity and prevents water flow from terminating mid-map in an undefined internal pit, a scenario which would otherwise necessitate an immediate pit removal process.

## **II. Core Algorithmic Implementation: GPU-Accelerated Flow Accumulation Pipeline**

Achieving hydrological realism mandates the implementation of specialized GIS methodologies using GPU compute shaders, moving beyond CPU-based particle tracing or L-systems to mathematically rigorous raster analysis methods executed on the GPU.8 The core process revolves around calculating Flow Accumulation entirely via GPU compute shaders. All algorithms (pit removal, D8 direction, flow accumulation) must be implemented as compute shader kernels for parallel execution.

### **Preprocessing the DEM: Pit Removal and Depression Identification**

The first critical step in the analytical pipeline is hydrological correction. Digital Elevation Models, especially those generated via noise functions, contain sinks or pits—areas completely surrounded by higher terrain.9 If left unhandled, these depressions cause the downhill flow calculation to stall, as water cannot find an outlet, thereby interrupting the continuous flow accumulation process.10

The necessity of hydrological correction before calculating Flow Direction is absolute. A raw DEM must be processed to create a "Depressionless DEM" (DDEM).9 If the D8 flow direction raster contains loops or unhandled sinks, the subsequent Flow Accumulation calculation will enter an endless cycle and never finish.12

However, the user requires lakes and ponds, which are, by definition, real sinks. This necessitates a dual processing approach:

1. **Sink Identification:** The raw DEM is used to identify all pit areas. These areas are potential candidates for lakes or ponds.  
2. **DDEM Creation (Filling):** A pit-filling method is applied to the raw DEM to raise the elevation of these pits to the level of their lowest adjacent neighbor or their watershed outlet elevation.14 This resulting DDEM is used strictly for calculating continuous flow direction and accumulation.  
3. **Lake Definition:** Only the identified sinks that meet specific area or depth criteria are designated as permanent water bodies, allowing the DDEM process to define the river network while preserving the desired standing water bodies.

The entire process must follow a strict causal chain of dependencies to ensure accurate output:

Table 1: Hydrological Generation Pipeline Dependencies

| Step | Input Data | Process/Algorithm | Output Data/Objective | Required for Next Step? |
| :---- | :---- | :---- | :---- | :---- |
| 1 | Raw DEM (Perlin) | Boundary Enforcement & Sink Identification | Enforced Ocean Sink, Identified Pit Areas | Yes (Flow Direction, Lake Formation) |
| 2 | Raw DEM \+ Pit Areas | Fill Sinks (Depression Filling) 14 | Depressionless DEM (DDEM) | Yes (D8 Flow Direction) |
| 3 | DDEM | D8 Flow Direction Algorithm 10 | Flow Direction Grid ($D\_{dir}$) | Yes (Flow Accumulation) |
| 4 | $D\_{dir}$ | Flow Accumulation (Iterative Upslope Count) 15 | Flow Accumulation Grid ($FA$) | Yes (Water Body Classification) |

### **D8 Flow Direction Algorithm: Calculation and Implementation**

The Deterministic 8 (D8) algorithm is the most common method for calculating flow direction in raster-based hydrology.16 The D8 method routes the flow from a central grid cell to only one of its eight adjacent or diagonal neighbors. This direction is calculated as the one offering the steepest descent, defined by the maximum elevation drop ($\\Delta Z$) divided by the horizontal travel distance (1 for cardinal directions, $\\sqrt{2}$ for diagonal directions).10

Flow directions are conventionally encoded using power-of-two integers (1, 2, 4, 8, 16, 32, 64, 128\) corresponding to the eight directions, simplifying storage and directional lookups.12 The DDEM ensures continuity; standard D8 implementations also include logic (such as the method by Garbrecht and Martz) to assign flow away from higher ground in perfectly flat areas, although this is less of a concern with continuous Perlin noise data.10

### **The Flow Accumulation Raster**

Once the Flow Direction Grid ($D\_{dir}$) is established using the DDEM, the Flow Accumulation ($FA$) raster can be calculated. $FA$ is determined by iteratively summing the contribution of all upslope cells that flow into a downslope cell.15 In its simplest form, where no weight raster is applied (such as rainfall data), the $FA$ value is merely the total number of upslope cells contributing area to the current cell.17

This accumulated value is a direct proxy for water volume or stream magnitude. A cell with an $FA$ value of zero indicates a local topographic high or a ridge line, as no upslope cells contribute to it.15 Conversely, cells with a high $FA$ value represent areas of concentrated flow and are used directly to delineate stream channels.15

When the $FA$ algorithm encounters a designated lake or pond area, flow calculation must be managed to maintain realism. The lake is treated as a uniform elevation plateau; flow enters at the point(s) defined by the inflowing $D\_{dir}$ and then exits through the predefined sink outlet point 14, ensuring that accumulated flow continues downstream.

## **III. Constructing the Water Layer: Lakes, Ponds, and Rivers**

The $FA$ grid is the defining dataset that translates the abstract conceptual DEM into actionable, classified water features for the game engine.

### **Defining Standing Water Bodies (Lakes and Ponds)**

Lakes and ponds are structurally defined by the boundaries of the depressions identified in the initial preprocessing step (Table 1, Step 1). The physical dimensions of the standing water body are determined by "flooding" the sink up to the elevation of its lowest defined outlet ($E\_{outlet}$).9

The water depth ($W\_{depth}$) is calculated precisely as the difference between the determined water surface elevation (the $E\_{outlet}$) and the original raw DEM elevation ($E\_{DEM}$): $W\_{depth} \= E\_{outlet} \- E\_{DEM}$.14 This calculation provides a natural depth gradient: the water is deepest at the original lowest point of the pit and approaches zero depth at the high-water mark (the shoreline defined by $E\_{outlet}$). This depth map is crucial for rendering realism in the Godot shader (Section IV.3).

### **Delineating the Stream Network: Threshold Analysis**

The primary objective of the $FA$ calculation is to extract the stream network. This is achieved by applying a flow accumulation threshold ($T$) to the $FA$ raster.15 Only cells where $FA \\ge T$ are designated as part of a continuous, permanent water channel.

The accumulated cell count ($FA$) serves as a sufficient proxy for hydrologic magnitude in a game environment, replacing the need for complex, real-world hydrologic criteria like cubic feet per second (cfs) flow volume.19 By classifying water features based on varying flow accumulation thresholds, the system can distinguish between small creeks and major rivers, which subsequently dictates their width, tile representation, and flow intensity.20

The following classification table outlines suggested parameters for segmenting the drainage network:

Table 2: Flow Accumulation Threshold Parameters for Water Body Classification

| Water Body Type | Flow Accumulation Threshold (TFA​, cells) | Conceptual Magnitude | Visual Characteristics (Godot) | TileSet Requirement |
| :---- | :---- | :---- | :---- | :---- |
| Minor Creek/Rivulet | $10 \\le T\_{FA} \< 100$ | Headwaters, low flow | Narrowest channel, minimal foam/wake | Simple channel tiles |
| Major Creek/Stream | $100 \\le T\_{FA} \< 500$ | Perennial flow, small watershed | Increased width, distinct flow direction | Autotiling for bends and confluence |
| River (Main Channel) | $T\_{FA} \\ge 500$ | High volume, major drainage | Widest, deepest channel, fastest calculated flow | Advanced autotiling (three-cell width) |
| Lake/Pond | Defined by $W\_{depth}$ | Static Water Body | Water depth gradient, no directional flow | Shoreline blending (Terrain Set) |
| Ocean | Boundary Sink | Infinite Sink | Deepest water, highly reflective surface | Border tiles/boundary shader |

### **Refining River Geometry for Realism**

A limitation of the D8 methodology is its restriction of flow directions to multiples of 45 degrees, which results in streams that appear angular and unrealistic, lacking the sinuosity found in natural river systems.16 This lack of meandering features, often caused by differential flow speeds and inertia in real systems 21, must be mitigated through post-processing.

One solution is to introduce stochastic variation to the flow path calculation, such as using the Rho8 algorithm, a stochastic variant of D8 that helps break the strict 45-degree alignment.16 Alternatively, a lightweight hydraulic erosion simulation can be employed. The $FA$ path defines where water concentrates; running a simplified particle tracing model that applies small local height modifications proportional to $FA$ can carve smoother, more sinuous channels into the conceptual DEM.21 This smoothing process introduces complexity that more closely resembles natural geological features.

## **IV. Godot 4.5 3D Engine Implementation via GPU Compute Shaders and GridMap**

The successful translation of the high-resolution raster data into a dynamic, visually appealing Godot 3D environment is essential. This requires leveraging Godot 4.5 3D features, specifically GPU compute shaders for all data generation and GridMap for world structure, combined with the advanced 3D shader system.

### **Data Structure and GPU-Based Computation in Godot 4.5 3D**

The most efficient strategy for implementing this system is to compute all hydrological data ($D\_{dir}, FA, W\_{depth}$) via GPU compute shaders and store results in specialized texture resources (Data Maps). GridMap is then used for discrete visual classification (placing water tiles, biome elements) while the continuous numerical hydrology data is sampled by custom 3D shaders for realistic water rendering. This GPU-first approach avoids any CPU bottleneck and leverages parallel shader computation for fast chunk generation.

The mapping strategy ensures that the computationally expensive flow data is pre-calculated and passed directly to the GPU for rendering:

Table 3: Godot 4.5 3D Engine Data Layer Mapping Strategy

| Data Raster/Value | Target Layer/Storage in Godot | Purpose | Format/Scale |
| :---- | :---- | :---- | :---- |
| Water Type (Creek, River, Lake) | GridMap Water Layer (Cell Data) | Visual classification, 3D placement | Integer ID (Mesh Index) |
| Flow Direction ($D\_{dir}$) | GPU Compute Texture Output | Input to D8/FA compute shaders | Normalized Angle (0-1) or D8 Integer |
| Flow Accumulation ($FA$) | GPU-Computed Texture (R Channel) | Input to water shader, flow speed, magnitude | Normalized Value (0-1) |
| Water Depth ($W\_{depth}$) | GPU-Computed Texture (G Channel) | Input to water shader, depth gradient, opacity | Normalized Value (0-1) |
| Biome/Terrain Type | GridMap Terrain Layer | Visual classification via 3D grid | Integer ID (Mesh Index) |

### **3D Mesh Placement and Water Body Rendering in GridMap**

Godot 4's GridMap system manages spatial placement in 3D space. For water bodies, the strategy is to:

1. **GPU Compute Shader Processing**: All hydrology calculations ($D\_{dir}$, $FA$, $W\_{depth}$) are computed via compute shaders and stored as texture data.
2. **GridMap Placement**: Water meshes are placed in the GridMap based on calculated $FA$ thresholds:
   - Minor creeks: $T\_{FA} < 100$ cells (narrow water quads)
   - Major streams: $100 \le T\_{FA} < 500$ cells (medium width)
   - Rivers: $T\_{FA} \ge 500$ cells (wide water quads)
   - Lakes: Defined by depression areas, variable depth

3. **Shader-Based Rendering**: Custom 3D shaders sample the Data Maps ($D\_{dir}$, $FA$, $W\_{depth}$) to render:
   - Flow direction using flow maps
   - Water depth using the $W\_{depth}$ texture
   - Realistic refraction and opacity based on depth
   - Dynamic wave motion modulated by flow accumulation

All mesh placement is deterministic based on GPU-computed hydrology data, eliminating the need for complex constraint satisfaction algorithms. The GPU directly determines placement via compute shader output.

### **Dynamic Water Visuals with GPU Shaders**

The aesthetic realism of the water layer is driven by custom 3D fragment shaders applied to water meshes in the GridMap. These shaders dynamically interpret the baked Data Maps (computed via GPU compute shaders) to produce movement, depth, and interaction effects. All shader operations leverage GPU parallelization for efficient real-time rendering.

#### **Depth and Refraction Modeling**

The $W\_{depth}$ value, read from the dedicated texture channel (Table 3), governs the visual characteristics of depth:

1. **Opacity and Color:** Deeper water areas (higher $W\_{depth}$) should be rendered with darker colors and higher opacity, simulating thick or murky water. Lakes and deep rivers have maximum opacity.
2. **Refraction and Shoreline Visibility:** Refraction effects using screen-space techniques should be scaled inversely with depth. Shallower areas should show more distortion and greater visibility of the underlying terrain, providing a strong sense of interaction at the shoreline.

#### **Flow Visualization using GPU-Computed Flow Maps**

The $D\_{dir}$ data, computed via GPU shaders, is the source for dynamic water movement. This data is translated into a 3D vector field—a Flow Map—which is used within the fragment shader to distort the water texture's UV coordinates over time. This process simulates the visual appearance of current flow.

The speed and intensity of this UV offset distortion are directly modulated by the Flow Accumulation ($FA$) value. Rivers with high $FA$ values (main channels) will exhibit faster and more aggressive wave motion than minor creeks, naturally linking the visual speed of the water to its calculated hydrologic magnitude.

## **V. Optimization and Production Considerations**

Integrating complex computational geoscience methods into a game environment, especially for a procedurally generated world of potentially infinite size, requires strategic architectural choices focused on performance.

### **Performance and GPU-Accelerated Chunk Generation**

The Flow Accumulation algorithm is inherently non-local; the flow value of any given cell depends entirely on the terrain features and flow paths originating from every upslope cell.33 In an infinite 3D world, the calculation pipeline (Table 1) must be executed chunk-by-chunk as the player approaches, with GPU compute shaders handling all calculations.

The $FA$ calculation for a new chunk relies on the elevation and $D\_{dir}$ outputs of all neighboring upslope chunks that have already been generated. The procedural system must therefore resolve the DEM and $D\_{dir}$ data across chunk boundaries first, establishing continuity, via GPU compute shaders, before the $FA$ calculation for the current visible chunk can be finalized.

**Critical: All D8 and Flow Accumulation calculations MUST be executed via GPU compute shaders for performance.** CPU-based execution is not acceptable and would create severe bottlenecks. The GPU parallelization of these algorithms is essential for maintaining 60 FPS during chunk streaming. Godot's RenderingDevice API provides the necessary compute shader infrastructure to execute these raster calculations directly on the GPU, with results stored in texture buffers for rendering and further computation.

### **Extending Realism: GPU-Computed Hydraulic Erosion and Meandering**

While the initial DEM provides the base for the hydrology system, integrating a simplified hydraulic erosion model (via compute shaders) greatly enhances the realism of the resulting river channels. The Flow Accumulation grid accurately indicates where concentrated flow occurs. By using the $FA$ value as a local weighting factor in a compute shader, the system can apply minor, localized modifications to the conceptual DEM, carving the channel deeper proportional to the flow magnitude.

This localized depth modification is computed on the GPU and is crucial for realism. Even though the visual 3D terrain uses 2D sprites in GridMap, the act of "carving" the conceptual DEM (via GPU shader) ensures that the calculated channel depth is intrinsically linked to the river's magnitude. This GPU-driven modification reinforces geological plausibility, preventing wide, high-FA rivers from appearing shallow in the calculated depth map. This also contributes to the sinuosity and overall visual quality of the resulting river shape through shader-based computation.

### **Integration with Biome System**

The generated hydrological data is not merely a visual layer; it provides fundamental data for game logic, particularly biome placement and density.2 The system should leverage the outputs $W\_{depth}$ and $FA$:

* **Saturation and Wetlands:** Areas with a small, positive $W\_{depth}$ (indicating standing water just below the surface) or regions immediately adjacent to high $FA$ channels should be classified as high-humidity environments, triggering the placement of marsh, wetland, or riverside biomes.3  
* **Ridges and Arid Zones:** Cells identified with an $FA$ value of zero correspond to local topographic highs and ridges.15 These areas should logically correlate with low-humidity or dry biomes, maintaining the natural interdependence between elevation, water flow, and ecological distribution.

## **Conclusions**

To achieve a hydrologically realistic 3D procedural system in Godot 4.5 using GPU acceleration, simple Perlin noise flow generation must be replaced by a structured GIS analysis pipeline executed entirely on the GPU. This approach is founded on using a high-resolution conceptual Digital Elevation Model (DEM) that is processed through three mandatory GPU compute shader steps:

1. **Hydrological Correction (GPU):** Removing all sinks (pits) to create a Depressionless DEM (DDEM) via compute shaders, guaranteeing flow continuity while cataloging real sinks for lake generation.
2. **D8 Flow Direction (GPU):** Calculating the direction of steepest descent across the DDEM using GPU parallelization.
3. **Flow Accumulation (GPU):** Iteratively counting the upslope contributing area on the GPU to quantify stream magnitude.

The calculated $FA$ values are then used as the definitive measure to classify water bodies (creeks, rivers) via threshold analysis and to calculate water depth ($W\_{depth}$) in lake areas, all computed on the GPU.

For implementation in Godot 4.5 3D Engine, all raster computations ($D\_{dir}, FA, W\_{depth}$) are performed via GPU compute shaders and stored as texture maps (Data Maps). These Data Maps are passed to custom 3D fragment shaders applied to water meshes in the GridMap. The shaders utilize the $W\_{depth}$ map to drive realistic depth effects (opacity, refraction) and use the $D\_{dir}$ and $FA$ maps to generate dynamic flow maps, controlling the speed and direction of texture distortion. Godot's GridMap system is employed to discretely place water meshes based on computed $FA$ thresholds, while the GPU shaders provide continuous visual effects. This architecture—with GPU compute shaders handling all calculations and 3D rendering, GridMap managing spatial placement, and 2D sprite assets providing visual representation in 3D space—achieves both high fidelity and exceptional performance in a large, procedurally generated world, all powered by GPU parallelization.

#### **Works cited**

1. Dynamic Procedural Generation of Terrain with Hydrologic Systems, accessed on November 27, 2025, [https://www.cs.rpi.edu/\~cutler/classes/advancedgraphics/S21/final\_projects/frankj6.pdf](https://www.cs.rpi.edu/~cutler/classes/advancedgraphics/S21/final_projects/frankj6.pdf)  
2. Procedural Content Generation (PCG) Biome Core and Sample Plugins Reference Guide in Unreal Engine \- Epic Games Developers, accessed on November 27, 2025, [https://dev.epicgames.com/documentation/en-us/unreal-engine/procedural-content-generation-pcg-biome-core-and-sample-plugins-reference-guide-in-unreal-engine](https://dev.epicgames.com/documentation/en-us/unreal-engine/procedural-content-generation-pcg-biome-core-and-sample-plugins-reference-guide-in-unreal-engine)  
3. How are randomly placed structures generated in a procedurally generated infinite world? : r/proceduralgeneration \- Reddit, accessed on November 27, 2025, [https://www.reddit.com/r/proceduralgeneration/comments/4eixfr/how\_are\_randomly\_placed\_structures\_generated\_in\_a/](https://www.reddit.com/r/proceduralgeneration/comments/4eixfr/how_are_randomly_placed_structures_generated_in_a/)  
4. Procedural river drainage basins \- Red Blob Games, accessed on November 27, 2025, [https://www.redblobgames.com/x/1723-procedural-river-growing/](https://www.redblobgames.com/x/1723-procedural-river-growing/)  
5. Polygonal Map Generation for Games \- Stanford, accessed on November 27, 2025, [http://www-cs-students.stanford.edu/\~amitp/game-programming/polygon-map-generation/](http://www-cs-students.stanford.edu/~amitp/game-programming/polygon-map-generation/)  
6. Inverse Procedural Modeling by Automatic Generation of L-systems, accessed on November 27, 2025, [https://www.cs.jhu.edu/\~misha/ReadingSeminar/Papers/Stava10.pdf](https://www.cs.jhu.edu/~misha/ReadingSeminar/Papers/Stava10.pdf)  
7. CIS 460 Final Project \- Mini Minecraft Milestone 2, accessed on November 27, 2025, [https://www.cis.upenn.edu/\~cis4600/20fa/hw/hwMM02/mini\_minecraft\_02.html](https://www.cis.upenn.edu/~cis4600/20fa/hw/hwMM02/mini_minecraft_02.html)  
8. Procedural Generation of Landscapes with Water Bodies Using Artificial Drainage Basins \- CGVR, accessed on November 27, 2025, [https://cgvr.cs.uni-bremen.de/papers/cgi22/CGI22.pdf](https://cgvr.cs.uni-bremen.de/papers/cgi22/CGI22.pdf)  
9. How Sink works—ArcGIS Pro | Documentation, accessed on November 27, 2025, [https://pro.arcgis.com/en/pro-app/3.4/tool-reference/spatial-analyst/how-sink-works.htm](https://pro.arcgis.com/en/pro-app/3.4/tool-reference/spatial-analyst/how-sink-works.htm)  
10. D8 Flow Directions, accessed on November 27, 2025, [https://hydrology.usu.edu/taudem/taudem5/help53/d8flowdirections.html](https://hydrology.usu.edu/taudem/taudem5/help53/d8flowdirections.html)  
11. ANALYSIS OF THE PIT REMOVAL METHODS IN DIGITAL TERRAIN MODELS OF VARIOUS RESOLUTIONS, accessed on November 27, 2025, [https://isprs-archives.copernicus.org/articles/XLI-B2/235/2016/](https://isprs-archives.copernicus.org/articles/XLI-B2/235/2016/)  
12. Flow Accumulation | ArcGIS REST APIs \- Esri Developer, accessed on November 27, 2025, [https://developers.arcgis.com/rest/services-reference/enterprise/flow-accumulation/](https://developers.arcgis.com/rest/services-reference/enterprise/flow-accumulation/)  
13. Flow Accumulation (Spatial Analyst)—ArcMap | Documentation, accessed on November 27, 2025, [https://desktop.arcgis.com/en/arcmap/latest/tools/spatial-analyst-toolbox/flow-accumulation.htm](https://desktop.arcgis.com/en/arcmap/latest/tools/spatial-analyst-toolbox/flow-accumulation.htm)  
14. Filling sinks in DEMs like an expert \- Esri, accessed on November 27, 2025, [https://www.esri.com/arcgis-blog/products/arcgis-pro/analytics/filling-sinks-in-dems-like-an-expert](https://www.esri.com/arcgis-blog/products/arcgis-pro/analytics/filling-sinks-in-dems-like-an-expert)  
15. How Flow Accumulation works—ArcGIS Pro | Documentation, accessed on November 27, 2025, [https://pro.arcgis.com/en/pro-app/latest/tool-reference/spatial-analyst/how-flow-accumulation-works.htm](https://pro.arcgis.com/en/pro-app/latest/tool-reference/spatial-analyst/how-flow-accumulation-works.htm)  
16. Given a terrain, how to draw the stream flow path? \- GIS StackExchange, accessed on November 27, 2025, [https://gis.stackexchange.com/questions/14622/given-a-terrain-how-to-draw-the-stream-flow-path](https://gis.stackexchange.com/questions/14622/given-a-terrain-how-to-draw-the-stream-flow-path)  
17. Flow-Based Method for Stream Generation in a GIS \- Maryland-Delaware-D.C. Water Science Center, accessed on November 27, 2025, [https://md.water.usgs.gov/preview/posters/flowGIS/index.html](https://md.water.usgs.gov/preview/posters/flowGIS/index.html)  
18. Water bodies \- Procedural World, accessed on November 27, 2025, [http://procworld.blogspot.com/2013/10/water-bodies.html](http://procworld.blogspot.com/2013/10/water-bodies.html)  
19. What Flow Accumulation Threshold Should I Use? \- Esri Community, accessed on November 27, 2025, [https://community.esri.com/t5/water-resources-blog/what-flow-accumulation-threshold-should-i-use/ba-p/1633241](https://community.esri.com/t5/water-resources-blog/what-flow-accumulation-threshold-should-i-use/ba-p/1633241)  
20. \[AM-04-066\] Watersheds and Drainage Networks \- UCGIS Bok Visualizer and Search, accessed on November 27, 2025, [https://gistbok-topics.ucgis.org/AM-04-066](https://gistbok-topics.ucgis.org/AM-04-066)  
21. more in depth overview of my procedural terrain with hydraulic erosion : r/proceduralgeneration \- Reddit, accessed on November 27, 2025, [https://www.reddit.com/r/proceduralgeneration/comments/1bmhl3b/more\_in\_depth\_overview\_of\_my\_procedural\_terrain/](https://www.reddit.com/r/proceduralgeneration/comments/1bmhl3b/more_in_depth_overview_of_my_procedural_terrain/)  
22. D8/Rho8 flow accumulation \- John Lindsay, accessed on November 27, 2025, [https://jblindsay.github.io/ghrg/Whitebox/Help/FlowAccumD8.html](https://jblindsay.github.io/ghrg/Whitebox/Help/FlowAccumD8.html)  
23. TileMapLayer — Godot Engine (4.5) documentation in English, accessed on November 27, 2025, [https://docs.godotengine.org/en/4.5/classes/class\_tilemaplayer.html](https://docs.godotengine.org/en/4.5/classes/class_tilemaplayer.html)  
24. I built a procedural 2D water system that uses a TileMap bake and single shader : r/godot, accessed on November 27, 2025, [https://www.reddit.com/r/godot/comments/1o6f6n9/i\_built\_a\_procedural\_2d\_water\_system\_that\_uses\_a/](https://www.reddit.com/r/godot/comments/1o6f6n9/i_built_a_procedural_2d_water_system_that_uses_a/)  
25. Coding Challenge \#24: Perlin Noise Flow Field \- YouTube, accessed on November 27, 2025, [https://www.youtube.com/watch?v=BjoM9oKOAKY](https://www.youtube.com/watch?v=BjoM9oKOAKY)  
26. Auto Tiling A 2D Platformer In Godot 4 \- Tutorial \- YouTube, accessed on November 27, 2025, [https://www.youtube.com/watch?v=EO6hRcPCOms](https://www.youtube.com/watch?v=EO6hRcPCOms)  
27. Flow Map Shader \- Godot Asset Library, accessed on November 27, 2025, [https://godotengine.org/asset-library/asset/246](https://godotengine.org/asset-library/asset/246)  
28. So I Made A Water Shader In Godot 4 And It Was Quite Simple \- YouTube, accessed on November 27, 2025, [https://www.youtube.com/watch?v=CNE7EOVlYLY](https://www.youtube.com/watch?v=CNE7EOVlYLY)  
29. Terrain Autotiling and Alternative Tiles \~ Godot 4 Tutorial for Beginners \- YouTube, accessed on November 27, 2025, [https://www.youtube.com/watch?v=vV8uKN1VnN4](https://www.youtube.com/watch?v=vV8uKN1VnN4)  
30. What is the use-case for Godot 4 terrains (vs Godot 3 autotiles) \- Reddit, accessed on November 27, 2025, [https://www.reddit.com/r/godot/comments/15q7qbz/what\_is\_the\_usecase\_for\_godot\_4\_terrains\_vs\_godot/](https://www.reddit.com/r/godot/comments/15q7qbz/what_is_the_usecase_for_godot_4_terrains_vs_godot/)  
31. Complex Autotile Inclines (Godot Tutorial 3.2) \- YouTube, accessed on November 27, 2025, [https://www.youtube.com/watch?v=HiM\_ksA6E2Y](https://www.youtube.com/watch?v=HiM_ksA6E2Y)  
32. Perlin Noise \- Flow Field \- David's Raging Nexus, accessed on November 27, 2025, [https://ragingnexus.com/creative-code-lab/experiments/perlin-noise-flow-field/](https://ragingnexus.com/creative-code-lab/experiments/perlin-noise-flow-field/)  
33. Procedural rivers on an infinite 2d tile map : r/proceduralgeneration \- Reddit, accessed on November 27, 2025, [https://www.reddit.com/r/proceduralgeneration/comments/78ytcj/procedural\_rivers\_on\_an\_infinite\_2d\_tile\_map/](https://www.reddit.com/r/proceduralgeneration/comments/78ytcj/procedural_rivers_on_an_infinite_2d_tile_map/)