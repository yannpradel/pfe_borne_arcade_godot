extends Node

func _ready():
	# Mettre la fenêtre principale en plein écran
	DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN)
	
	# Afficher les tailles des écrans pour débogage
	print("Taille de l'écran principal :", DisplayServer.screen_get_size(0))
	print("Taille du deuxième écran :", DisplayServer.screen_get_size(1))
	
	# Crée la première fenêtre sur l'écran 0
	var window = Window.new()
	window.title = "Fenêtre 1"
	window.size = Vector2(1366, 768)  # Taille de la fenêtre
	window.position = DisplayServer.screen_get_position(0)  # Coin supérieur gauche de l'écran 0
	window.current_screen = 1  # Affiche sur l'écran 0
	window.fullscreen = true
	window.show()

	
