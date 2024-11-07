extends CharacterBody3D

@export var speed = 14
@export var fall_acceleration = 75
@export var jump_force = 15  # Force du saut
@export var max_camera_speed = 22.5  # Vitesse maximale de la caméra

var target_velocity = Vector3.ZERO
@onready var camera := $"../CameraPivot/Camera3D"

# Variable pour le double saut
var has_double_jumped = false

func _physics_process(delta):
	var direction = Vector3.ZERO

	# Détection des mouvements horizontaux
	if Input.is_action_pressed("move_right"):
		direction.x += 1
	if Input.is_action_pressed("move_left"):
		direction.x -= 1
	if Input.is_action_pressed("move_back"):
		direction.z += 1
	if Input.is_action_pressed("move_forward"):
		direction.z -= 1

	if direction != Vector3.ZERO:
		direction = direction.normalized()
		$Pivot.basis = Basis.looking_at(direction)

	# Ground Velocity
	target_velocity.x = direction.x * speed
	target_velocity.z = direction.z * speed

	# Saut et double saut
	if Input.is_action_just_pressed("jump"):
		if is_on_floor():
			target_velocity.y = jump_force  # Applique la force du saut
			has_double_jumped = false  # Réinitialise le double saut lorsqu'on touche le sol
		elif not has_double_jumped:
			target_velocity.y = jump_force  # Applique la force du double saut
			has_double_jumped = true  # Empêche un deuxième double saut

	# Gravité (si le personnage est en l'air)
	if not is_on_floor():
		target_velocity.y -= fall_acceleration * delta

	# Déplacement du personnage
	velocity = target_velocity
	move_and_slide()

	# Ajuste la vitesse de la caméra pour suivre le personnage
	adjust_camera_speed(delta)

func adjust_camera_speed(delta):
	# Calcule la position cible de la caméra pour garder le personnage centré
	var target_camera_z = global_transform.origin.z + 50  # Ajuste l'offset de 10 selon le besoin
	var camera_position = camera.global_transform.origin.z

	# Calcul de la vitesse de la caméra pour la rapprocher de la cible
	var camera_speed = (target_camera_z - camera_position) * delta * max_camera_speed

	# Limite la vitesse de la caméra à la valeur maximale
	camera_speed = clamp(camera_speed, -max_camera_speed, max_camera_speed)
	
	# Déplace la caméra sur l'axe Z en fonction de la vitesse calculée
	camera.global_transform.origin.z += camera_speed * delta
