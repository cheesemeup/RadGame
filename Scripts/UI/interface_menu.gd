extends Control


# Called when the node enters the scene tree for the first time.
func _ready():
	# player frame
	var playerframe = Autoload.player_ui_main_reference.get_node("ui_persistent").get_node("playerframe").get_node("playerframe_hpbar")
	$"interface_menu_tabs/Single Frames/playerframe_width_entry".text = str(playerframe.size.x)
	$"interface_menu_tabs/Single Frames/playerframe_height_entry".text = str(playerframe.size.y)
	$"interface_menu_tabs/Single Frames/playerframe_h_position_entry".text = str(playerframe.position.x)
	$"interface_menu_tabs/Single Frames/playerframe_v_position_entry".text = str(playerframe.position.y)
	print(Autoload.player_ui_main_reference.get_children())
	print(Autoload.player_ui_main_reference.get_child(0))
	print(Autoload.player_ui_main_reference.get_node("ui_persistent").get_node("playerframe").get_node("playerframe_hpbar").size.x)
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
