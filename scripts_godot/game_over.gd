extends Control

@onready var client_node := $"../ClientNode"
var timer : Timer

func _ready():
	client_node = get_tree().get_root().get_node("Main/ClientNode")
	# Création et configuration du Timer
	timer = Timer.new()
	timer.wait_time = 5.0
	timer.one_shot = true
	timer.connect("timeout", Callable(self, "_on_timer_timeout"))
	add_child(timer)
	timer.start()

func _on_timer_timeout():
	if client_node and client_node.is_connected:
		client_node.send_data("MinusLife\n")
	else:
		print("Erreur : Impossible de trouver le nœud ClientNode ou non connecté.")

# Fonction appelée lorsque le bouton "Restart" est pressé
func _on_restart_button_pressed():
	# Recharge la scène principale
	get_tree().change_scene_to_file("res://tscn_godot/Main.tscn")

# Fonction appelée lorsque le bouton "Quit" est pressé
func _on_quit_button_pressed():
	# Quitte le jeu
	get_tree().quit()
