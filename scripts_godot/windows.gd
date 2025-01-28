extends Node

func _ready():
	print("Nombre d'écrans détectés :", DisplayServer.get_screen_count())

	# Crée une fenêtre pour le premier écran
	var window1 = Window.new()
	window1.title = "Fenêtre 1"
	window1.size = Vector2(800, 600)
	window1.position = DisplayServer.screen_get_position(0)  # Place sur l'écran 1
	window1.current_screen = 0
	window1.set_exclusive(true)  # Force la séparation
	add_child(window1)
	window1.show()

	# Crée une fenêtre pour le deuxième écran
	if DisplayServer.get_screen_count() > 1:  # Vérifie s'il y a bien 2 écrans
		var window2 = Window.new()
		window2.title = "Fenêtre 2"
		window2.size = Vector2(800, 600)
		window2.position = DisplayServer.screen_get_position(1)  # Place sur l'écran 2
		window2.current_screen = 1
		window2.set_exclusive(true)
		add_child(window2)
		window2.show()
	else:
		print("⚠️ Un seul écran détecté. Impossible d'afficher la deuxième fenêtre.")
