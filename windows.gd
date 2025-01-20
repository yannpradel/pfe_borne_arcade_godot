extends Node

func _ready():
	# Positionner la première fenêtre
	$Window.position = Vector2(100, 100)  # Position de la première fenêtre
	$Window.show()  # Afficher la fenêtre 1

	# Positionner la deuxième fenêtre
	$Window2.position = Vector2(800, 100)  # Position de la deuxième fenêtre
	$Window2.show()  # Afficher la fenêtre 2
