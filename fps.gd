class_name ServerNode
extends Node

var server := TCPServer.new()  # Créer un serveur TCP
var port := 12345  # Port d'écoute
var client = null  # Stocker le client connecté

var player: CharacterBody3D  # Référence au personnage à contrôler

func _ready():
	var err = server.listen(port)
	if err == OK:
		print("Serveur TCP démarré sur le port %d" % port)
		set_process(true)
		
		# Trouver et assigner la référence au joueur (supposons qu'il est un enfant de la scène principale)
		player = $Player  # Assure-toi que le nœud "Player" existe dans la scène
	else:
		print("Erreur lors du démarrage du serveur TCP : %s" % err)

func _process(delta):
	if server.is_connection_available():
		client = server.take_connection()  # Accepter une nouvelle connexion
		if client != null:
			print("Nouveau client connecté.")
	
	if client != null and client.get_status() == StreamPeerTCP.STATUS_CONNECTED:
		if client.get_available_bytes() > 0:
			var data = client.get_utf8_string(client.get_available_bytes())
			print("Données reçues du client : %s" % data)

			# Si les données sont des coordonnées, les extraire
			if data.find("X:") != -1:
				var x_str = data.split(": ")[1]
				var x = int(x_str)
				
				# Limiter la valeur de X entre 0 et 255
				x = clamp(x, 0, 255)
				
				print("Coordonnée extraite : X = %d" % x)

				# Déplacer le personnage en fonction de la coordonnée X reçue
				_move_player(x)

func _move_player(x: int):
	# Déplacement du personnage uniquement sur l'axe X
	var new_position = Vector3(x, player.global_position.y, player.global_position.z)
	player.global_position = new_position
	print("Personnage déplacé à : X = %d" % x)

func _exit_tree():
	server.stop()
	print("Serveur TCP arrêté.")
