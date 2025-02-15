extends CharacterBody3D

const SPEED = 5.0
const JUMP_VELOCITY = 5.0
const GRAVITY = 9.8

func _physics_process(delta):
	var direction = Vector3.ZERO

	# Get input
	if Input.is_action_pressed("move_forward"):
		direction.z -= 1
	if Input.is_action_pressed("move_backward"):
		direction.z += 1
	if Input.is_action_pressed("move_left"):
		direction.x -= 1
	if Input.is_action_pressed("move_right"):
		direction.x += 1

	# Apply gravity
	if not is_on_floor():
		velocity.y -= GRAVITY * delta

	# Jumping
	if Input.is_action_just_pressed("jump") and is_on_floor():
		velocity.y = JUMP_VELOCITY

	# Move the player
	direction = direction.normalized() * SPEED
	velocity.x = direction.x
	velocity.z = direction.z
	move_and_slide()
