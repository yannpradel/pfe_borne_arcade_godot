class_name ServerNode
extends Node

var server := UDPServer.new()
var port := 12345
var player: CharacterBody3D  # Référence au personnage à contrôler

func _ready():
	print("Démarrage du serveur UDP sur le port %d..." % port)
	var result = server.listen(port)
	if result != OK:
		print("Erreur : Impossible de démarrer le serveur UDP sur le port %d. Code d'erreur : %d" % [port, result])
	else:
		print("Serveur UDP démarré avec succès sur le port %d" % port)

	# Référence au joueur
	player = $Player  # Remplacez $Player par le chemin exact de votre personnage
	if player:
		print("Référence au joueur trouvée.")
	else:
		print("Erreur : Impossible de trouver le joueur.")

func _process(delta):
	server.poll()  # Vérifie les connexions UDP

	while server.is_connection_available():
		var peer: PacketPeerUDP = server.take_connection()
		if peer:
			var packet = peer.get_packet()
			var command = packet.get_string_from_utf8()

			# Interpréter les commandes
			match command:
				"BUTTON_GAUCHE":
					player.move_left()
				"STOP_BUTTON_GAUCHE":
					player.stop_move_left()
				"BUTTON_DROIT":
					player.move_right()
				"STOP_BUTTON_DROIT":
					player.stop_move_right()
				"BUTTON_AVANT":
					player.move_forward()
				"STOP_BUTTON_AVANT":
					player.stop_move_forward()
				"BUTTON_ARRIERE":
					player.move_back()
				"STOP_BUTTON_ARRIERE":
					player.stop_move_back()
				"BUTTON_SAUT":
					player.jump()
				_:
					print("Commande inconnue : %s" % command)

			# Répondre au client (facultatif)
			peer.put_packet(packet)
