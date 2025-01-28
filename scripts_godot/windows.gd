extends Node

func _ready():
	# Mettre la fenêtre principale en plein écran
	DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)
	
	# Afficher les tailles des écrans pour débogage
	print("Taille de l'écran principal :", DisplayServer.screen_get_size(0))
	print("Taille du deuxième écran :", DisplayServer.screen_get_size(1))
	
	# Configurer une deuxième fenêtre en plein écran
	var window = $Window
	window.name = "Barnaby"
	window.size = Vector2(1920, 1080)  # Taille de la deuxième fenêtre
	window.mode = Window.MODE_WINDOWED  # Activer le plein écran pour la deuxième fenêtre
	window.set_current_screen(0)
	
	# Positionner la fenêtre à une position fixe (exemple : X=0, Y=-1080)
	window.set_position(Vector2(1920, 0))
	
	# Afficher la fenêtre
	window.show()
