extends CharacterBody2D 

# --- Movimiento ---
const SPEED := 400.0
const ACCEL := 2000.0
const FRICTION := 2000.0

# --- Salto (si usás física de salto) ---
const JUMP_VELOCITY := -500.0
const GRAVITY := 900.0

# --- Umbral para activar "jump_run" cuando CORRE muy rápido ---
const RUN_TRIGGER := 250.0
signal bones_changed(count: int)
var bones: int = 0

@onready var anim: AnimatedSprite2D = $AnimatedSprite2D

# Muestra 1 solo frame de 'jump_run' cuando se toca Space.
var jump_flash_timer := 0.0        # segundos que forzamos el frame 0 de 'jump_run'
const JUMP_FLASH_TIME := 0.9       # ~80ms, ajustá a gusto

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

	# Mover Sprite mirando a la derecha
	if dir > 0:  anim.flip_h = false     # derecha (ajustá si tu sprite base mira distinto)
	elif dir < 0: anim.flip_h = true   # izquierda

	# --- PRIORIDADES DE ANIMACIÓN ---

	# 0) Arriba = 'alert' (se para en 2 patas)
	#    Lo ponemos primero para que tenga prioridad sobre el resto.
	if is_on_floor() and Input.is_action_pressed("ui_up"):
		if anim.animation != "up":
			anim.play("up")
		velocity.x = 0.0  # opcional: bloquear desplazamiento mientras está en alerta
		return

	# 1) Abajo = 'down' 
	if is_on_floor() and Input.is_action_pressed("ui_down"):
		if anim.animation != "down":
			anim.play("down")
		velocity.x = 0.0  # descomentá si querés bloquear el desplazamiento al agacharse
		return

	# 2) Flash de salto
	if jump_flash_timer > 0.0:
		jump_flash_timer -= delta
		anim.animation = "Jump"
		return

	# 3) Movimiento basado en velocidad horizontal
	var speed_abs := absf(velocity.x)

	if speed_abs >= RUN_TRIGGER:
		# Corriendo MUY rápido -> 'jump_run' 
		if anim.animation != "Run":
			anim.play("Run")
	elif speed_abs > 0.0:
		# Se mueve pero por debajo del umbral -> 'walk'
		if anim.animation != "Run":
			anim.play("Run")
	else:
		# Quieto -> 'wait'
		if anim.animation != "wait":
			anim.play("wait")
		return

# --- INVENTARIO: Huesos ---
# Llamá a esta función desde el pickup (Bone.gd) cuando Osiris lo toque.
func add_bone(amount: int = 1) -> void:
	bones += amount
	# Mensajes de consola para ver que funciona:
	print("Osiris tiene huesos: %d" % bones)
	emit_signal("bones_changed", bones)
	
