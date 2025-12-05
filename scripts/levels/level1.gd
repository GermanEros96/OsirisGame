extends Node

@onready var music: AudioStreamPlayer = $AudioStreamPlayer
@onready var hud: HUD = $CanvasLayer/HUD              # ajusta la ruta si hace falta
@onready var level_timer: Timer = $LevelTimer         # el Timer que creaste

var remaining_time: int = 600   # 10 minutos en segundos

func _ready() -> void:
	# Música del nivel
	if music:
		music.play()
	
	if hud:
		hud.set_time(remaining_time)
	
	# Conectar el timer
	level_timer.timeout.connect(_on_level_timer_timeout)

func _on_level_timer_timeout() -> void:
	remaining_time -= 1
	if remaining_time < 0:
		remaining_time = 0
	
	if hud:
		hud.set_time(remaining_time)
	
	if remaining_time == 0:
		level_timer.stop()
		# TODO: acá más adelante hacemos GAME OVER o respawn
		print("Tiempo agotado")
