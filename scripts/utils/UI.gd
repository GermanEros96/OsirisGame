extends Control
class_name HUD

@onready var bones_label: Label = $BonesCollected
@onready var life: Label = $Life
@onready var heart: AnimatedSprite2D =$HBoxContainer/AnimatedSprite2D
@onready var timer: AnimatedSprite2D =$HBoxContainer/AnimatedSprite2D2
@onready var time_label: Label = $Time  

func _ready() -> void:
	set_bones(0)  # valor inicial
	set_life(3) # valor inicial de 3 vidas
	set_time(600) # valor en segundos
	heart.play("default")
	timer.play("default")

func set_bones(count: int) -> void:
	bones_label.text = "x %d" % count
	
func set_life(count: int) -> void:
	life.text ="x %d" % count

func set_time(total_seconds: int) -> void:
	if total_seconds < 0:
		total_seconds = 0
	var minutes: int = total_seconds / 60
	var seconds: int = total_seconds % 60
	time_label.text = "%02d:%02d" % [minutes, seconds]


func update_hearts(value: int) -> void:
	life.text = "x " + str(value)

func _on_osiris_bones_changed(count: int) -> void:
	set_bones(count)
