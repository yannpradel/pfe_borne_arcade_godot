extends Control

# Fonction appelée lorsque le bouton "Restart" est pressé
func _on_restart_button_pressed():
	# Recharge la scène principale (modifie le chemin selon ton projet)
	get_tree().change_scene_to_file("res://scenes/Main.tscn")


# Fonction appelée lorsque le bouton "Quit" est pressé
func _on_quit_button_pressed():
	# Quitte le jeu
	get_tree().quit()
