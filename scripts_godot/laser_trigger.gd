extends Area3D

@export var laser_scene: PackedScene
@export var texture_rect_path: NodePath  # Chemin vers le TextureRect dans la hiérarchie
var laser_instance
var player_detected = false

var server_node: ServerNode
var texture_rect: TextureRect

func _ready():
	print("Laser: Initialisation terminée.")

	# Connexion au ServerNode
	server_node = get_tree().get_root().get_node("Main/ServerNode")
	if server_node == null:
		print("Erreur : Impossible de trouver le nœud ServerNode.")
		
		# Récupération du TextureRect pour l'image 2D
	if texture_rect_path:
		texture_rect = get_node(texture_rect_path)
		if texture_rect and texture_rect is TextureRect:
			print("TextureRect trouvé : %s" % texture_rect.name)
			texture_rect.visible = false
		else:
			print("Erreur : Le noeud ciblé n'est pas un TextureRect ou introuvable.")
	else:
		print("Erreur : Aucun chemin spécifié pour texture_rect_path.")

func _on_body_entered(body):
	if body.name == "Player" and not player_detected:
		print("Le joueur a activé le laser.")
		player_detected = true

		# Affiche l'image 2D temporairement
		if texture_rect:
			texture_rect.visible = true  # Affiche l'image
			var timer = Timer.new()
			timer.wait_time = 0.5  # Durée de 0.5 seconde
			timer.one_shot = true
			timer.connect("timeout", Callable(self, "_hide_texture_rect"))
			add_child(timer)
			timer.start()

		# Envoi des données de la plateforme au serveur
		send_platform_data()

		if texture_rect_path:
			texture_rect = get_node(texture_rect_path)
			if texture_rect:
				update_texture_position()
				texture_rect.visible = true  # Affiche à nouveau au cas où
			else:
				print("Erreur : TextureRect introuvable !")
		else:
			print("Erreur : Aucun chemin de TextureRect spécifié.")

# Fonction appelée après le délai pour masquer l'image
func _hide_texture_rect():
	if texture_rect:
		texture_rect.visible = false
		print("TextureRect masqué après le délai.")

# 🚀 Fonction pour envoyer les données de position au serveur
func send_platform_data():
	if server_node and server_node.client != null and server_node.client.get_status() == StreamPeerTCP.STATUS_CONNECTED:
		var platform_data = determine_platform_position()
		
		# Envoi immédiat de la position
		server_node.client.put_utf8_string(platform_data + "\n")
		print("Données envoyées au serveur : %s" % platform_data)
		
		# Mise en place d'un Timer pour envoyer "0" après 0.5 secondes
		var timer = Timer.new()
		timer.wait_time = 0.5
		timer.one_shot = true
		timer.connect("timeout", Callable(self, "_send_zero_to_server"))
		add_child(timer)
		timer.start()
	else:
		print("Erreur : Pas de client TCP connecté.")

# ⏱️ Fonction appelée après le délai
func _send_zero_to_server():
	print("cense envoyer 0")
	if server_node and server_node.client != null and server_node.client.get_status() == StreamPeerTCP.STATUS_CONNECTED:
		server_node.client.put_utf8_string("0\n")
		print("Données '0' envoyées au serveur.")
	else:
		print("Erreur : Pas de client TCP connecté.")

func update_texture_position():
	if texture_rect:
		# Récupérer et limiter X à la plage [-20, 20]
		var area3d_x = clamp(global_transform.origin.x, -20, 20)

		# Mapper X (-20 à 20) sur la position 2D X (0 à 1366)
		texture_rect.position.x = map_range(area3d_x, -20, 20, 300, 1066)

		# Debug : Afficher les informations pour vérification
		print("Position 3D X :", area3d_x, " → Position 2D X :", texture_rect.position.x)

func map_range(value, min_3D, max_3D, min_2D, max_2D):
	# Mappe une valeur d'une plage à une autre
	return ((value - min_3D) / (max_3D - min_3D)) * (max_2D - min_2D) + min_2D



# 🔍 Détermine la position de la plateforme pour envoyer au serveur
func determine_platform_position() -> String:
	var platform_x = global_transform.origin.x
	print("X de la plateforme %d" % platform_x)
	if platform_x < -1:
		return "1"  # Gauche
	elif platform_x > 1:
		return "2"  # Droite
	else:
		return "3"
	#faire des zones de plateforme -25, -7, 10
