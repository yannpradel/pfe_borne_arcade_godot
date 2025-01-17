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
		
		# Trouver et assigner la référence au joueur
		player = get_node("../Player")  # Chemin relatif à partir de ServerNode
		if player == null:
			print("Erreur : le nœud 'Player' est introuvable. Vérifiez le nom ou la hiérarchie.")
	else:
		print("Erreur lors du démarrage du serveur TCP : %s" % err)

func _process(delta):
	if server.is_connection_available():
		client = server.take_connection()  # Accepter une nouvelle connexion
		if client != null:
			print("Nouveau client connecté.")
	
	if client != null and client.get_status() == StreamPeerTCP.STATUS_CONNECTED:
		if client.get_available_bytes() > 0:
			var data = client.get_utf8_string(client.get_available_bytes()).strip_edges()
			print("Données reçues du client : %s" % data)

			# Extraire les coordonnées X depuis les données reçues
			if data.find("X:") != -1:
				var x_str = data.split(":")[1]
				var x = float(x_str)  # Pas de vérification
				_move_player(x)

func _move_player(x: float):
	# Déplacement du personnage uniquement sur l'axe X
	if player != null:
		player.global_position.x = x
	else:
		print("Erreur : Le joueur n'est pas disponible.")

func _exit_tree():
	server.stop()
	print("Serveur TCP arrêté.")
