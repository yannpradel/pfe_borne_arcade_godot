extends CharacterBody3D

@export var speed = 14
@export var fall_acceleration = 75
@export var jump_force = 15
@export var max_camera_speed = 22.5

var target_velocity = Vector3.ZERO
var move_direction = Vector3.ZERO  # Direction actuelle du déplacement
@onready var camera := $"../CameraPivot/Camera3D"

var has_double_jumped = false

func _physics_process(delta):
	# Réinitialise la direction à chaque frame
	move_direction = Vector3.ZERO

	# Détection des mouvements horizontaux via le clavier
	if Input.is_action_pressed("move_right"):
		move_right()
	if Input.is_action_pressed("move_left"):
		move_left()
	if Input.is_action_pressed("move_back"):
		move_back()
	if Input.is_action_pressed("move_forward"):
		move_forward()

	# Si une direction est spécifiée, normalise et oriente le Pivot
	if move_direction != Vector3.ZERO:
		move_direction = move_direction.normalized()
		$Pivot.basis = Basis.looking_at(move_direction)

	# Mise à jour des vitesses en fonction de la direction
	target_velocity.x = move_direction.x * speed
	target_velocity.z = move_direction.z * speed

	# Gestion du saut et du double saut via le clavier
	if Input.is_action_just_pressed("jump"):
		jump()

	# Gravité si le personnage est en l'air
	if not is_on_floor():
		target_velocity.y -= fall_acceleration * delta

	# Déplacement final
	velocity = target_velocity
	move_and_slide()

	# Ajuste la vitesse de la caméra
	adjust_camera_speed(delta)

# Déplacement vers la gauche
func move_left():
	print("Déplacement à gauche")
	move_direction.x = -1
	$Pivot.basis = Basis.looking_at(move_direction)

# Déplacement vers la droite
func move_right():
	print("Déplacement à droite")
	move_direction.x = 1
	$Pivot.basis = Basis.looking_at(move_direction)

# Déplacement vers l'arrière
func move_back():
	print("Déplacement vers l'arrière")
	move_direction.z = 1
	$Pivot.basis = Basis.looking_at(move_direction)

# Déplacement vers l'avant
func move_forward():
	print("Déplacement vers l'avant")
	move_direction.z = -1
	$Pivot.basis = Basis.looking_at(move_direction)

# Saut
func jump():
	if is_on_floor():
		print("Saut")
		target_velocity.y = jump_force
		has_double_jumped = false
	elif not has_double_jumped:
		print("Double saut")
		target_velocity.y = jump_force
		has_double_jumped = true

# Ajustement de la vitesse de la caméra pour suivre le personnage
func adjust_camera_speed(delta):
	var target_camera_z = global_transform.origin.z + 40
	var camera_position = camera.global_transform.origin.z
	var camera_speed = (target_camera_z - camera_position) * delta * max_camera_speed
	camera_speed = clamp(camera_speed, -max_camera_speed, max_camera_speed)
	camera.global_transform.origin.z += camera_speed * delta
