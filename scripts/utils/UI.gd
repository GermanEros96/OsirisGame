extends Control
class_name HUD

@onready var bones_label: Label = $BonesCollected
@onready var life: Label = $Life
@onready var heart: AnimatedSprite2D =$HBoxContainer/AnimatedSprite2D

func _ready() -> void:
	set_bones(0)  # valor inicial
	set_life(3) # valor inicial de 3 vidas
	heart.play("default")

func set_bones(count: int) -> void:
	bones_label.text = "x %d" % count
	
func set_life(count: int) -> void:
	life.text ="x %d" % count

func update_hearts(value: int) -> void:
	life.text = "x " + str(value)

func _on_osiris_bones_changed(count: int) -> void:
	set_bones(count)
