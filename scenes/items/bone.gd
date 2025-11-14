class_name Bone
extends Area2D

@export var amount: int = 1          # cuántos huesos suma este pickup
@export var float_amp: float = 4.0   # amplitud del "flotado" (en píxeles)
@export var float_time: float = 0.7  # tiempo ida/vuelta del flotado

@onready var sprite: Sprite2D = $"../Sprite2D"

func _ready() -> void:
	body_entered.connect(_on_body_entered)
	_start_float()

# Animación de "flotado" (idle)
func _start_float() -> void:
	if sprite == null:
		return

	# Movimiento vertical suave arriba/abajo en bucle
	var base_y := sprite.position.y
	var bob := create_tween().set_loops().set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	bob.tween_property(sprite, "position:y", base_y - float_amp, float_time)
	bob.tween_property(sprite, "position:y", base_y + float_amp, float_time)

	# (Opcional) pequeño vaivén de rotación para dar vida
	var rot := create_tween().set_loops().set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	rot.tween_property(sprite, "rotation_degrees", -3.0, float_time * 0.9)
	rot.tween_property(sprite, "rotation_degrees",  3.0, float_time * 0.9)

func _on_body_entered(body: Node) -> void:
	# Acepta jugador por grupo "player" o si implementa add_bone()
	if not (body.is_in_group("player") or body.has_method("add_bone")):
		return

	# Sumar al inventario del jugador (si tiene método)
	if body.has_method("add_bone"):
		body.add_bone(amount)
		
		
	# Evitar múltiples disparos y colisiones mientras desaparece
	set_deferred("monitoring",false) 
	if $CollisionShape2D:
		
		$CollisionShape2D.set_deferred("disable",true)

	# Pequeña animación de "pop" antes de desaparecer
	if sprite:
		var pop := create_tween()
		pop.set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
		pop.tween_property(sprite, "scale", sprite.scale * 1.2, 0.08)
		pop.set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_IN)
		pop.tween_property(sprite, "scale", Vector2.ZERO, 0.12)

		pop.tween_callback(queue_free)
	else:

		queue_free()
