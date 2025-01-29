extends AnimatedSprite3D

@onready var player := $"../Player"  # Référence au joueur (ajustez le chemin si nécessaire)
@onready var camera2 := $"../SubViewport/Camera3DBarnaby"  # Référence à la caméra secondaire
@onready var animated_sprite := $"../Barnaby"  # Référence à l'AnimatedSprite3D (dans la même scène ou sous ce noeud)
@export var max_camera_speed = 22.5  # Vitesse maximale de la caméra pour rattraper l'ennemi
@export var camera_distance = 50.0  # Distance constante entre la caméra et l'ennemi

func _ready():
	# Vérifie si l'animation "barnaby" existe
	if sprite_frames.has_animation("barnaby"):
		# Définit et joue l'animation
		animation = "barnaby"
		play()  # Joue l'animation active
	else:
		print("L'animation 'barnaby' n'existe pas dans SpriteFrames !")


func _process(delta):
	# Vérifier que le joueur existe
	if not player:
		print("Le joueur n'est pas trouvé !")
		return

	# Synchroniser la vitesse de l'ennemi sur l'axe Z avec celle du joueur
	var player_velocity_z = player.get("velocity").z  # Suppose que le joueur utilise une propriété "velocity"
	global_transform.origin.z += player_velocity_z * delta

	# Ajuster la position de la caméra pour suivre l'ennemi
	adjust_camera2_speed(delta)

# Ajustement de la vitesse de la deuxième caméra pour suivre l'ennemi
func adjust_camera2_speed(delta):
	# Position cible pour la caméra
	var target_camera_z = global_transform.origin.z + camera_distance
	# Position actuelle de la caméra
	var camera_position = camera2.global_transform.origin.z
	# Calcul de la vitesse de la caméra pour rattraper la position cible
	var camera_speed = (target_camera_z - camera_position) * max_camera_speed
	# Limiter la vitesse pour éviter les mouvements trop brusques
	camera_speed = clamp(camera_speed, -max_camera_speed, max_camera_speed)
	# Déplacer la caméra en fonction de la vitesse calculée
	camera2.global_transform.origin.z += camera_speed * delta
