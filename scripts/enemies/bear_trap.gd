extends Area2D

@onready var anim: AnimatedSprite2D = $AnimatedSprite2D
@onready var notifier: VisibleOnScreenNotifier2D = $OnScreen
var is_open: bool = true

var initial_position: Vector2
var initial_frame: int

func _ready() -> void:
	# Guardamos el estado inicial
	initial_position = global_position
	initial_frame = anim.frame
	
	# Conectar la señal de cuando sale de la pantalla
	notifier.screen_exited.connect(_on_screen_exited)


func _on_body_entered(body: Node2D) -> void:
	if not body.is_in_group("Player"):
		return

	# Cerrar trampa (tu animación de cerrar)
	
	if (is_open):
		anim.play("default")  
		if body.has_method("take_damage"):
			body.take_damage(1)
			is_open = false
			print("Recibe daño")

func _on_screen_exited() -> void:
	# Volver al estado inicial cuando ya no se ve
	global_position = initial_position
	anim.stop()
	anim.frame = initial_frame
	is_open = true
