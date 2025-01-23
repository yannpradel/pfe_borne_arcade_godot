extends Area3D

@export var laser_scene: PackedScene
var server_node: ServerNode
var total_session_timer: Timer
var laser_spawn_timer: Timer
var active_lasers = []
var can_spawn_laser = true

func _ready():
	server_node = get_tree().get_root().get_node("Main/ServerNode")
	if server_node == null:
		print("Erreur : Impossible de trouver le nœud ServerNode.")
	connect("body_entered", self._on_body_entered)

func _on_body_entered(body):
	if body.name == "Player":
		print("Joueur dans la cage")
		start_laser_sequence()

func start_laser_sequence():
	# Timer total de la session
	total_session_timer = Timer.new()
	total_session_timer.wait_time = 60.0
	total_session_timer.one_shot = true
	total_session_timer.connect("timeout", Callable(self, "_end_laser_session"))
	add_child(total_session_timer)
	total_session_timer.start()

	# Timer pour spawner des lasers
	laser_spawn_timer = Timer.new()
	laser_spawn_timer.wait_time = 2.0  # Toutes les 2 secondes
	laser_spawn_timer.connect("timeout", Callable(self, "_spawn_laser"))
	add_child(laser_spawn_timer)
	laser_spawn_timer.start()

func _spawn_laser():
	if not can_spawn_laser:
		return
	
	can_spawn_laser = false
	
	var positions = ["left", "center", "right"]
	var chosen_position = positions[randi() % positions.size()]
	
	send_platform_data(chosen_position)
	
	if laser_scene:
		var laser_instance = laser_scene.instantiate()
		get_parent().add_child(laser_instance)
		
		match chosen_position:
			"left":
				laser_instance.global_transform.origin = global_transform.origin + Vector3(-15, 0, -19)
			"right":
				laser_instance.global_transform.origin = global_transform.origin + Vector3(15, 0, -19)
			"center":
				laser_instance.global_transform.origin = global_transform.origin + Vector3(0, 0, -19)
		
		# Timer pour désactiver ce laser spécifique après 2 secondes
		var laser_timer = Timer.new()
		laser_timer.wait_time = 2.0
		laser_timer.one_shot = true
		laser_timer.connect("timeout", Callable(self, "_remove_laser").bind(laser_instance))
		add_child(laser_timer)
		laser_timer.start()
		
		# Timer pour réactiver la spawn de lasers
		var spawn_delay_timer = Timer.new()
		spawn_delay_timer.wait_time = 2.0
		spawn_delay_timer.one_shot = true
		spawn_delay_timer.connect("timeout", Callable(self, "_enable_laser_spawn"))
		add_child(spawn_delay_timer)
		spawn_delay_timer.start()

func _remove_laser(laser):
	if laser:
		laser.queue_free()

func _enable_laser_spawn():
	can_spawn_laser = true

func _end_laser_session():
	# Arrêter les timers
	if laser_spawn_timer:
		laser_spawn_timer.stop()
		laser_spawn_timer.queue_free()
	
	# Supprimer tous les lasers restants
	for laser in get_parent().get_children():
		if laser.name.begins_with("Laser"):
			laser.queue_free()

func send_platform_data(position):
	if server_node and server_node.client != null and server_node.client.get_status() == StreamPeerTCP.STATUS_CONNECTED:
		var platform_code = {"left": "1", "right": "2", "center": "3"}
		server_node.client.put_utf8_string(platform_code[position] + "\n")
		
		var zero_timer = Timer.new()
		zero_timer.wait_time = 0.5
		zero_timer.one_shot = true
		zero_timer.connect("timeout", Callable(self, "_send_zero_to_server"))
		add_child(zero_timer)
		zero_timer.start()

func _send_zero_to_server():
	if server_node and server_node.client != null and server_node.client.get_status() == StreamPeerTCP.STATUS_CONNECTED:
		server_node.client.put_utf8_string("0\n")
