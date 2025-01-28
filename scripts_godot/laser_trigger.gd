extends Area3D

@export var laser_scene: PackedScene
@export var texture_rect_path: NodePath  # Chemin vers le TextureRect dans la hiérarchie
var server_node: ServerNode
var texture_rect: TextureRect
var debug_polygon: Polygon2D  # Zone visuelle pour le débogage
var player_detected = false
var is_zone_dangerous = false
var dangerous_zone_min_x = 0
var dangerous_zone_max_x = 0

func _ready():
	_initialize_server_node()
	_initialize_texture_rect()

	# Vérifier si le signal "body_entered" est déjà connecté avant de le connecter
	if not is_connected("body_entered", Callable(self, "_on_body_entered")):
		connect("body_entered", Callable(self, "_on_body_entered"))
	else:
		print("Le signal 'body_entered' est déjà connecté à _on_body_entered.")


func _initialize_server_node():
	server_node = get_tree().get_root().get_node("Main/ServerNode")
	if server_node == null:
		print("Erreur : Impossible de trouver le nœud ServerNode.")

func _initialize_texture_rect():
	if texture_rect_path:
		texture_rect = get_node(texture_rect_path)
		if texture_rect and texture_rect is TextureRect:
			texture_rect.visible = false
		else:
			print("Erreur : Le noeud spécifié n'est pas un TextureRect.")
	else:
		print("Erreur : Aucun chemin de TextureRect spécifié.")

func _on_body_entered(body):
	if body.name == "Player" and not player_detected:
		player_detected = true
		_display_laser_effect()
		_send_platform_data()
		_mark_zone_as_dangerous()

		# Créer un timer pour retarder l'apparition du laser
		var delay_timer = Timer.new()
		delay_timer.wait_time = 1.0  # Délai avant l'affichage du laser (1 seconde)
		delay_timer.one_shot = true
		delay_timer.connect("timeout", Callable(self, "_spawn_laser_scene"))
		add_child(delay_timer)
		delay_timer.start()

func _spawn_laser_scene():
	if laser_scene:
		var laser_instance = laser_scene.instantiate()
		get_parent().add_child(laser_instance)

		# Ajuste la taille du laser en fonction des limites de la zone dangereuse
		var laser_scale = laser_instance.get_node("CollisionShape3D")  # Remplacez "CollisionShape3D" par le nœud à ajuster
		if laser_scale:
			var zone_width = dangerous_zone_max_x - dangerous_zone_min_x
			laser_instance.global_transform.origin.x = dangerous_zone_min_x + zone_width / 2.0
			laser_scale.scale.x = zone_width + 50  # Ajuste l'échelle X du laser
		else:
			print("Erreur : Nœud de collision ou échelle non trouvé dans la scène du laser.")

		# Connecter l'événement de collision du laser
		laser_instance.connect("body_entered", Callable(self, "_on_laser_body_entered"))

		# Vérifier si le joueur est DÉJÀ dans la zone dangereuse
		_check_player_in_laser_zone(laser_instance)

		# Création d'un timer pour désactiver le laser après 1 seconde
		var laser_timer = Timer.new()
		laser_timer.wait_time = 1.0
		laser_timer.one_shot = true
		laser_timer.connect("timeout", Callable(self, "_remove_laser").bind(laser_instance))
		add_child(laser_timer)
		laser_timer.start()
	else:
		print("Erreur : `laser_scene` n'est pas défini.")


func _display_laser_effect():
	if texture_rect:
		update_texture_position()
		texture_rect.visible = true
		var animation_player = texture_rect.get_node("MoveTexture")
		if animation_player:
			animation_player.play("mark_animation")

		var timer = Timer.new()
		timer.wait_time = 0.7
		timer.one_shot = true
		timer.connect("timeout", Callable(self, "_hide_texture_rect"))
		add_child(timer)
		timer.start()

func _hide_texture_rect():
	if texture_rect:
		texture_rect.visible = false
		
func _mark_zone_as_dangerous():
	is_zone_dangerous = true
	_set_dangerous_zone_limits()  # Définir la bonne zone pour ce trigger

	# Afficher le point d’exclamation à la bonne position
	if texture_rect:
		texture_rect.visible = true


func _set_dangerous_zone_limits():
	var area3d_x = global_transform.origin.x
	if area3d_x < -7:
		dangerous_zone_min_x = -25
		dangerous_zone_max_x = -7
	elif area3d_x <= 10:
		dangerous_zone_min_x = -7
		dangerous_zone_max_x = 10
	else:
		dangerous_zone_min_x = 10
		dangerous_zone_max_x = 25
	print("Zone dangereuse activée : X entre", dangerous_zone_min_x, "et", dangerous_zone_max_x)

func _send_platform_data():
	if server_node and server_node.client != null and server_node.client.get_status() == StreamPeerTCP.STATUS_CONNECTED:
		var platform_data = determine_platform_position()
		server_node.client.put_utf8_string(platform_data + "\n")
		print("Données envoyées au serveur : %s" % platform_data)
		_send_zero_after_delay()

func _send_zero_after_delay():
	var timer = Timer.new()
	timer.wait_time = 0.5
	timer.one_shot = true
	timer.connect("timeout", Callable(self, "_send_zero_to_server"))
	add_child(timer)
	timer.start()

func _send_zero_to_server():
	if server_node and server_node.client != null and server_node.client.get_status() == StreamPeerTCP.STATUS_CONNECTED:
		server_node.client.put_utf8_string("0\n")

func determine_platform_position() -> String:
	var area3d_x = global_transform.origin.x
	if area3d_x < -7:
		return "1"  # Gauche
	elif area3d_x <= 10:
		return "2"  # Centre
	else:
		return "3"  # Droite

func update_texture_position():
	print("aoiap")
	if texture_rect:
		var area3d_x = global_transform.origin.x
		if area3d_x < -7:
			texture_rect.position.x = 250
		elif area3d_x <= 10:
			texture_rect.position.x = 650
		else:
			texture_rect.position.x = 1050
			
func _remove_laser(laser_instance):
	if laser_instance:
		laser_instance.queue_free()  # Supprime le laser après 1 seconde.")

func _on_laser_body_entered(body):
	if body.name == "Player":
		body.lose_life()
		
func _check_player_in_laser_zone(_laser_instance):
	var player = get_tree().get_root().get_node("Main/Player")
	if player:
		var player_x = player.global_transform.origin.x
		# Vérifie si le joueur est dans la zone couverte par le laser
		if player_x >= dangerous_zone_min_x and player_x <= dangerous_zone_max_x:
			player.lose_life()
