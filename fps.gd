class_name ServerNode
extends Node

var server := UDPServer.new()

func _ready():
	var port = 12345
	print("Démarrage du serveur UDP sur le port %d..." % port)
	var result = server.listen(port)
	if result != OK:
		print("Erreur : Impossible de démarrer le serveur UDP sur le port %d. Code d'erreur : %d" % [port, result])
	else:
		print("Serveur UDP démarré avec succès sur le port %d" % port)

func _process(delta):
	server.poll()  # Nécessaire pour vérifier les connexions entrantes

	# Vérifie si une connexion est disponible
	while server.is_connection_available():
		var peer: PacketPeerUDP = server.take_connection()
		if peer:
			var packet = peer.get_packet()
			print("Connexion reçue : %s:%d" % [peer.get_packet_ip(), peer.get_packet_port()])
			print("Message reçu : %s" % [packet.get_string_from_utf8()])
			# Répond directement au client
			peer.put_packet(packet)
