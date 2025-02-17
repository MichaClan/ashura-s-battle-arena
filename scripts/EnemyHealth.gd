extends CharacterBody3D

var health = 50
var velocitee = Vector3.ZERO  # Add velocity for knockback

func take_damage(amount):
	health -= amount
	print("Enemy health: ", health)
	if health <= 0:
		queue_free()  # Remove the enemy when health reaches 0

func _physics_process(_delta):

	# Move the enemy
	move_and_slide()
