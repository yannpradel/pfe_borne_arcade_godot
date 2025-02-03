extends AnimatedSprite3D

@onready var player := $"../Player"  # Référence au joueur
@onready var camera2 := $"../SubViewport/Camera3DBarnaby"  # Référence à la caméra secondaire
@onready var animated_sprite := $"../Barnaby"  # Référence à l'AnimatedSprite3D (dans la même scène ou sous ce noeud)

@export var max_camera_speed = 22.5  # Vitesse maximale de la caméra pour rattraper l'ennemi
@export var camera_distance = 50.0  # Distance constante entre la caméra et l'ennemi
@export var min_distance_from_player = 20.0  # Distance minimale entre le joueur et Barnaby
@export var max_distance_x_from_player = 5.0  # Distance maximale autorisée en X entre Barnaby et le joueur

func _ready():
	# Vérifie si l'animation "barnaby" existe
	if sprite_frames.has_animation("barnaby"):
		animation = "barnaby"
		play()
	else:
		print("L'animation 'barnaby' n'existe pas dans SpriteFrames !")

func _process(delta):
	if not player:
		print("Le joueur n'est pas trouvé !")
		return

	# Vérification de la distance avec le joueur
	adjust_distance_from_player(delta)

	# Synchroniser la vitesse de l'ennemi sur l'axe Z avec celle du joueur
	var player_velocity_z = player.get("velocity").z  # Suppose que le joueur utilise une propriété "velocity"
	global_transform.origin.z += player_velocity_z * delta

	# Ajuster la position de la caméra pour suivre Barnaby
	adjust_camera2_speed(delta)

# Empêche le personnage de se rapprocher trop du joueur et de dépasser la distance X autorisée
func adjust_distance_from_player(delta):
	var player_position = player.global_transform.origin
	var barnaby_position = global_transform.origin

	# Distance en X et Z
	var distance_x = abs(barnaby_position.x - player_position.x)
	var distance_z = abs(barnaby_position.z - player_position.z)

	# Correction si Barnaby est trop proche en Z
	if distance_z < min_distance_from_player:
		var direction_away = (barnaby_position - player_position).normalized()
		global_transform.origin += direction_away * (min_distance_from_player - distance_z)

	# Correction si Barnaby dépasse en X
	if distance_x > max_distance_x_from_player:
		global_transform.origin.x = player_position.x + sign(barnaby_position.x - player_position.x) * max_distance_x_from_player

# Ajustement de la vitesse de la deuxième caméra pour suivre Barnaby
func adjust_camera2_speed(delta):
	var target_camera_z = global_transform.origin.z + camera_distance
	var camera_position = camera2.global_transform.origin.z
	var camera_speed = (target_camera_z - camera_position) * max_camera_speed

	camera_speed = clamp(camera_speed, -max_camera_speed, max_camera_speed)
	camera2.global_transform.origin.z += camera_speed * delta
