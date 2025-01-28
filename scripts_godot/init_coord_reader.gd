class_name ClientNode
extends Node

var client := StreamPeerTCP.new()  # Créer un client TCP
var server_ip := "127.0.0.1"  # Adresse IP du serveur
var server_port := 12346  # Port du serveur

var player: CharacterBody3D  # Référence au personnage à contrôler

func _ready():
	# Connecter au serveur
	var err = client.connect_to_host(server_ip, server_port)
	if err == OK:
		print("Connexion au serveur %s:%d réussie." % [server_ip, server_port])
		set_process(true)
	else:
		print("Erreur de connexion au serveur : %s" % err)
		set_process(false)

	# Trouver et assigner la référence au joueur (supposons qu'il est un enfant de la scène principale)
	player = get_tree().get_root().get_node("Main/Player")

func _process(delta):
	if client.get_status() == StreamPeerTCP.STATUS_CONNECTED:
		# Vérifier si des données sont disponibles depuis le serveur
		if client.get_available_bytes() > 0:
			var data = client.get_utf8_string(client.get_available_bytes())
			print("Données reçues du serveur : %s" % data)

			# Si les données sont des coordonnées, les extraire
			if data.find("X:") != -1:
				var x_str = data.split(":")[1]
				var x = float(x_str)

				print("Coordonnée extraite : X = %d" % x)

				# Déplacer le personnage en fonction de la coordonnée X reçue
				_move_player(x)

			if data.strip_edges() == "jump":
				if player and player.has_method("jump"):
					player.jump()
					print("Commande 'jump' exécutée : le joueur saute.")
				else:
					print("Erreur : La méthode 'jump' n'existe pas ou 'player' est invalide.")
	else:
		print("Déconnecté du serveur.")
		set_process(false)

func _move_player(x: float):
	# Déplacement du personnage uniquement sur l'axe X
	var new_position = Vector3(x, player.global_position.y, player.global_position.z)
	player.global_position = new_position
	print("Personnage déplacé à : X = %d" % x)

func send_data(data: String):
	# Envoyer des données au serveur
	if client.get_status() == StreamPeerTCP.STATUS_CONNECTED:
		client.put_utf8_string(data)
		print("Données envoyées au serveur : %s" % data)
	else:
		print("Erreur : Impossible d'envoyer les données, client non connecté.")

func _exit_tree():
	if client.get_status() == StreamPeerTCP.STATUS_CONNECTED:
		client.disconnect_from_host()
		print("Déconnecté du serveur.")
