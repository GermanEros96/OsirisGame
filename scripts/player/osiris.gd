extends CharacterBody2D

# --- Movimiento ---
const SPEED := 300.0
const ACCEL := 2000.0
const FRICTION := 2000.0

# --- Salto (si usás física de salto) ---
const JUMP_VELOCITY := -400.0
const GRAVITY := 900.0

# --- Umbral para activar "jump_run" cuando CORRE muy rápido ---
const RUN_TRIGGER := 250.0

@onready var anim: AnimatedSprite2D = $AnimatedSprite2D

# Muestra 1 solo frame de 'jump_run' cuando se toca Space.
var jump_flash_timer := 0.0        # segundos que forzamos el frame 0 de 'jump_run'
const JUMP_FLASH_TIME := 0.9      # ~80ms, ajustá a gusto

func _ready() -> void:
	anim.play("wait")
	anim.flip_h = false  # false = mira a la DERECHA (cambiá si tu sprite base mira al otro lado)

func _physics_process(delta: float) -> void:
	# --- Inputs ---
	var dir := Input.get_axis("ui_left", "ui_right") # -1 izq, 0, +1 der

	# --- Física (opcional, si tu personaje salta/cae) ---
	if not is_on_floor():
		velocity.y += GRAVITY * delta
	if is_on_floor() and Input.is_action_just_pressed("ui_accept"):
		# Salto + flash de 1 frame de 'jump_run'
		velocity.y = JUMP_VELOCITY
		jump_flash_timer = JUMP_FLASH_TIME

	# --- Acelerar/frenar horizontal ---
	var target_speed := dir * SPEED
	if dir != 0.0:
		velocity.x = move_toward(velocity.x, target_speed, ACCEL * delta)
	else:
		velocity.x = move_toward(velocity.x, 0.0, FRICTION * delta)

	move_and_slide()

	# --- FLIP según dirección pulsada (si no hay input, no cambiamos el flip) ---
	if dir > 0:  anim.flip_h = true     # derecha (ajustá si tu sprite base mira distinto)
	elif dir < 0: anim.flip_h = false   # izquierda

	# --- PRIORIDADES DE ANIMACIÓN ---
	# 1) Abajo = 'down' (bloquea movimiento si querés)
	if is_on_floor() and Input.is_action_pressed("ui_down"):
		anim.play("down")
		velocity.x = 0.0  # descomentá si querés bloquear el desplazamiento al agacharse
		return

	# 2) Flash de salto: SOLO 1 frame de 'jump_run'
	if jump_flash_timer > 0.0:
		jump_flash_timer -= delta
		anim.animation = "jump_run"
		anim.frame = 0
		return

	# 3) Movimiento basado en velocidad horizontal
	var speed_abs := absf(velocity.x)

	if speed_abs >= RUN_TRIGGER:
		# Corriendo MUY rápido -> 'jump_run' (tu pedido)
		if anim.animation != "jump_run":
			anim.play("jump_run")
	elif speed_abs > 0.0:
		# Se mueve pero por debajo del umbral -> 'walk'
		if anim.animation != "walk":
			anim.play("walk")
	else:
		# Quieto -> 'wait'
		if anim.animation != "wait":
			anim.play("wait")
