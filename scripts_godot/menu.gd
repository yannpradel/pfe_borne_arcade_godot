extends Control

signal _connected
signal _data_received
signal _disconnected
signal error

var client := StreamPeerTCP.new()
var server_ip := "127.0.0.1"
var server_port := 12345
var _status: int = 0

func _ready():
	connect_to_server()

func connect_to_server():
	print("Connexion au serveur %s:%d..." % [server_ip, server_port])
	_status = client.STATUS_NONE
	var err = client.connect_to_host(server_ip, server_port)
	if err != OK:
		print("Erreur de connexion au serveur : %s" % err)
		emit_signal("error")
	else:
		print("Tentative de connexion en cours...")

func _process(delta):
	client.poll()
	var new_status: int = client.get_status()
	if new_status != _status:
		_status = new_status
		match _status:
			client.STATUS_NONE:
				print("Déconnecté du serveur.")
				emit_signal("disconnected")
			client.STATUS_CONNECTING:
				print("Tentative de connexion au serveur...")
			client.STATUS_CONNECTED:
				print("Connexion au serveur réussie.")
				emit_signal("connected")
			client.STATUS_ERROR:
				print("Erreur de connexion au serveur.")
				emit_signal("error")
	
	if _status == client.STATUS_CONNECTED and client.get_available_bytes() > 0:
		var buffer = client.get_string(client.get_available_bytes()).strip_edges()
		emit_signal("data_received", buffer)
		handle_menu_navigation(buffer)

func handle_menu_navigation(direction):
	var current_scene = get_tree().current_scene.name.to_lower()
	var valid_menus = ["game_over", "menu", "you_win"]
	if current_scene in valid_menus:
		print("🎮 Navigation dans le menu :", direction)
		var focused = get_viewport().gui_get_focus_owner()
		if not focused or not focused is Button:
			var first_button = find_first_button()
			if first_button:
				first_button.grab_focus()
		else:
			if direction == "up":
				focused.next_focus_prefer_wrap = false
				focused.release_focus()
				Input.action_press("ui_up")
				await get_tree().create_timer(0.1).timeout
				Input.action_release("ui_up")
			elif direction == "down":
				focused.next_focus_prefer_wrap = false
				focused.release_focus()
				Input.action_press("ui_down")
				await get_tree().create_timer(0.1).timeout
				Input.action_release("ui_down")

func find_first_button():
	for child in get_tree().current_scene.get_children():
		if child is Button:
			return child
	return null

func _on_quit_pressed() -> void:
	get_tree().quit()

func _on_play_pressed() -> void:
	print("launching game...")
	get_tree().change_scene_to_file("res://tscn_godot/Main.tscn")

func _on_menu_pressed() -> void:
	get_tree().change_scene_to_file("res://tscn_godot/menu.tscn")
