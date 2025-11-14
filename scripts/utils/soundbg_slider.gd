extends HSlider
# Exportamos el nombre para referirnos al audio en el script 
@export var audio : String
var audio_busId

func _ready():
	
	audio_busId = AudioServer.get_bus_index(audio)

func _on_value_changed(new_value: float) -> void:
	
	print(value)
	var db = linear_to_db(new_value)
	AudioServer.set_bus_volume_db(audio_busId,db)
