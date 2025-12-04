extends CharacterBody3D

@export var move_speed: float = 5.0
@export var run_multiplier: float = 1.5

var is_running: bool = false

func _ready():
	# Collision layer assignment (MUST MATCH Story 1.3 grid system)
	collision_layer = 1  # Player occupies layer 1
	collision_mask = 2   # Player collides with terrain_objects (layer 2)

	# Sprite3D child for visual representation
	var sprite = Sprite3D.new()
	sprite.offset.y = 1  # Adjust for isometric bottom-center pivot
	add_child(sprite)

	# CollisionShape3D child for physics
	var collision_shape = CollisionShape3D.new()
	collision_shape.shape = CapsuleShape3D.new()
	add_child(collision_shape)

func _process(delta):
	# Handle input
	var input_dir = Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down")
	is_running = Input.is_action_pressed("ui_select")  # Space key

	var current_speed = move_speed
	if is_running:
		current_speed *= run_multiplier

	# Set velocity
	if input_dir != Vector2.ZERO:
		velocity.x = input_dir.x * current_speed
		velocity.z = input_dir.y * current_speed
	else:
		velocity.x = 0
		velocity.z = 0

	# Apply gravity (keep player on ground)
	if not is_on_floor():
		velocity.y -= 9.8 * delta

	# Move and slide
	move_and_slide()

func _input(event):
	if event.is_action_pressed("ui_e"):
		# Placeholder for interaction system (Story 3.x)
		print("Interact pressed - E")
	elif event.is_action_pressed("ui_i"):
		# Placeholder for inventory (Story 7.x)
		print("Inventory pressed - I")
