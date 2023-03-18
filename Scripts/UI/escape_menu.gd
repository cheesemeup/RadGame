extends Control

##############################################################################################################################
# exiting the game via esc menu
func _on_button_exit_game_pressed():
	var exit_game_countdown = load("res://Scenes/UI/exit_game_countdown.tscn")
	exit_game_countdown = exit_game_countdown.instantiate()
	Autoload.player_ui_main_reference.add_child(exit_game_countdown)

