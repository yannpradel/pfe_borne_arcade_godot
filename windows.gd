extends Node

func _ready():
	# Référence absolue pour accéder au nœud "Window"
	var window = $Window
	var window2 = $Window2

	# Positionner la première fenêtre
	window.position = Vector2(0, 0)  # Position sur le premier écran
	window.size = Vector2(1920, 1080)  # Taille de la fenêtre
	window.show()

	# Positionner la deuxième fenêtre
	window2.position = Vector2(0, 0)  # Position sur le second écran
	window2.size = Vector2(1920, 1080)  # Taille de la fenêtre
	window2.show()
