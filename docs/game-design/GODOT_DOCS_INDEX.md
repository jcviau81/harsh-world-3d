# Godot 4.5 Documentation Quick Reference Index

Quick access to the most commonly needed Godot 4.5 documentation sections. All paths are relative to `docs/godot-docs-html-stable/`.

## Core Concepts

### Getting Started
- **Introduction to Godot**: `getting_started/introduction/index.html`
- **First Steps**: `getting_started/step_by_step/index.html`
- **The Scene System**: `getting_started/step_by_step/scenes_and_nodes.html`
- **Signals**: `getting_started/step_by_step/signals.html`
- **Scripting with GDScript**: `getting_started/scripting/gdscript/index.html`

### Nodes and Scenes
- **Node Class Reference**: `classes/class_node.html`
- **Scene Format**: `getting_started/step_by_step/scenes_and_nodes.html`
- **Scene Instantiation**: `tutorials/3d/using_3d_scenes/instantiating_scenes.html`
- **Nodes and Scenes Overview**: `tutorials/3d/using_3d_scenes/index.html`

## Input Handling

- **Using Input Events**: `tutorials/inputs/using_inputs/index.html`
- **Action Mapping**: `tutorials/inputs/using_inputs/input_examples.html`
- **Input Class Reference**: `classes/class_input.html`

## Physics

### 2D Physics
- **2D Physics Overview**: `tutorials/physics/using_2d_physics/index.html`
- **RigidBody2D**: `classes/class_rigidbody2d.html`
- **CharacterBody2D**: `classes/class_characterbody2d.html`
- **2D Physics Shapes**: `tutorials/physics/using_2d_physics/physics_introduction.html`

### 3D Physics (Primary for Harsh World)
- **3D Physics Overview**: `tutorials/physics/using_3d_physics/index.html`
- **RigidBody3D**: `classes/class_rigidbody3d.html`
- **CharacterBody3D**: `classes/class_characterbody3d.html`
- **3D Physics Shapes**: `tutorials/physics/using_3d_physics/physics_introduction.html`
- **Character Controller Example**: `tutorials/3d/using_3d_characters/physics_based_character_controller.html`
- **GridMap**: `classes/class_gridmap.html` (for 3D grid-based world)

### Collisions
- **Collision Shapes**: `tutorials/physics/using_2d_physics/using_2d_shapes.html`
- **Raycasting**: `tutorials/physics/using_2d_physics/using_2d_shapes.html`
- **Areas and Collision Detection**: `tutorials/physics/using_2d_physics/using_area_2d.html`

## Graphics and Rendering

### 2D Graphics (Asset Format)
- **Canvas and Layers**: `tutorials/2d/canvas_layers/index.html`
- **2D Drawing**: `tutorials/2d/custom_drawing_in_2d/index.html`
- **Sprites**: `classes/class_sprite2d.html` (used as sprite atlas textures)

### 3D Graphics (Primary Rendering Engine)
- **3D Introduction**: `tutorials/3d/introduction_to_3d/index.html`
- **3D Scenes**: `tutorials/3d/using_3d_scenes/index.html`
- **3D Models**: `tutorials/3d/using_3d_models/index.html`
- **Cameras**: `classes/class_camera3d.html` (orthographic for 2D-like view)
- **Viewports**: `classes/class_viewport.html`
- **GridMap**: `classes/class_gridmap.html` (grid-based world structure)

### Rendering and Shaders
- **Materials**: `tutorials/3d/standard_material_3d/index.html`
- **Shaders**: `tutorials/shaders/index.html`
- **Custom Shaders**: `tutorials/shaders/using_shaders/index.html`
- **Compute Shaders**: `tutorials/shaders/compute_shaders.html` (GPU terrain generation)
- **RenderingDevice API**: `classes/class_renderingdevice.html` (GPU compute)

## Animation

- **Animation Overview**: `tutorials/animation/index.html`
- **Using AnimationPlayer**: `tutorials/animation/using_the_animation_player.html`
- **Using AnimationTree**: `tutorials/animation/using_the_animation_tree.html`
- **AnimationPlayer Class**: `classes/class_animationplayer.html`

## Audio

- **Audio Overview**: `tutorials/audio/index.html`
- **Audio Streams**: `tutorials/audio/audio_streams.html`
- **AudioStreamPlayer**: `classes/class_audiostreamplayer.html`
- **Audio Effects**: `tutorials/audio/audio_buses.html`

## UI (User Interface)

- **UI Overview**: `tutorials/ui/index.html`
- **Canvas Layers and Viewports**: `tutorials/ui/using_3d_characters/index.html`
- **Control Nodes**: `classes/class_control.html`
- **Custom UI**: `tutorials/ui/custom_gui_controls.html`

