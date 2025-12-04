## GPU Compute Shader-based Terrain Generation
## Provides deterministic heightmap generation using RenderingDevice API
## Input: chunk_x, chunk_y, seed → Output: 32x32 heightmap (PackedFloat32Array)

class_name TerrainGenerator
extends Node3D

# ============================================
# CONSTANTS
# ============================================
const CHUNK_SIZE: int = 32  # 32x32 pixels per chunk
const HEIGHTMAP_SIZE: int = 1024  # 32 * 32
const SHADER_PATH: String = "res://src/shaders/heightmap_compute.glsl"

# ============================================
# VARIABLES
# ============================================
var _rendering_device: RenderingDevice
var _compute_pipeline: RID
var _shader: RID
var _is_initialized: bool = false
var _gpu_supports_compute: bool = false

# ============================================
# LIFECYCLE
# ============================================

func _ready() -> void:
	"""Initialize GPU compute pipeline on startup."""
	_initialize_gpu()


func _initialize_gpu() -> void:
	"""Set up RenderingDevice and compile compute shader."""

	# Create local rendering device
	_rendering_device = RenderingServer.create_local_rendering_device()
	if _rendering_device == null:
		push_error("TerrainGenerator: Failed to create RenderingDevice")
		_is_initialized = false
		return

	# Load and compile shader
	if not _load_shader():
		push_error("TerrainGenerator: Failed to load compute shader")
		_is_initialized = false
		return

	# Create compute pipeline
	if not _create_pipeline():
		push_error("TerrainGenerator: Failed to create compute pipeline")
		_is_initialized = false
		return

	_gpu_supports_compute = true
	_is_initialized = true
	print("TerrainGenerator: GPU compute initialized successfully")


func _load_shader() -> bool:
	"""Load and compile GLSL compute shader to SPIR-V."""

	# Load shader source
	var shader_file = load(SHADER_PATH)
	if shader_file == null:
		push_error("TerrainGenerator: Shader file not found at ", SHADER_PATH)
		return false

	# Create ShaderFile and compile to SPIR-V
	var shader_spirv: RDShaderSPIRV = shader_file.get_spirv()
	if shader_spirv == null:
		push_error("TerrainGenerator: Failed to compile shader to SPIR-V")
		return false

	# Create shader from SPIR-V
	_shader = _rendering_device.shader_create_from_spirv(shader_spirv)
	if _shader == RID():
		push_error("TerrainGenerator: Failed to create shader from SPIR-V")
		return false

	return true


func _create_pipeline() -> bool:
	"""Create compute pipeline from compiled shader."""

	if _shader == RID():
		push_error("TerrainGenerator: Cannot create pipeline without valid shader")
		return false

	_compute_pipeline = _rendering_device.compute_pipeline_create(_shader)
	if _compute_pipeline == RID():
		push_error("TerrainGenerator: Failed to create compute pipeline")
		return false

	return true


# ============================================
# PUBLIC API
# ============================================

func generate_heightmap(chunk_x: int, chunk_y: int, seed: int) -> PackedFloat32Array:
	"""
	Generate a single 32x32 heightmap for the given chunk.

	Args:
		chunk_x: Chunk X coordinate
		chunk_y: Chunk Y coordinate
		seed: World seed for determinism

	Returns:
		PackedFloat32Array with 1024 float32 values (32x32) in range [0.0, 1.0]
	"""

	if not _is_initialized:
		push_error("TerrainGenerator: GPU not initialized")
		return PackedFloat32Array()

	# Allocate output buffer (32x32 = 1024 pixels, 1 channel float32)
	var output_buffer = _rendering_device.storage_buffer_create(
		HEIGHTMAP_SIZE * 4,  # 1024 pixels * 4 bytes per float32
		PackedByteArray()
	)

	if output_buffer == RID():
		push_error("TerrainGenerator: Failed to allocate output buffer")
		return PackedFloat32Array()

	# Create uniform buffer for shader parameters
	var uniform_data = PackedInt32Array([chunk_x, chunk_y, seed])
	var uniform_bytes = uniform_data.to_byte_array()
	var uniform_buffer = _rendering_device.uniform_buffer_create(
		uniform_bytes.size(),
		uniform_bytes
	)

	if uniform_buffer == RID():
		push_error("TerrainGenerator: Failed to create uniform buffer")
		_rendering_device.free_rid(output_buffer)
		return PackedFloat32Array()

	# Create uniform set binding
	var uniform_set = _rendering_device.uniform_set_create(
		[
			RDUniform.new()
		],
		_shader,
		0
	)

	if uniform_set == RID():
		push_error("TerrainGenerator: Failed to create uniform set")
		_rendering_device.free_rid(output_buffer)
		_rendering_device.free_rid(uniform_buffer)
		return PackedFloat32Array()

	# Dispatch compute (32x32 threads, 8x8 local size = 4x4 work groups)
	var compute_list = _rendering_device.compute_list_begin()
	_rendering_device.compute_list_bind_compute_pipeline(compute_list, _compute_pipeline)
	_rendering_device.compute_list_bind_uniform_set(compute_list, uniform_set, 0)
	_rendering_device.compute_list_dispatch(compute_list, 4, 4, 1)  # 4x4 work groups of 8x8 threads
	_rendering_device.compute_list_end()

	# Synchronize to ensure computation completes
	_rendering_device.submit()
	_rendering_device.sync()

	# Read results back from GPU
	var result_bytes = _rendering_device.buffer_get_data(output_buffer)

	# Clean up GPU resources
	_rendering_device.free_rid(output_buffer)
	_rendering_device.free_rid(uniform_buffer)
	_rendering_device.free_rid(uniform_set)

	# Convert byte array to PackedFloat32Array
	var heightmap = PackedFloat32Array()
	heightmap.resize(HEIGHTMAP_SIZE)

	for i in range(HEIGHTMAP_SIZE):
		var offset = i * 4
		if offset + 4 <= result_bytes.size():
			var bytes = result_bytes.slice(offset, offset + 4)
			heightmap[i] = bytes.decode_float(0)
		else:
			push_error("TerrainGenerator: Buffer underrun at index ", i)
			return PackedFloat32Array()

	return heightmap


func is_gpu_available() -> bool:
	"""Check if GPU compute is available and initialized."""
	return _is_initialized and _gpu_supports_compute


# ============================================
# CLEANUP
# ============================================

func _exit_tree() -> void:
	"""Clean up GPU resources on exit."""

	if _rendering_device != null:
		if _compute_pipeline != RID():
			_rendering_device.free_rid(_compute_pipeline)
		if _shader != RID():
			_rendering_device.free_rid(_shader)
