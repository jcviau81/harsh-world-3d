extends Camera3D

@export var follow_speed: float = 0.1
@export var camera_distance: float = 50.0
@export var camera_height: float = 40.0
@export var camera_fov: float = 70.0

var player: CharacterBody3D

func _ready():
	player = get_parent()  # Camera is child of Player, so parent IS the player
	fov = camera_fov

	# Set initial position
	var target_pos = player.global_position
	target_pos.y -= camera_distance
	target_pos.z += camera_height
	global_position = target_pos

func _process(delta):
	if player == null:
		return

	# Calculate target position for isometric view
	var target_pos = player.global_position
	target_pos.y -= camera_distance  # Back offset for isometric
	target_pos.z += camera_height    # Height offset

	# Smooth follow
	global_position = global_position.lerp(target_pos, follow_speed)

	# Keep camera looking at player
	look_at(player.global_position, Vector3.UP)
