extends Control

@export var next_scene_path: String = "res://scenes/levels/level1/level_1.tscn"

@onready var bar: TextureProgressBar = $TextureProgressBar

func _ready() -> void:
	# Empezar carga en segundo plano
	ResourceLoader.load_threaded_request(next_scene_path)

func _process(delta: float) -> void:
	var progress := [0.0]
	var status = ResourceLoader.load_threaded_get_status(next_scene_path, progress)

	bar.value = progress[0] * bar.max_value

# Si llega a 100 % cambiamos la escena

	if status == ResourceLoader.THREAD_LOAD_LOADED:
		var packed_scene := ResourceLoader.load_threaded_get(next_scene_path)
		get_tree().change_scene_to_packed(packed_scene)
