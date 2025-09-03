extends HSlider
# Exportamos el nombre para referirnos al audio en el script 
@export var audio : String

var audio_busId

func _ready():
	
	audio_busId = AudioServer.get_bus_index(audio)

func _on_value_changed(value: float) -> void:
	

	var db = linear_to_db(value)
	print(value)
	AudioServer.set_bus_volume_db(audio_busId,value)
