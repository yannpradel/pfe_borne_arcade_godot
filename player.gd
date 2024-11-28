extends CharacterBody3D

@export var speed = 14
@export var fall_acceleration = 75
@export var jump_force = 15
@export var max_camera_speed = 22.5

var target_velocity = Vector3.ZERO
@onready var camera := $"../CameraPivot/Camera3D"

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

func move_left():
	print("Déplacement à gauche")
	target_velocity.x = -speed

func move_right():
	print("Déplacement à droite")
	target_velocity.x = speed

func jump():
	if is_on_floor():
		print("Saut")
		target_velocity.y = jump_force
		has_double_jumped = false
	elif not has_double_jumped:
		print("Double saut")
		target_velocity.y = jump_force
		has_double_jumped = true

func adjust_camera_speed(delta):
	var target_camera_z = global_transform.origin.z + 50
	var camera_position = camera.global_transform.origin.z
	var camera_speed = (target_camera_z - camera_position) * delta * max_camera_speed
	camera_speed = clamp(camera_speed, -max_camera_speed, max_camera_speed)
	camera.global_transform.origin.z += camera_speed * delta
