extends Control

# Guardamos los nodos Hijos en una variable

@onready var main_buttons: VBoxContainer = $Background/MainButtons
@onready var options: Panel = $Options
@onready var soundPanel: Panel = $Options/SoundPanel
@onready var labelOptions: Label = $Options/Label

func _ready() -> void:
	
# Cuando se inicializa la interfaz, el menu "Options" esta oculto
	options.hide()
	soundPanel.hide()
	
	
func _process(delta: float) -> void:
	pass
	


func _on_start_pressed() -> void:
	print("Iniciando Juego..")


func _on_settings_pressed() -> void:

#Si "Options" es precionado, ocultamos los botones principales y mostramos las opciones.
	main_buttons.hide()
	options.show()



func _on_exit_pressed() -> void:
	
# Salimos del juego.
	get_tree().quit()


func _on_back_pressed() -> void:
	main_buttons.show()
	options.hide()


func _on_sounds_pressed() -> void:
	print("Abriendo el menu de sonido")
	
	labelOptions.hide()
	main_buttons.hide()
	soundPanel.show()


func _on_backto_options_pressed() -> void:
	labelOptions.show()
	soundPanel.hide()
	
