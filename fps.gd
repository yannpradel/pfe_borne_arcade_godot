extends Node

@onready var fps_label = $FPSLabel  # Assurez-vous que le chemin soit correct

func _process(delta):
	# Calcule et affiche les FPS
	fps_label.text = "FPS: " + str(Engine.get_frames_per_second())
