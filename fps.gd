class_name ServerNode
extends Node

var server := UDPServer.new()
var peers = []  # Liste des pairs connectés

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
	if server.is_connection_available():
		var peer: PacketPeerUDP = server.take_connection()
		if peer:
			var packet = peer.get_packet()
			print("Connexion acceptée : %s:%d" % [peer.get_packet_ip(), peer.get_packet_port()])
			print("Données reçues : %s" % [packet.get_string_from_utf8()])
			# Répond au pair pour confirmer la réception
			peer.put_packet(packet)
			# Ajoute le pair à la liste pour les communications ultérieures
			peers.append(peer)
	
	# Traite les pairs déjà connectés
	for i in range(peers.size()):
		var peer = peers[i]
		# Exemple : Envoi d'un message périodique (remplacer par votre logique)
		# peer.put_packet("Ping depuis le serveur".to_utf8())
