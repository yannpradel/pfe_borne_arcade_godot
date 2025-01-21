extends Area3D

func _ready():
	# Connexion du signal `body_entered`
	connect("body_entered", self._on_body_entered)
	
func _on_body_entered(body: Node3D) -> void:
	# Vérifie si l'objet détecté est le joueur
	if body.name == "Player":
		print("PERTE DE VIE : Le joueur est entré dans la zone !")
		body.lose_life()  # Appelle la méthode lose_life() du joueur
