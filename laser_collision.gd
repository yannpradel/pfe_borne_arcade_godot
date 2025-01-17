extends Area3D

@export var laser_scene: PackedScene = preload("res://laser.tscn")
var laser_instance
var player_detected = false

var server_node: ServerNode

func _ready():
	server_node = get_tree().get_root().get_node("Main/ServerNode") as ServerNode
	if server_node == null:
		print("Erreur : Impossible de trouver le nœud ServerNode.")

	if $Timer:
		$Timer.wait_time = 0.5
		$Timer.one_shot = true
		$Timer.timeout.connect(_on_Timer_timeout)
	else:
		print("Erreur : Timer introuvable dans Area3D !")

	if $CollisionShape3D:
		body_entered.connect(_on_body_entered)
	else:
		print("Erreur : CollisionShape3D introuvable dans Area3D !")

func _on_body_entered(body):
	if body.name == "Player" and not player_detected:
		player_detected = true
		send_platform_data()
		if $Timer:
			$Timer.start()

func send_platform_data():
	if server_node and server_node.client != null and server_node.client.get_status() == StreamPeerTCP.STATUS_CONNECTED:
		var platform_data = determine_platform_position()
		server_node.client.put_utf8_string(platform_data + "\n")
		print("Données envoyées au serveur : %s" % platform_data)
	else:
		print("Erreur : Pas de client TCP connecté.")

func determine_platform_position() -> String:
	var platform_x = global_transform.origin.x
	if platform_x < -1:
		return "100"
	elif platform_x > 1:
		return "001"
	else:
		return "010"

func _on_Timer_timeout():
	if laser_scene:
		laser_instance = laser_scene.instantiate()
		get_parent().add_child(laser_instance)
		laser_instance.global_transform.origin = global_transform.origin + Vector3(0, 2, 0)
	else:
		print("Erreur : laser_scene non défini !")
