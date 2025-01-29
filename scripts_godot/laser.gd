extends Area3D

var laser_active = false  # Pour savoir si le laser est actif

func _ready():
	laser_active = true
	connect("body_entered", Callable(self, "_on_body_entered"))  # 📌 Détecte automatiquement les objets entrants
	print("🚀 Laser activé, détecte les collisions !")

func _on_body_entered(body):
	print("🚀 Collision détectée avec :", body.name, "(", body.get_class(), ")")

	if body.is_in_group("player"):  # 📌 Vérifie si c'est bien un joueur
		print("🎯 Le joueur est touché !")
		body.lose_life()  # 📌 Applique les dégâts au joueur
	else:
		print("⚠️ Collision ignorée :", body.name)

func _remove_laser():
	laser_active = false
	queue_free()  # Supprime le laser proprement
