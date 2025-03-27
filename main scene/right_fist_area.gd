extends Area3D

signal hit_detected(target)

func _ready():
	connect("body_entered", _on_body_entered)

func _on_body_entered(body):
	if body.is_in_group("enemy"):
		emit_signal("hit_detected", body)  # Notify when an enemy is hit
