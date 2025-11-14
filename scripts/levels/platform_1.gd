# platform_motion.gd — Godot 4.4
extends AnimatableBody2D

@export var down_px: float = 12.0      # cuánto se hunde
@export var press_time: float = 0.08   # tiempo de bajada
@export var release_time: float = 0.12 # tiempo de subida
@export var overshoot: float = 0.0     # 0 => SIN rebote (no impulsa al player)

@onready var spr: Sprite2D = $Sprite2D

var base_y: float
var tw: Tween

func _ready():
	base_y = position.y

func press():
	if tw: tw.kill()
	tw = create_tween()
	tw.set_process_mode(Tween.TWEEN_PROCESS_PHYSICS)
	tw.set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	tw.tween_property(self, "position:y", base_y + down_px, press_time)
	tw.parallel().tween_property(spr, "position", Vector2(1.03, 0.97), press_time)

func release():
	if tw: tw.kill()
	tw = create_tween()
	tw.set_process_mode(Tween.TWEEN_PROCESS_PHYSICS)
	tw.set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	tw.tween_property(self, "position:y", base_y, release_time)
	tw.parallel().tween_property(spr, "position", Vector2.ONE, release_time)
