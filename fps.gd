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
		player = get_tree().get_root().get_node("Main/Player")
	else:
		print("Erreur lors du démarrage du serveur TCP : %s" % err)
		
	_launch_python_script()

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
			
			if data.strip_edges() == "jump":
				if player and player.has_method("jump"):
					player.jump()
					print("Commande 'jump' exécutée : le joueur saute.")
				else:
					print("Erreur : La méthode 'jump' n'existe pas ou 'player' est invalide.")

func _move_player(x: int):
	# Déplacement du personnage uniquement sur l'axe X
	var new_position = Vector3(x, player.global_position.y, player.global_position.z)
	player.global_position = new_position
	print("Personnage déplacé à : X = %d" % x)
	

func _exit_tree():
	server.stop()
	print("Serveur TCP arrêté.")
	
func _launch_python_script():
	var python_script_path = "res://python udp/tcp_for_serial.py"  # Chemin relatif
	var absolute_path = ProjectSettings.globalize_path(python_script_path)  # Convertit en chemin absolu
	var output = []  # Tableau pour capturer la sortie standard (stdout)

	# Convertit les arguments en PackedStringArray
	var args = PackedStringArray([absolute_path])

	print("avant le execute du python")
	# Exécute le script avec blocking = true pour capturer la sortie
	var result = OS.execute("python3", args, output, false)  # output suivi de read_stderr

	print("Chemin absolu du script Python : %s" % absolute_path)

	if result == OK:
		print("Script Python lancé avec succès :")
		print("Sortie du script Python :\n%s" % String("\n").join(output))  # Affiche la sortie capturée
	else:
		print("Erreur lors du lancement du script Python. Code : %d" % result)
		print("Sortie capturée (potentiellement des erreurs) :\n%s" % String("\n").join(output))
