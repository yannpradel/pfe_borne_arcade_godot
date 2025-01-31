extends Control

var client := StreamPeerTCP.new()
var server_ip := "127.0.0.1"
var server_port := 12345

func _ready():
	connect_to_server()

func connect_to_server():
	print("Connexion au serveur %s:%d..." % [server_ip, server_port])
	var err = client.connect_to_host(server_ip, server_port)
	if err != OK:
		print("Erreur de connexion au serveur : %s" % err)
	else:
		print("Tentative de connexion en cours...")

func _on_quit_pressed() -> void:
	get_tree().quit()

func _on_play_pressed() -> void:
	print("launching game...")
	get_tree().change_scene_to_file("res://tscn_godot/Main.tscn")

func _on_menu_pressed() -> void:
	get_tree().change_scene_to_file("res://tscn_godot/menu.tscn")

# Vérifier si le client TCP est actif et recevoir les commandes
func _process(delta):
	client.poll()
	if client.get_status() == client.STATUS_CONNECTED:
		if client.get_available_bytes() > 0:
			var buffer = client.get_string(client.get_available_bytes()).strip_edges()
			if buffer in ["up", "down"]:
				handle_menu_navigation(buffer)
	else:
		print("Client non connecté.")

func handle_menu_navigation(direction):
	var current_scene = get_tree().current_scene.name.to_lower()
	var valid_menus = ["game_over", "menu", "you_win"]
	if current_scene in valid_menus:
		print("🎮 Navigation dans le menu :", direction)
		if direction == "up":
			Input.action_press("ui_up")
			await get_tree().create_timer(0.1).timeout
			Input.action_release("ui_up")
		elif direction == "down":
			Input.action_press("ui_down")
			await get_tree().create_timer(0.1).timeout
			Input.action_release("ui_down")
