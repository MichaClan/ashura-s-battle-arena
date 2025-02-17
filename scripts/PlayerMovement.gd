extends CharacterBody3D

const SPEED = 5.0
const JUMP_VELOCITY = 5.0
const GRAVITY = 9.8
const ATTACK_COOLDOWN = 0.5
const PUNCH_FORCE = 10.0

@export var mouse_sensitivity: float = 0.002  

var rotation_x = 0.0
var is_attacking = false
var last_attack_time = 0.0 

@onready var camera_pivot = $CameraPivot
@onready var healthbar = $HealthBar 

# Starting health
var max_health = 100
var current_health = 100

func _ready():
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)

func take_damage(amount: int):
	current_health -= amount
	current_health = max(current_health, 0)  # Prevent health from going below 0
	healthbar.set_health(current_health)  # Update health bar
	if current_health <= 0:
		die()  # Handle player deathandle player death

func die():
	print("Player has died.")
	# Implement death behavior (e.g., respawn, game over screen, etc.)

func _input(event):
	if event is InputEventMouseMotion:
		rotate_y(-event.relative.x * mouse_sensitivity)  # Rotate player left/right
		rotation_x -= event.relative.y * mouse_sensitivity
		rotation_x = clamp(rotation_x, -1.2, 1.2)  # Prevent looking too high/low
		camera_pivot.rotation.x = rotation_x  # Apply vertical rotation

	# Check for attack input
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
		attack()

func _physics_process(delta):
	apply_gravity(delta)
	handle_movement(delta)
	move_and_slide()

	# Update attack cooldown timer
	if is_attacking:
		last_attack_time += delta
		if last_attack_time >= ATTACK_COOLDOWN:
			is_attacking = false

func apply_gravity(delta):
	if is_on_floor():
		if Input.is_action_just_pressed("jump"):
			velocity.y = JUMP_VELOCITY
	else:
		velocity.y -= GRAVITY * delta  # Apply gravity when in air

func handle_movement(_delta):
	var move_direction = Vector3.ZERO
	var cam_forward = -camera_pivot.global_transform.basis.z
	var cam_right = camera_pivot.global_transform.basis.x

	# Get movement input
	if Input.is_action_pressed("move_forward"):
		move_direction += cam_forward
	if Input.is_action_pressed("move_backward"):
		move_direction -= cam_forward
	if Input.is_action_pressed("move_left"):
		move_direction -= cam_right
	if Input.is_action_pressed("move_right"):
		move_direction += cam_right

	# Normalize movement
	if move_direction.length() > 0:
		move_direction = move_direction.normalized() * SPEED
		velocity.x = move_direction.x
		velocity.z = move_direction.z
	else:
		# Instantly stop when no input is given
		velocity.x = 0
		velocity.z = 0

func attack():
	if is_attacking:
		return  # Skip if already attacking

	# Start attack
	is_attacking = true
	last_attack_time = 0.0

	# Play attack animation (if you have one)
	# $AnimationPlayer.play("punch")

	# Move the player forward slightly during the punch
	var punch_direction = -transform.basis.z  # Forward direction of the player
	velocity += punch_direction * PUNCH_FORCE * 0.5  # Adjust force for player movement

	# Detect enemies in range
	detect_hit()

func detect_hit():
	# Define attack range and area
	var _attack_range = 2.0  # How far the punch reaches
	var _attack_angle = 45.0  # Angle in front of the player to detect hits

	# Get all overlapping bodies in the attack area
	var space_state = get_world_3d().direct_space_state
	var query = PhysicsShapeQueryParameters3D.new()
	query.set_shape($CollisionShape3D.shape)  # Use the player's collision shape
	query.transform = global_transform  # Use the player's global transform

	# Perform the query
	var results = space_state.intersect_shape(query)

	# Check each result
	for result in results:
		var body = result.collider
		if body.is_in_group("enemy"):  # Check if the body is an enemy
			print("Hit enemy: ", body.name)
			# Apply damage to the enemy
			body.take_damage(10)

			# Apply knockback to the enemy
			var punch_direction = -transform.basis.z  # Forward direction of the player
			body.velocity += punch_direction * PUNCH_FORCE  # Adjust force for enemy movement
