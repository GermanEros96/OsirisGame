# Monkey.gd
extends Area2D

enum State { ON_LIANA, GOING_DOWN, ATTACKING, GOING_UP }
var state: State = State.ON_LIANA

@export var banana_scene: PackedScene
@export var liana_distance: float = 450.0      # cuánto baja desde la posición inicial
@export var throw_interval: float = 1.0       # tiempo entre tiros
@export var throw_speed: float = 120.0        # velocidad de la banana

@onready var anim: AnimatedSprite2D = $AnimatedSprite2D
@onready var vision: Area2D = $DetectedArea2D     
@onready var spawn: Marker2D = $Muzzle           
@onready var timer: Timer = $ThrowCD              

var player: Node2D = null
var top_pos: Vector2
var bottom_pos: Vector2

func _ready() -> void:
	top_pos = global_position
	bottom_pos = top_pos + Vector2(0.0, liana_distance)

	vision.body_entered.connect(_on_vision_entered)
	vision.body_exited.connect(_on_vision_exited)
	timer.timeout.connect(_on_throw_timer_timeout)

	anim.play("move")  # puede quedar en el primer frame colgado
	anim.pause()       # lo pausamos para que no se anime solo

func _on_vision_entered(body: Node) -> void:
	if not body.is_in_group("Player"):
		return

	player = body

	if state == State.ON_LIANA:
		_go_down()

func _on_vision_exited(body: Node) -> void:
	if body != player:
		return

	player = null

	if state == State.ATTACKING:
		_go_up()

func _go_down() -> void:
	state = State.GOING_DOWN
	anim.play("move")
	var tw := create_tween().set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	tw.tween_property(self, "global_position", bottom_pos, 2.0)
	tw.finished.connect(func ():
		if state == State.GOING_DOWN:
			_start_attacking()
	)

func _go_up() -> void:
	state = State.GOING_UP
	timer.stop()
	anim.play("move")
	var tw := create_tween().set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	tw.tween_property(self, "global_position", top_pos, 2.0)
	tw.finished.connect(func ():
		if state == State.GOING_UP:
			state = State.ON_LIANA
			anim.play("move")
			anim.pause()   # se queda quieto arriba
	)

func _start_attacking() -> void:
	state = State.ATTACKING
	timer.wait_time = throw_interval
	timer.start()

func _on_throw_timer_timeout() -> void:
	if state != State.ATTACKING:
		return
	if player == null or not is_instance_valid(player):
		_go_up()
		return

	# mirar hacia el jugador (flip horizontal opcional)
	anim.flip_h = player.global_position.x < global_position.x

	# animación de lanzar
	anim.play("throw")
	_throw_banana()

func _throw_banana() -> void:
	if banana_scene == null:
		return

	var banana := banana_scene.instantiate() as RigidBody2D
	get_tree().current_scene.add_child(banana)

	banana.global_position = spawn.global_position

	# dirección hacia el jugador
	var dir := (player.global_position - banana.global_position).normalized()
	banana.linear_velocity = dir * throw_speed
	
