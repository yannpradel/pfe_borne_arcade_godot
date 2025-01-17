extends Area3D

@export var laser_scene: PackedScene
var laser_instance
var player_detected = false

var server_node: ServerNode

func _ready():
	print("Laser: Initialisation terminée.")

	# Connexion au ServerNode
	server_node = get_tree().get_root().get_node("Main/ServerNode")
	if server_node == null:
		print("Erreur : Impossible de trouver le nœud ServerNode.")

	# Connexion du signal body_entered
	connect("body_entered", self._on_body_entered)
	print("Signal body_entered connecté avec succès.")

func _on_body_entered(body):
	print("Un corps est entré dans l'Area3D : %s" % body.name)

	if body.name == "Player" and not player_detected:
		print("Le joueur a activé le laser.")
		player_detected = true

		# Envoi des données de la plateforme au serveur
		send_platform_data()

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
			print("Le laser a déjà été activé pour ce joueur.")

# 🚀 Fonction pour envoyer les données de position au serveur
func send_platform_data():
	if server_node and server_node.client != null and server_node.client.get_status() == StreamPeerTCP.STATUS_CONNECTED:
		var platform_data = determine_platform_position()
		server_node.client.put_utf8_string(platform_data + "\n")
		print("Données envoyées au serveur : %s" % platform_data)
	else:
		print("Erreur : Pas de client TCP connecté.")

# 🔍 Détermine la position de la plateforme pour envoyer au serveur
func determine_platform_position() -> String:
	var platform_x = global_transform.origin.x
	if platform_x < -1:
		return "100"  # Gauche
	elif platform_x > 1:
		return "001"  # Droite
	else:
		return "010"
