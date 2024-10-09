extends Node

func _on_restart_map_button_pressed() -> void:
	restart_map()

func _on_toggle_collision_shapes_button_pressed() -> void:
	get_tree().debug_collisions_hint = !get_tree().debug_collisions_hint
	restart_map()

func restart_map() -> void:
	Serverscript.map_swap(References.current_map_name)
	UIHandler.close_ingame_menu()
