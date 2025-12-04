## GPU Capability Detection
## Checks for compute shader support and logs GPU info on startup

class_name GPUDeviceCheck
extends Node

# ============================================
# STATIC METHODS
# ============================================

static func check_compute_support() -> bool:
	"""
	Check if the GPU supports compute shaders.
	Returns true if compute shaders are available, false otherwise.
	"""

	var rd = RenderingServer.create_local_rendering_device()
	if rd == null:
		push_error("GPUDeviceCheck: Failed to create RenderingDevice")
		return false

	# If we can create a device, it supports basic compute
	# More detailed capability checks would require querying device limits
	rd.free()
	return true


static func get_gpu_info() -> Dictionary:
	"""
	Retrieve GPU information and capabilities.
	Returns a dictionary with GPU model, driver version, etc.
	"""

	var gpu_info = {}

	# Use Godot's RenderingServer to get GPU info
	var device_name = RenderingServer.get_rendering_device().get_device_name()
	var driver_version = RenderingServer.get_rendering_device().get_device_driver_version()
	var vram_mb = RenderingServer.get_rendering_device().get_device_vram_mb()

	gpu_info["device_name"] = device_name if device_name else "Unknown"
	gpu_info["driver_version"] = driver_version if driver_version else "Unknown"
	gpu_info["vram_mb"] = vram_mb

	return gpu_info


static func log_gpu_info() -> void:
	"""Log detailed GPU information at startup."""

	print("\n=== GPU CAPABILITY CHECK ===")

	var compute_supported = check_compute_support()
	print("Compute Shader Support: ", "✓ YES" if compute_supported else "✗ NO")

	var gpu_info = get_gpu_info()
	print("GPU Device: ", gpu_info["device_name"])
	print("Driver Version: ", gpu_info["driver_version"])
	print("VRAM: ", gpu_info["vram_mb"], " MB")

	if not compute_supported:
		push_warning("GPUDeviceCheck: Compute shaders not supported on this GPU!")
		print("WARNING: Terrain generation will not work without compute shader support.")

	print("============================\n")


# ============================================
# LIFECYCLE (if used as Node)
# ============================================

func _ready() -> void:
	"""Automatically log GPU info when this node enters the scene."""
	GPUDeviceCheck.log_gpu_info()
