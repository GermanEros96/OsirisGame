extends Area2D

var activated: bool = false
@onready var sprite: AnimatedSprite2D = $AnimatedSprite2D

# --- Audios ---
@onready var sfx_check: AudioStreamPlayer = $SFX_Check
@onready var sfx_bark1: AudioStreamPlayer = $SFX_Bark1
@onready var sfx_bark2: AudioStreamPlayer= $SFX_Bark2

func _ready() -> void:
	body_entered.connect(_on_body_entered)

func _on_body_entered(body: Node) -> void:
	if activated:
		return

	# Solo el jugador puede activarlo
	if not body.is_in_group("Player"):
		return

	activated = true
	sprite.frame = 1  # casita "activada"

	# Guardar posición de respawn en Osiris
	if body.has_method("set_respawn_position"):
		_play_sounds() 
		body.set_respawn_position(global_position)
		
func _play_sounds() -> void:
	sfx_check.play()
	
	var random_valor:= randi() %2
	
	if random_valor == 0:
		sfx_bark1.play()
	else:
		sfx_bark2.play()
