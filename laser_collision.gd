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
		body_exited.connect(_on_body_exited)
	else:
		print("Erreur : CollisionShape3D introuvable dans Area3D !")

func _on_body_entered(body):
	if body.name == "Player" and not player_detected:
		player_detected = true
		send_laser_command("LASER_ON")  # Allume le laser
		if $Timer:
			$Timer.start()

func _on_body_exited(body):
	if body.name == "Player" and player_detected:
		player_detected = false
		send_laser_command("LASER_OFF")  # Éteint le laser

func send_laser_command(command: String):
	if server_node and server_node.client != null and server_node.client.get_status() == StreamPeerTCP.STATUS_CONNECTED:
		server_node.client.put_utf8_string(command + "\n")
		print("Commande laser envoyée au serveur : %s" % command)
	else:
		print("Erreur : Pas de client TCP connecté pour envoyer la commande laser.")

func _on_Timer_timeout():
	if laser_scene:
		laser_instance = laser_scene.instantiate()
		get_parent().add_child(laser_instance)
		laser_instance.global_transform.origin = global_transform.origin + Vector3(0, 2, 0)
	else:
		print("Erreur : laser_scene non défini !")
