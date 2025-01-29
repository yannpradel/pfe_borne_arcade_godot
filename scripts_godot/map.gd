extends Node3D

# Chemins vers les plateformes
@export var cage1: NodePath
@export var cage2: NodePath
@export var cage3: NodePath
@export var cage4: NodePath

# Vitesse initiale de chute
@export var initial_fall_speed: float = 5.0  # Vitesse initiale sur l'axe Y
@export var max_fall_speed: float = 100.0  # Vitesse maximale de chute
@export var session_duration: float = 60.0  # Durée de la session en secondes

# Variables locales
var local_triggered: bool = false
var elapsed_time: float = 0.0  # Temps écoulé depuis le début de la session
var fall_speed: float = initial_fall_speed  # Vitesse de chute actuelle
var is_falling: bool = false  # Indique si une plateforme est en train de tomber
var current_cage: NodePath = NodePath()  # La plateforme actuellement en chute (initialisée vide)

# Sauvegarde des positions initiales
var initial_positions: Dictionary = {}

# Liste des plateformes
var cages: Array = []

func _ready():
	# Sauvegarde les positions initiales des cages
	cages = [cage1, cage2, cage3, cage4]
	for cage_path in cages:
		var cage = get_node(cage_path)
		if cage:
			initial_positions[cage_path] = cage.global_transform.origin

func _process(delta):
	# Si `Global.triggered` est activé, commence la session
	if Global.triggered and not local_triggered:
		local_triggered = true
		print("Session commencée : plateformes en chute")

	# Si la session est en cours
	if local_triggered:
		elapsed_time += delta
		fall_speed = lerp(initial_fall_speed, max_fall_speed, elapsed_time / session_duration)  # Augmente la vitesse progressivement

		# Si aucune plateforme ne tombe, en choisir une aléatoirement
		if not is_falling:
			start_fall()

		# Faire tomber la plateforme actuelle
		if is_falling and current_cage != NodePath():
			var cage = get_node(current_cage)
			if cage:
				var new_position = cage.global_transform.origin
				new_position.y -= fall_speed * delta  # Déplacer vers le bas
				cage.global_transform.origin = new_position

				# Vérifier si la plateforme est tombée en dessous d'un seuil
				if new_position.y < -100:  # Seuil arbitraire pour la "fin de la chute"
					reset_platform(current_cage)
					is_falling = false  # Permet de choisir une nouvelle plateforme

		# Fin de la session
		if elapsed_time >= session_duration:
			reset_all_platforms()
			Global.triggered = false
			local_triggered = false
			elapsed_time = 0.0  # Réinitialiser le temps écoulé
			fall_speed = initial_fall_speed
			print("Session terminée : plateformes réinitialisées")

func start_fall():
	# Choisir une plateforme aléatoirement
	current_cage = cages[randi() % cages.size()]
	print("Nouvelle plateforme sélectionnée : ", current_cage)
	is_falling = true

func reset_platform(cage_path: NodePath):
	# Réinitialiser une plateforme à sa position initiale
	var cage = get_node(cage_path)
	if cage and cage_path in initial_positions:
		cage.global_transform.origin = initial_positions[cage_path]
		print("Plateforme réinitialisée : ", cage_path)

func reset_all_platforms():
	# Réinitialiser toutes les plateformes
	for cage_path in initial_positions.keys():
		reset_platform(cage_path)
	print("Toutes les plateformes ont été réinitialisées")
