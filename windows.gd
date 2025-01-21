extends Node

func _ready():
	# Mettre la fenêtre principale en plein écran
	DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN)

	# Configurer une deuxième fenêtre en plein écran
	var window = $Window
	window.size = Vector2(1920, 1080)  # Taille de la deuxième fenêtre
	window.position = Vector2(3000, 0)  # Position sur le deuxième écran
	window.mode = Window.MODE_FULLSCREEN  # Activer le plein écran pour la deuxième fenêtre
	window.show()
