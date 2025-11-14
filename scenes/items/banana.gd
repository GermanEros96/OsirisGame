# Banana.gd
extends RigidBody2D

@export var life_time := 4.0

func _ready() -> void:
	await get_tree().create_timer(life_time).timeout
	queue_free()
