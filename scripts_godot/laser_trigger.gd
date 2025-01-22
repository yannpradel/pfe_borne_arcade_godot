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


func _on_body_entered(body):
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
		
		# Envoi immédiat de la position
		server_node.client.put_utf8_string(platform_data + "\n")
		print("Données envoyées au serveur : %s" % platform_data)
		
		# Mise en place d'un Timer pour envoyer "0" après 0.5 secondes
		var timer = Timer.new()
		timer.wait_time = 0.5
		timer.one_shot = true
		timer.connect("timeout", Callable(self, "_send_zero_to_server"))
		add_child(timer)
		timer.start()
	else:
		print("Erreur : Pas de client TCP connecté.")

# ⏱️ Fonction appelée après le délai
func _send_zero_to_server():
	print("cense envoyer 0")
	if server_node and server_node.client != null and server_node.client.get_status() == StreamPeerTCP.STATUS_CONNECTED:
		server_node.client.put_utf8_string("0\n")
		print("Données '0' envoyées au serveur.")
	else:
		print("Erreur : Pas de client TCP connecté.")


# 🔍 Détermine la position de la plateforme pour envoyer au serveur
func determine_platform_position() -> String:
	var platform_x = global_transform.origin.x
	print("X de la plateforme %d" % platform_x)
	if platform_x < -1:
		return "1"  # Gauche
	elif platform_x > 1:
		return "2"  # Droite
	else:
		return "3"
	#faire des zones de plateforme -25, -7, 10
