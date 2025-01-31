extends Control

func _on_quit_pressed() -> void:
	get_tree().quit()


func _on_play_pressed() -> void:
	print("launching game...")
	get_tree().change_scene_to_file("res://tscn_godot/Main.tscn")
	
func _on_menu_pressed() ->void:
	get_tree().change_scene_to_file("res://tscn_godot/menu.tscn")
