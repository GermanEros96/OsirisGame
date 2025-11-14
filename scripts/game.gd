
extends Node

# Arrastrá aquí tu res://scenes/levels/level1.tscn (o la ruta que uses)
@export var level_scene: PackedScene 

# Ajustá la ruta a tu Title en el Game; en tu escena es CanvasLayer/Title_Screen
@onready var title: Control = $CanvasLayer/Title_Screen

func _ready() -> void:
	# Mostrar el título al arrancar y escuchar su señal
	title.visible = true
	if title.has_signal("start_game"):
		title.start_game.connect(_on_title_start_game)

func _on_title_start_game() -> void:
	if level_scene:
		# Reemplaza la escena actual por Level 1
		get_tree().change_scene_to_packed(level_scene)
	else:
		push_warning("No asignals 'level_scene' in Game.gd")
