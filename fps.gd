extends Node

var udp_socket = UDPServer.new()
var port = 12345  # Port pour le socket UDP
@onready var fps_label = $FPSLabel  # Assurez-vous que le chemin soit correct

func _ready():
	if udp_socket.listen(port) != OK:
		print("Impossible de démarrer le serveur UDP")
		return
	print("Serveur UDP démarré sur le port %d" % port)

func _process(delta):
		# Calcule et affiche les FPS
	fps_label.text = "FPS: " + str(Engine.get_frames_per_second())
	while udp_socket.is_connection_available():
		var packet = udp_socket.get_packet()
		var message = packet.get_string_from_utf8()
		if message == "BUTTON_1_PRESSED":
			handle_button_1()
		elif message == "BUTTON_2_PRESSED":
			handle_button_2()

func handle_button_1():
	print("Bouton 1 pressé !")
	# Ajoutez ici la logique pour le bouton 1, par exemple :
	# Déplacer un personnage à gauche
	pass

func handle_button_2():
	print("Bouton 2 pressé !")
	# Ajoutez ici la logique pour le bouton 2, par exemple :
	# Déplacer un personnage à droite
	pass
