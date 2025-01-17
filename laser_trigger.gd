extends Area3D

@export var laser_scene: PackedScene
var laser_instance
var player_detected = false

func _ready():
	print("Laser: Initialisation terminée.")
	connect("body_entered", self._on_body_entered)
	print("Signal body_entered connecté avec succès.")

func _on_body_entered(body):
	print("Un corps est entré dans l'Area3D : %s" % body.name)

	if body.name == "Player" and not player_detected:
		print("Le joueur a activé le laser.")
		player_detected = true

		if laser_scene:
			print("La scène du laser est chargée. Instanciation en cours...")
			laser_instance = laser_scene.instantiate()
			get_parent().add_child(laser_instance)
			print("Laser instancié et ajouté au parent.")

			# Positionner le laser
			laser_instance.global_transform.origin = global_transform.origin + Vector3(0, 2, 0)
			print("Laser positionné au-dessus de la plateforme : %s" % str(laser_instance.global_transform.origin))
		else:
			print("Erreur : laser_scene n'est pas défini.")
	else:
		if player_detected:
			print("Le laser a déjà été activé pour ce joueur.")
