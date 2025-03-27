extends CharacterBody3D

# Constants
const WALK_SPEED = 5.0
const SPRINT_SPEED = 9.0
const JUMP_VELOCITY = 5.0
const GRAVITY = 9.8
const DASH_SPEED = 15.0
const DASH_TIME = 0.3
const DOUBLE_JUMP_VELOCITY = 4.5

# Exports
@export var mouse_sensitivity: float = 0.002  

# Variables
var rotation_x = 0.0
var is_sprinting = false
var can_double_jump = false
var is_dashing = false
var dash_direction = Vector3.ZERO
var dash_timer = 1

@onready var camera_pivot = $CameraPivot

# Ready function
func _ready():
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)

# Input handling
func _input(event):
	# Mouse look (camera movement)
	if event is InputEventMouseMotion:
		rotate_y(-event.relative.x * mouse_sensitivity)  # Rotate left/right
		rotation_x -= event.relative.y * mouse_sensitivity
		rotation_x = clamp(rotation_x, -1.2, 1.2)  # Clamp vertical movement
		camera_pivot.rotation.x = rotation_x  # Apply to camera

	# Sprint toggle (Shift key)
	if Input.is_action_just_pressed("sprint"):
		is_sprinting = !is_sprinting  # Toggle sprint mode

	# Dash (Q key)
	if Input.is_action_just_pressed("dash") and not is_dashing:
		start_dash()

	# Double jump
	if Input.is_action_just_pressed("jump"):
		if is_on_floor():  # Regular jump
			velocity.y = JUMP_VELOCITY
		elif can_double_jump:  # Double jump
			velocity.y = DOUBLE_JUMP_VELOCITY
			can_double_jump = false

# Physics process
func _physics_process(delta):
	apply_gravity(delta)

	if is_dashing:
		handle_dash(delta)
	else:
		handle_movement(delta)

	move_and_slide()

# Gravity application
func apply_gravity(delta):
	if not is_on_floor():
		velocity.y -= GRAVITY * delta  # Apply gravity
	else:
		can_double_jump = true  # Reset double jump when on the floor

# Movement handler
func handle_movement(_delta):
	var move_direction = Vector3.ZERO
	var cam_forward = -camera_pivot.global_transform.basis.z
	var cam_right = camera_pivot.global_transform.basis.x

	# Movement input
	if Input.is_action_pressed("move_forward"):
		move_direction += cam_forward
	if Input.is_action_pressed("move_backward"):
		move_direction -= cam_forward
	if Input.is_action_pressed("move_left"):
		move_direction -= cam_right
	if Input.is_action_pressed("move_right"):
		move_direction += cam_right

	# Normalize movement vector
	if move_direction.length() > 0:
		move_direction = move_direction.normalized()
		var speed = SPRINT_SPEED if is_sprinting else WALK_SPEED
		velocity.x = move_direction.x * speed
		velocity.z = move_direction.z * speed
	else:
		# Stop movement if no input
		velocity.x = 0
		velocity.z = 0

# Dash logic
func start_dash():
	is_dashing = true
	dash_timer = DASH_TIME

	# Get dash direction
	var move_direction = Vector3.ZERO
	if Input.is_action_pressed("move_forward"):
		move_direction += -global_transform.basis.z
	if Input.is_action_pressed("move_backward"):
		move_direction -= -global_transform.basis.z
	if Input.is_action_pressed("move_left"):
		move_direction -= global_transform.basis.x
	if Input.is_action_pressed("move_right"):
		move_direction += global_transform.basis.x

	if move_direction.length() == 0:
		move_direction = -global_transform.basis.z  # Default forward dash

	dash_direction = move_direction.normalized()

# Dash movement
func handle_dash(delta):
	if dash_timer > 0:
		velocity = dash_direction * DASH_SPEED
		dash_timer -= delta
	else:
		is_dashing = false
