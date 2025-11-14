extends Control
class_name HUD

@onready var bones_label: Label = $BonesCollected

func _ready() -> void:
	set_bones(0)  # valor inicial

func set_bones(count: int) -> void:
	bones_label.text = "x %d" % count


func _on_osiris_bones_changed(count: int) -> void:
	set_bones(count)
