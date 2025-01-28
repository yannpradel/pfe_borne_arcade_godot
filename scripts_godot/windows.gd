extends Node

func _ready():
	# Mettre la fenêtre principale en mode fenêtré
	DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)
	
	# Afficher les tailles des écrans pour débogage
	print("Taille de l'écran principal :", DisplayServer.screen_get_size(0))
	print("Taille du deuxième écran :", DisplayServer.screen_get_size(1))
	
	# Configurer une deuxième fenêtre
	var window = $Window
	window.name = "Barnaby"
	window.size = Vector2(1920, 1080)  # Taille de la deuxième fenêtre
	window.mode = Window.MODE_WINDOWED  # Activer le mode fenêtré pour la deuxième fenêtre
	
	# Positionner la fenêtre sur le deuxième écran (par exemple, à droite du premier écran)
	var second_screen_position = DisplayServer.screen_get_position(1)
	print("Position du deuxième écran :", second_screen_position)
	
	window.set_position(second_screen_position)  # Déplacer la fenêtre au début du deuxième écran
	
	# Afficher la fenêtre
	window.show()
