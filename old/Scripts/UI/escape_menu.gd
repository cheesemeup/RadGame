extends Control

# close esc menu via Continue
func _on_button_continue_pressed():
	Autoload.player_ui_main_reference.get_node("escape_menu_root").queue_free()

# progress
func _on_button_progress_pressed():
	var progress_menu = load("res://Scenes/UI/progress_menu.tscn")
	progress_menu = progress_menu.instantiate()
	Autoload.player_ui_main_reference.add_child(progress_menu)
	Autoload.player_ui_main_reference.get_node("escape_menu_root").queue_free()

# interface
func _on_button_interface_pressed():
	var interface_menu = load("res://Scenes/UI/interface_menu.tscn")
	interface_menu = interface_menu.instantiate()
	Autoload.player_ui_main_reference.add_child(interface_menu)
	Autoload.player_ui_main_reference.get_node("escape_menu_root").queue_free()

# keybindings

# exiting the game via esc menu
func _on_button_exit_game_pressed():
	var exit_game_countdown = load("res://Scenes/UI/exit_game_countdown.tscn")
	exit_game_countdown = exit_game_countdown.instantiate()
	Autoload.player_ui_main_reference.add_child(exit_game_countdown)
 
