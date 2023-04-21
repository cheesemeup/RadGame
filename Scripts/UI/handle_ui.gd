extends Control

# target frame vars
var targetframe_hp_size_x = 250
var targetframe_hp_size_y = 80
var targetframe_hp_position_x = 0
var targetframe_hp_position_y = 0
var targetframe_updateflag = false

var esc_menu_preload = preload("res://Scenes/UI/escape_menu.tscn")
var targetframe_preload = preload("res://Scenes/UI/targetframe.tscn")

##############################################################################################################################

func _ready():
	Autoload.player_ui_main_reference = self

func esc_menu():
	if get_node_or_null("escape_menu_root"):
		$escape_menu_root.queue_free()
	elif get_node_or_null("exit_game_countdown"):
		$exit_game_countdown._on_cancel_pressed()
	elif get_node_or_null("progress_menu"):
		$progress_menu.queue_free()
	elif get_node_or_null("interface_menu"):
		$interface_menu.queue_free()
	else:
		var escape_menu = esc_menu_preload.instantiate()
		Autoload.esc_menu_reference = escape_menu
		add_child(escape_menu)

func load_persistent():
	var ui_persistent_load = load("res://Scenes/UI/ui_persistent.tscn")
	var ui_persistent = ui_persistent_load.instantiate()
	$/root/main/ui.add_child(ui_persistent)

func targetframe_initialize(ID):
	# create new targetframe if there is no targetframe
	if not get_node_or_null("targetframe"):
		var targetframe = targetframe_preload
		targetframe = targetframe.instantiate()
		add_child(targetframe)
		targetframe_updateflag = true
	# update targetframe if it already exists
	else:
		pass

func targetframe_remove():
	print("remove")
	if not get_node_or_null("targetframe"):
		print(get_children())
		return
	targetframe_updateflag = false
	get_node("targetframe").queue_free()
