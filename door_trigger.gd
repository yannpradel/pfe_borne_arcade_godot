extends Area3D

# Récupère le nœud AnimationPlayer
@onready var animation_player: AnimationPlayer = $DoorAnimationPlayer

func _ready():
	# Connexion du signal `body_entered`
	connect("body_entered", self._on_door_trigger_body_entered)
	
	# Vérifie si l'AnimationPlayer est bien trouvé
	if animation_player == null:
		print("Erreur : AnimationPlayer introuvable.")
	else:
		print("Succès : AnimationPlayer trouvé.")

func _on_door_trigger_body_entered(body: Node3D) -> void:
	# Vérifie si l'objet détecté est le joueur
	if body.name == "Player":
		print("Le joueur est entré dans la zone !")
		open_door()

# Fonction pour jouer l'animation d'ouverture de la porte
func open_door():
	print("Avant lancement de l'animation")
	if animation_player:
		print("Lancement de l'animation 'close_door'")
		animation_player.play("new_animation")
	else:
		print("Erreur : AnimationPlayer non défini !")
