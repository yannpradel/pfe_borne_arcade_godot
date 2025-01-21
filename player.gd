extends CharacterBody3D

@export var speed = 13
@export var fall_acceleration = 75
@export var jump_force = 30
@export var max_camera_speed = 22.5

var target_velocity = Vector3.ZERO
var move_direction = Vector3.ZERO
@onready var camera := $"../CameraPivot/Camera3D"
@onready var camera2 := $"../SubViewport/Camera3DBarnaby"
var has_double_jumped = false

# Flags pour les commandes UDP
var move_left_flag = false
var move_right_flag = false
var move_forward_flag = false
var move_back_flag = false  # Déplacement manuel sur Z

# Nouvelle variable de contrôle
var auto_move_z = true  # Définit si le Z est auto ou manuel

func _physics_process(delta):
	# Réinitialise la direction
	move_direction = Vector3.ZERO

	# Ajout des directions via les flags UDP
	if move_left_flag:
		move_direction.x -= 1
	if move_right_flag:
		move_direction.x += 1
	if move_forward_flag:
		move_direction.z -= 1
	if move_back_flag:
		move_direction.z += 1

	# Ajout des directions via le clavier
	if Input.is_action_pressed("move_right"):
		move_direction.x += 1
	if Input.is_action_pressed("move_left"):
		move_direction.x -= 1
	if Input.is_action_pressed("move_back"):
		move_direction.z += 1
	if Input.is_action_pressed("move_forward"):
		move_direction.z -= 1
	if Input.is_action_just_pressed("jump"):
		jump()

	# Ajout du mouvement automatique sur Z si activé
	if auto_move_z:
		move_direction.z += 1

	# Normalisation de la direction et mise à jour de l'orientation
	if move_direction != Vector3.ZERO:
		move_direction = move_direction.normalized()
		$Pivot.basis = Basis.looking_at(move_direction)

	# Mise à jour des vitesses en fonction de la direction
	target_velocity.x = move_direction.x * speed
	target_velocity.z = move_direction.z * speed

	# Gravité si le personnage est en l'air
	if not is_on_floor():
		target_velocity.y -= fall_acceleration * delta

	# Déplacement final
	velocity = target_velocity
	move_and_slide()

	# Ajuste la vitesse des caméras
	adjust_camera_speed(delta)
	adjust_camera2_speed(delta)

# Désactive le déplacement automatique sur Z et ajuste la logique de la caméra
func stop_auto_move_z():
	auto_move_z = false
	print("Le déplacement automatique sur Z a été désactivé.")


# Active le déplacement automatique sur Z
func start_auto_move_z():
	auto_move_z = true
	print("Le déplacement automatique sur Z a été activé.")

# Saut
func jump():
	if is_on_floor():
		target_velocity.y = jump_force
		has_double_jumped = false
	elif not has_double_jumped:
		target_velocity.y = jump_force
		has_double_jumped = true

# Ajustement de la vitesse de la caméra pour suivre le personnage
func adjust_camera_speed(delta):
	var target_camera_z = global_transform.origin.z + 10
	if auto_move_z:
		target_camera_z += 40  # Ajoute un offset seulement si auto_move_z est activé

	var camera_position = camera.global_transform.origin.z
	var camera_speed = (target_camera_z - camera_position) * delta * max_camera_speed
	camera_speed = clamp(camera_speed, -max_camera_speed, max_camera_speed)
	camera.global_transform.origin.z += camera_speed * delta

# Ajustement de la vitesse de la deuxième caméra pour suivre le personnage
func adjust_camera2_speed(delta):
	var target_camera_z = global_transform.origin.z + 10
	var camera_position = camera2.global_transform.origin.z
	var camera_speed = (target_camera_z - camera_position) * delta * max_camera_speed
	camera_speed = clamp(camera_speed, -max_camera_speed, max_camera_speed)
	camera2.global_transform.origin.z += camera_speed * delta
