extends Control

var esc_menu_preload = preload("res://Scenes/UI/escape_menu.tscn")

##############################################################################################################################

func _ready():
	Autoload.player_ui_main_reference = self

func esc_menu():
	if get_node_or_null("escape_menu_root"):
		$escape_menu_root.queue_free()
	elif get_node_or_null("exit_game_countdown"):
		$exit_game_countdown._on_cancel_pressed()
	else:
		var escape_menu = esc_menu_preload.instantiate()
		Autoload.esc_menu_reference = escape_menu
		add_child(escape_menu)
