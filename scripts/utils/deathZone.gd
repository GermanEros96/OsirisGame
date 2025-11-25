extends Area2D

func _ready() -> void:
	pass

func _on_body_entered(body: Node2D) -> void:
	# Solo queremos que afecte al jugador
	if not body.is_in_group("Player"):
		return

	if body.has_method("respawn"):
		body.respawn()
