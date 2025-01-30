extends Node3D

@export var spawn_area: Vector2 = Vector2(10, 10) # Zone de spawn
@export var fall_height: float = 20.0  # Hauteur de spawn des météorites
var shadow_texture
@export var shadow_scale_factor: float = 1.0  # Facteur d'échelle de l'ombre

var meteors = []
var player: CharacterBody3D  # Référence au joueur
var is_spawning = false  # Flag pour gérer l'état du spawner

func _ready():
	player = get_tree().get_root().get_node("Main/Player")
	if player != null:
		print("Player détecté :", player.name)
	# Les spawns commenceront uniquement dans une zone spécifique

func start_spawning():
	if is_spawning:
		return

	is_spawning = true
	var timer = Timer.new()
	timer.wait_time = 2.0  # Fréquence d'apparition
	timer.autostart = true
	timer.timeout.connect(spawn_meteor)
	add_child(timer)

func stop_spawning():
	if not is_spawning:
		return

	is_spawning = false
	for child in get_children():
		if child is Timer:
			child.queue_free()  # Supprime tous les timers en cours

func spawn_meteor():
	if player == null or not is_spawning:
		return

	shadow_texture = load("res://assets - blender/textures/ombre.png")
	var meteor_scene = load("res://tscn_godot/meteor_scene.tscn")
	if meteor_scene == null:
		return

	var meteor = meteor_scene.instantiate() as RigidBody3D
	if meteor == null:
		return

	# Position de spawn aléatoire autour du joueur avec un offset sur l'axe Z
	var player_position = player.global_position
	var spawn_x = player_position.x + randf_range(-spawn_area.x, spawn_area.x)
	var spawn_z = player_position.z + randf_range(-spawn_area.y, spawn_area.y) + 15
	meteor.global_position = Vector3(spawn_x, fall_height, spawn_z)

	# Créer et configurer l'ombre
	var shadow = create_shadow()
	shadow.global_position = Vector3(spawn_x, 0.1, spawn_z)  # Position au sol
	add_child(shadow)  # Ajouter l'ombre à la scène principale

	# Lier l'ombre à la météorite
	add_child(meteor)

	# Stocker l'ombre et la météorite pour mise à jour
	meteors.append({ "meteor": meteor, "shadow": shadow })

func create_shadow() -> MeshInstance3D:
	var shadow = MeshInstance3D.new()
	shadow.mesh = PlaneMesh.new()
	shadow.mesh.size = Vector2(8, 8)  # Taille initiale de l'ombre

	var material = StandardMaterial3D.new()
	material.albedo_texture = shadow_texture  # Assigne la texture d'ombre
	material.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA  # Active la transparence alpha
	material.use_alpha_scissor = true  # Permet de découper en fonction de l'alpha
	material.alpha_scissor_threshold = 0.1  # Ajuste la sensibilité de l'alpha
	shadow.material_override = material

	return shadow

func _process(delta):
	# Met à jour les ombres et supprime celles des météorites tombées
	for entry in meteors:
		var meteor = entry["meteor"]
		var shadow = entry["shadow"]

		if meteor == null or shadow == null:
			continue

		var meteor_position = meteor.global_position
		shadow.global_position.x = meteor_position.x
		shadow.global_position.z = meteor_position.z

		# Mise à l'échelle de l'ombre en fonction de la hauteur
		var scale = shadow_scale_factor * max(0.5, 1.0 - (meteor_position.y / fall_height))
		shadow.scale = Vector3(scale, 1, scale)

		# Supprimer l'ombre quand la météorite touche le sol
		if meteor_position.y <= 0:
			print("Suppression de l'ombre")
			shadow.queue_free()
			meteors.erase(entry)

func _on_Area3D_body_entered(body):
	if body == player:
		print("Player est entré dans l'Area3D. Spawning activé.")
		start_spawning()

func _on_Area3D_body_exited(body):
	if body == player:
		print("Player a quitté l'Area3D. Spawning désactivé.")
		stop_spawning()
