extends Control
signal start_game

@onready var main_buttons: VBoxContainer = $Background/MainButtons
@onready var options: Panel               = $Options
@onready var soundPanel: Panel            = $Options/SoundPanel
@onready var labelOptions: Label          = $Options/Label
@onready var click_fx: AudioStreamPlayer =  $ClickFX
@onready var game_panel: Panel =  $GamePanel



enum Menu { MAIN, OPTIONS, SOUND, GAME }

func _ready() -> void:
	set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	

	# Asegurate de cortar clicks detrás cuando hay paneles encima
	options.mouse_filter     = Control.MOUSE_FILTER_STOP
	soundPanel.mouse_filter  = Control.MOUSE_FILTER_STOP
	game_panel.mouse_filter  = Control.MOUSE_FILTER_STOP

	show_menu(Menu.MAIN)  # estado inicial
	
func _play_click() -> void:
	if click_fx:
		click_fx.play()


func show_menu(which: Menu) -> void:
	# Main
	main_buttons.visible = (which == Menu.MAIN)

	# Opciones y sonido
	options.visible      = (which == Menu.OPTIONS or which == Menu.SOUND)
	labelOptions.visible = (which != Menu.SOUND or which == Menu.GAME)   # en SOUND escondemos el título "Opciones"
	soundPanel.visible   = (which == Menu.SOUND)
	game_panel.visible   = (which == Menu.GAME)

	# DEBUG útil para detectar rutas mal puestas / duplicados
	# print("Main:", main_buttons.visible, " Opt:", options.visible, " Sound:", soundPanel.visible)

func _on_start_pressed() -> void:
	_play_click()
	start_game.emit()

func _on_settings_pressed() -> void:
	_play_click()
	show_menu(Menu.OPTIONS)

func _on_exit_pressed() -> void:
	_play_click()
	get_tree().quit()

func _on_back_pressed() -> void:
	_play_click()
	show_menu(Menu.MAIN)

func _on_sounds_pressed() -> void:
	_play_click()
	show_menu(Menu.SOUND)

func _on_backto_options_pressed() -> void:
	_play_click()
	show_menu(Menu.OPTIONS)


func _on_game_pressed() -> void:
	_play_click()
	show_menu(Menu.GAME)


func _on_back_pressed_in_game_panel() -> void:
	_play_click()
	show_menu(Menu.OPTIONS)
