extends Node

func _on_restart_map_button_pressed() -> void:
	Serverscript.map_swap(References.current_map_name)
	UIHandler.close_ingame_menu()