## Advanced Topics

### Signals and Events
- **Signals Documentation**: `getting_started/step_by_step/signals.html`
- **Advanced Signals**: `tutorials/scripting/gdscript/signals.html`

### Scripting
- **GDScript Overview**: `getting_started/scripting/gdscript/index.html`
- **GDScript Basics**: `tutorials/scripting/gdscript/gdscript_basics.html`
- **GDScript Classes**: `tutorials/scripting/gdscript/class_as_namespace.html`
- **Advanced GDScript**: `tutorials/scripting/gdscript/gdscript_advanced.html`

### Multithreading
- **Threading**: `tutorials/scripting/gdscript/gdscript_basics.html`

### Networking
- **Multiplayer Documentation**: `tutorials/networking/index.html`
- **MultiplayerAPI**: `classes/class_multiplayerapi.html`
- **RPC**: `tutorials/networking/high_level_multiplayer.html`

## GPU and Compute Shaders

- **RenderingDevice API**: `classes/class_renderingdevice.html`
- **Compute Shaders**: `tutorials/shaders/compute_shaders.html`
- **Shader Language**: `tutorials/shaders/shader_reference/index.html`
- **FastNoiseLite**: `classes/class_fastnoiselite.html` (CPU fallback for noise)
- **GPU Textures and Buffers**: `tutorials/3d/using_3d_models/importing_3d_models/index.html`

## Performance and Optimization

- **Performance Optimization**: `engine_details/best_practices/introduction.html`
- **Debugging**: `engine_details/debugging/index.html`
- **Profiling**: `engine_details/debugging/profiling_the_project.html`
- **GDScript Optimization**: `tutorials/scripting/gdscript/static_typing.html`
- **GPU Performance**: `engine_details/rendering/gpu_optimization.html`

## API Reference

- **Complete Class List**: `classes/index.html`
- **Built-in Types**: `tutorials/scripting/gdscript/builtin_types.html`
- **Global Scope**: `classes/class_@globalscope.html`

## File Structure

```
godot-docs-html-stable/
├── getting_started/       # Beginner tutorials
│   ├── introduction/
│   ├── step_by_step/     # Start here!
│   └── scripting/
├── tutorials/            # Detailed guides by topic
│   ├── 2d/
│   ├── 3d/
│   ├── animation/
│   ├── audio/
│   ├── inputs/
│   ├── physics/
│   ├── scripting/
│   ├── shaders/
│   ├── ui/
│   └── networking/
├── engine_details/       # Engine internals and performance
├── classes/              # Complete API reference
└── community/            # Community resources
```

## Quick Navigation Tips

### Finding Information

1. **By Topic**: Look in `tutorials/` (e.g., `tutorials/physics/`)
2. **By Class Name**: Look in `classes/` (e.g., `classes/class_rigidbody3d.html`)
3. **Beginner Content**: Start with `getting_started/step_by_step/`
4. **Advanced Topics**: Check `engine_details/` and `tutorials/scripting/`

### Search Functions

- Use the browser's Find function (Ctrl+F) to search within pages
- The HTML docs include a searchindex.js for global searching
- Check `genindex.html` for alphabetical index of all content

## Common Tasks

### I want to learn...

| Task | Reference |
|------|-----------|
| ...the Node system | `getting_started/step_by_step/scenes_and_nodes.html` |
| ...about Signals | `getting_started/step_by_step/signals.html` |
| ...GDScript | `getting_started/scripting/gdscript/index.html` |
| ...3D Physics (Primary) | `tutorials/physics/using_3d_physics/index.html` |
| ...2D Physics | `tutorials/physics/using_2d_physics/index.html` |
| ...Animation | `tutorials/animation/using_the_animation_player.html` |
| ...Custom Shaders | `tutorials/shaders/using_shaders/index.html` |
| ...GPU Compute Shaders | `tutorials/shaders/compute_shaders.html` |
| ...GridMap 3D Grid | `classes/class_gridmap.html` |
| ...UI design | `tutorials/ui/index.html` |
| ...Networking | `tutorials/networking/index.html` |
| ...GPU Performance | `engine_details/rendering/gpu_optimization.html` |
| ...Overall Performance | `engine_details/best_practices/introduction.html` |

---

**Pro Tip**: When asking Claude Code for help with a specific feature, reference the relevant documentation file path. Example:

"Check `docs/godot-docs-html-stable/tutorials/physics/using_3d_physics/physics_based_character_controller.html` for reference on implementing player movement."

This helps Claude provide more accurate and contextual solutions.
