extends Node

# Arrastrá aquí tu res://scenes/levels/level1.tscn (o la ruta que uses)
@export var level_scene: PackedScene 

# Ajustá la ruta a tu Title en el Game; en tu escena es CanvasLayer/Title_Screen
@onready var title: Control = $CanvasLayer/Title_Screen
@onready var fade_rect: ColorRect = $CanvasLayer/FadeRect

func _ready() -> void:
	# Mostrar el título al arrancar y escuchar su señal
	title.visible = true
	_fade_in_from_black()
	if title.has_signal("start_game"):
		title.start_game.connect(_on_title_start_game)

func _on_title_start_game() -> void:
	if level_scene:
		# Reemplaza la escena actual por Level 1
		get_tree().change_scene_to_packed(level_scene)
	else:
		push_warning("No asignals 'level_scene' in Game.gd")
	
func _fade_in_from_black() -> void:
	# Aseguramos que empieza totalmente negro
	fade_rect.visible = true
	var color := fade_rect.modulate
	color.a = 1.0
	fade_rect.modulate = color

	# Tween para bajar el alfa hasta 0 en 1 segundo
	var tw := create_tween().set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	tw.tween_property(fade_rect, "modulate:a", 0.0, 2.0)
	tw.finished.connect(func ():
		fade_rect.visible = false
	)
