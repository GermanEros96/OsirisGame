extends CharacterBody2D

enum State { PATROL, ALERT, CHASE }

@export var moving : Array[Marker2D]          # Puntos A, B, etc.
@export var patrol_speed : float = 200.0       # Velocidad normal
@export var chase_speed  : float = 360.0      # Velocidad cuando persigue
@export var gravity      : float = 900.0
@export var alert_time   : float = 1.0        # Tiempo quieto (alerta)
@export var chase_continue_time : float = 5.0 # Seguir corriendo tras perder de vista
var patrol_min_x: float = -INF
var patrol_max_x: float =  INF


@onready var anim        : AnimatedSprite2D   = $CollisionShape2D/AnimatedSprite2D
@onready var vision      : Area2D            = $Vision
@onready var alert_timer : Timer             = $AlertTimer
@onready var alert_sound : AudioStreamPlayer = $AlertSound
@onready var chase_timer : Timer             = $ChaseTimer   # <- Asegurate de tener este nodo

var state : State = State.PATROL
var target_index : int = 0            # Índice del punto de patrulla actual
var player : Node = null              # Referencia al jugador
var chase_dir : float = 1.0           # Última dirección al correr rápido


func _ready() -> void:
	anim.play("run")

	# Opcional: arrancar en el primer punto de patrulla
	if moving.size() > 0:
		global_position.x = moving[0].global_position.x
	
	patrol_min_x = moving[0].global_position.x
	patrol_max_x = moving[0].global_position.x
	
	for m in moving:
		var x:= m.global_position.x
		if x < patrol_min_x:
			patrol_min_x = x
		if x > patrol_max_x:
			patrol_max_x = x


func _physics_process(delta: float) -> void:
	velocity.y += gravity * delta

	match state:
		State.PATROL:
			_update_patrol()
		State.ALERT:
			velocity.x = 0.0
		State.CHASE:
			_update_chase()

	_update_sprite_facing()
	_limit_to_patrol_range()
	move_and_slide()


# ---------- PATRULLA ENTRE PUNTOS A/B ----------

func _update_patrol() -> void:
	if moving.is_empty():
		velocity.x = 0.0
		return

	var target: Marker2D = moving[target_index]
	var dir := signf(target.global_position.x - global_position.x)

	# Si está muy cerca, pasa al siguiente punto
	if abs(target.global_position.x - global_position.x) < 4.0:
		target_index = (target_index + 1) % moving.size()
		target = moving[target_index]
		dir = sign(target.global_position.x - global_position.x)

	velocity.x = dir * patrol_speed


# ---------- PERSECUCIÓN ----------

func _update_chase() -> void:
	if player:
		var dir := signf(player.global_position.x - global_position.x)
		if dir == 0.0:
			dir = chase_dir
		chase_dir = dir
		velocity.x = dir * chase_speed
	else:
		# ya no ve al jugador → sigue en la última dirección conocida
		velocity.x = chase_dir * chase_speed


# ---------- ORIENTACIÓN DEL SPRITE + VISIÓN ----------

func _update_sprite_facing() -> void:
	if velocity.x == 0.0:
		return

	var look_left := velocity.x < 0.0
	anim.flip_h = look_left

	# Ajustá este valor según dónde pusiste Vision en el editor
	var vision_offset := 160.0

	if look_left:
		$Vision.position.x = -vision_offset
	else:
		$Vision.position.x = vision_offset-150


# ---------- VISIÓN: DETECTA AL JUGADOR ----------

func _on_vision_body_entered(body: Node) -> void:
	if not body.is_in_group("Player"):
		return

	player = body

	if state == State.PATROL:
		# Lo ve por primera vez → se queda quieto 1s (ALERT)
		state = State.ALERT
		velocity.x = 0.0

		anim.pause()
		anim.frame = 0

		if alert_sound:
			alert_sound.play()

		alert_timer.start(alert_time)


func _on_vision_body_exited(body: Node) -> void:
	if body != player:
		return

	player = null

	if state == State.CHASE:
		# Dejó de verlo mientras corre → seguir 5s más
		if velocity.x != 0.0:
			chase_dir = sign(velocity.x)
		chase_timer.start(chase_continue_time)


# ---------- TIMERS ----------

func _on_alert_timer_timeout() -> void:
	if state != State.ALERT:
		return

	if player:
		
		state = State.CHASE
		anim.play("run")
	else:
		
		_set_closest_patrol_point()
		state = State.PATROL
		anim.play("run")


func _on_chase_timer_timeout() -> void:
	# Pasaron los 5s extra corriendo sin ver al jugador
	if state == State.CHASE and player == null:
		state = State.ALERT
		velocity.x = 0.0
		anim.pause()
		anim.frame = 0
		alert_timer.start(alert_time)


# ---------- VOLVER AL PUNTO DE PATRULLA MÁS CERCANO ----------

func _set_closest_patrol_point() -> void:
	if moving.is_empty():
		return

	var closest_index := 0
	var closest_dist := INF

	for i in moving.size():
		var d := absf(moving[i].global_position.x - global_position.x)
		if d < closest_dist:
			closest_dist = d
			closest_index = i

	target_index = closest_index
	
func _limit_to_patrol_range() -> void:
	if patrol_min_x == -INF or patrol_max_x == INF:
		return

	# Borde izquierdo
	if global_position.x <= patrol_min_x:
		global_position.x = patrol_min_x
		anim.stop()

		# Si está patrullando → sí bloquear movimiento
		if state == State.PATROL:
			velocity.x = max(velocity.x, 0.0)
			anim.play("run")
		# Si está persiguiendo → NO bloquear, mantener animación
		# pero impedir que lo empuje más a la izquierda

	# Borde derecho
	if global_position.x >= patrol_max_x:
		global_position.x = patrol_max_x
		anim.stop()

		if state == State.PATROL:
			velocity.x = min(velocity.x, 0.0)
			anim.play("run")
		# En CHASE, misma idea: solo clippear posición
