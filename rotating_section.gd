extends Node3D

@export var rotation_speed = 150.0  # Vitesse des rotations en degrés par seconde
@export var translation_speed = 30.0  # Vitesse des translations

# Rotations cibles
var target_rotation_x = -30.0  # Rotation sur l'axe X
var current_rotation_x = 0.0

var target_rotation_z = -90.0  # Rotation sur l'axe Z
var current_rotation_z = 0.0

# Translations cibles
var target_translation_y = 10.0  # Fin de la translation sur l'axe Y
var current_translation_y = -4.0  # Début sur l'axe Y

var target_translation_x = 3.0  # Fin de la translation sur l'axe X
var current_translation_x = 0.0  # Début sur l'axe X

# Flag pour vérifier si les animations sont en cours
var is_transforming = false

@onready var camera := $"../CameraPivot"

func _process(delta):
	if not is_transforming:
		return

	var animation_complete = true

	# Translation sur l'axe Y
	if current_translation_y < target_translation_y:
		var step_y_translation = translation_speed * delta
		current_translation_y += step_y_translation
		current_translation_y = min(current_translation_y, target_translation_y)
		var new_position_y = camera.transform.origin
		new_position_y.y = current_translation_y
		camera.transform.origin = new_position_y
		animation_complete = false

	# Translation sur l'axe X
	if current_translation_x < target_translation_x:
		var step_x_translation = translation_speed * delta
		current_translation_x += step_x_translation
		current_translation_x = min(current_translation_x, target_translation_x)
		var new_position_x = camera.transform.origin
		new_position_x.x = current_translation_x
		camera.transform.origin = new_position_x
		animation_complete = false

	# Rotation sur l'axe X
	if current_rotation_x > target_rotation_x:
		var step_x_rotation = rotation_speed * delta
		current_rotation_x -= step_x_rotation
		current_rotation_x = max(current_rotation_x, target_rotation_x)
		camera.rotate_x(deg_to_rad(step_x_rotation))
		animation_complete = false

	# Rotation sur l'axe Z
	if current_rotation_z > target_rotation_z:
		var step_z_rotation = rotation_speed * delta
		current_rotation_z -= step_z_rotation
		current_rotation_z = max(current_rotation_z, target_rotation_z)
		camera.rotate_z(deg_to_rad(-step_z_rotation))
		animation_complete = false

	# Vérifie si toutes les animations sont terminées
	if animation_complete:
		log_final_camera_state()
		is_transforming = false  # Arrête les animations

func start_transformations():
	# Initialise toutes les positions et rotations
	current_rotation_x = 0.0
	current_rotation_z = 0.0
	current_translation_y = -4.0
	current_translation_x = 0.0
	is_transforming = true  # Active les animations

func log_final_camera_state():
	# Log la position et la rotation finale de la caméra
	var position = camera.transform.origin
	var rotation = camera.rotation_degrees
	print("Final Camera Position: ", position)
	print("Final Camera Rotation: ", rotation)

func _on_area_3d_body_entered(body: Node3D) -> void:
	if body.is_in_group("player"):  # Vérifie si le joueur entre dans la zone
		start_transformations()  # Lance les transformations
