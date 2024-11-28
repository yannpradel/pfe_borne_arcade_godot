extends Node

var udp_socket = UDPServer.new()
var port = 12345  # Port utilisé pour l'écoute UDP

func _ready():
	print("Démarrage du serveur UDP...")
	var result = udp_socket.listen(port, "*")  # Écoute sur toutes les interfaces
	if result != OK:
		print("Erreur : Impossible de démarrer le serveur UDP sur le port %d. Code d'erreur : %d" % [port, result])
	else:
		print("Serveur UDP démarré sur le port %d" % port)
		# Affiche les détails du serveur
		print("Adresse IP d'écoute : %s" % udp_socket.get_local_address())
		print("Port d'écoute : %d" % port)


func _process(delta):
	# Vérifie si des données sont disponibles sur le port
	while udp_socket.is_connection_available():
		var packet = udp_socket.get_packet()
		print("=== Données détectées ===")
		print("Taille du paquet :", packet.size())  # Taille des données reçues
		print("Données brutes :", packet)  # Contenu brut du paquet

		if packet.size() > 0:
			# Essaie de décoder les données en UTF-8
			var message = packet.get_string_from_utf8()
			print("Message décodé :", message)
			
			# Traite le message en fonction de son contenu
			if message == "BUTTON_1_PRESSED":
				print("Action détectée : Bouton 1 pressé")
				handle_button_1()
			elif message == "BUTTON_2_PRESSED":
				print("Action détectée : Bouton 2 pressé")
				handle_button_2()
			else:
				print("Message inconnu reçu :", message)

func handle_button_1():
	# Logique pour le bouton 1
	print("Fonction handle_button_1 appelée")
	print("Ajoutez ici une action pour le bouton 1")

func handle_button_2():
	# Logique pour le bouton 2
	print("Fonction handle_button_2 appelée")
	print("Ajoutez ici une action pour le bouton 2")
