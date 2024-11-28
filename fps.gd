class_name ServerNode
extends Node

var server := UDPServer.new()
var port := 12345
var player: CharacterBody3D  # Référence au personnage à contrôler
var fps_label: Label  # Référence au Label pour afficher les FPS

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

	# Référence au Label pour afficher les FPS
	fps_label = $FPSLabel  # Remplacez $FPSLabel par le chemin exact du Label
	if fps_label:
		print("FPSLabel trouvé avec succès.")
	else:
		print("Erreur : FPSLabel introuvable.")

func _process(delta):
	# Met à jour les FPS dans le Label
	if fps_label:
		fps_label.text = "FPS : %d" % Engine.get_frames_per_second()
	
	server.poll()  # Vérifie les connexions UDP

	while server.is_connection_available():
		var peer: PacketPeerUDP = server.take_connection()
		if peer:
			var packet = peer.get_packet()
			var command = packet.get_string_from_utf8()
			print("Commande reçue : %s" % command)

			# Interpréter les commandes
			match command:
				"BUTTON_GAUCHE":
					player.move_left()
				"BUTTON_DROIT":
					player.move_right()
				"BUTTON_SAUT":
					player.jump()
				_:
					print("Commande inconnue : %s" % command)

			# Répondre au client (facultatif)
			peer.put_packet(packet)
