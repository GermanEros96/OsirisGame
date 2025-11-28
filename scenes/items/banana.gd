extends RigidBody2D

const LIFETIME := 3.0  # segundos

func _ready() -> void:
	# Para que el RigidBody2D dispare body_entered
	contact_monitor = true
	max_contacts_reported = 4


	# Empezar contador de vida
	_start_lifetime()


func _start_lifetime() -> void:
	await get_tree().create_timer(LIFETIME).timeout
	if is_inside_tree():
		queue_free()


func _on_body_entered(body: Node) -> void:
	# Solo nos importa el Player
	if not body.is_in_group("Player"):
		return

	if body.has_method("take_damage"):
		body.take_damage(1)  # parpadeo + sonido lo maneja Osiris

	if is_inside_tree():
		queue_free()
