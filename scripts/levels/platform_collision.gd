# platform_collision.gd — Godot 4.4
extends Area2D

@export var only_from_above := true     # opcional: cuenta "arriba" sólo si viene desde arriba
@export var above_margin_px := 2.0      # margen para ese chequeo
@export var exit_grace := 0.08          # retardo para no soltar por micro-salidas

@onready var platform := get_parent() as AnimatableBody2D
var occupants := {}   # set de instance_id() de players
var grace_timer: Timer

func _ready():
	monitoring = true
	monitorable = true
	body_entered.connect(_on_enter)
	body_exited.connect(_on_exit)

	grace_timer = Timer.new()
	grace_timer.one_shot = true
	grace_timer.wait_time = exit_grace
	add_child(grace_timer)
	grace_timer.timeout.connect(_on_grace_timeout)

func _on_enter(body: Node):
	if not body.is_in_group("Player"):
		return

	if only_from_above:
		# considera "arriba" si el centro del player está por encima del centro de la plataforma
		if body.global_position.y > platform.global_position.y - above_margin_px:
			return

	occupants[body.get_instance_id()] = true
	grace_timer.stop()  # cancelamos un release pendiente

	if occupants.size() == 1:
		print("Osiris está arriba")
		if platform.has_method("press"):
			platform.press()

func _on_exit(body: Node):
	if not body.is_in_group("Player"):
		return

	occupants.erase(body.get_instance_id())
	if occupants.is_empty():
		grace_timer.start()  # esperamos un poquito por si vuelve a entrar enseguida

func _on_grace_timeout():
	if occupants.is_empty():
		print("Osiris está abajo")
		if platform.has_method("release"):
			platform.release()
