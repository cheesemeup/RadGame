extends Control


# Called when the node enters the scene tree for the first time.
func _ready():
	# player frame
	var player_hpbar = Autoload.player_ui_main_reference.get_node("ui_persistent").get_node("playerframe").get_node("playerframe_hpbar")
	$"interface_menu_tabs/Single Frames/player_values/playerframe_hp_width_entry".text = str(player_hpbar.size.x)
	$"interface_menu_tabs/Single Frames/player_values/playerframe_hp_height_entry".text = str(player_hpbar.size.y)
	$"interface_menu_tabs/Single Frames/player_values/playerframe_hp_h_position_entry".text = str(player_hpbar.position.x)
	$"interface_menu_tabs/Single Frames/player_values/playerframe_hp_v_position_entry".text = str(player_hpbar.position.y)
	add_item_showhide($"interface_menu_tabs/Single Frames/player_dropdowns/playerframe_hp_showtoggle")
	add_item_orientation($"interface_menu_tabs/Single Frames/player_dropdowns/playerframe_hp_orientation_entry")
	$"interface_menu_tabs/Single Frames/player_dropdowns/playerframe_hp_showtoggle".selected = player_hpbar.visible
	$"interface_menu_tabs/Single Frames/player_dropdowns/playerframe_hp_orientation_entry".selected = player_hpbar.fill_mode
	var player_resbar = Autoload.player_ui_main_reference.get_node("ui_persistent").get_node("playerframe").get_node("playerframe_resbar")
	$"interface_menu_tabs/Single Frames/player_values/playerframe_res_width_entry".text = str(player_resbar.size.x)
	$"interface_menu_tabs/Single Frames/player_values/playerframe_res_height_entry".text = str(player_resbar.size.y)
	$"interface_menu_tabs/Single Frames/player_values/playerframe_res_h_position_entry".text = str(player_resbar.position.x)
	$"interface_menu_tabs/Single Frames/player_values/playerframe_res_v_position_entry".text = str(player_resbar.position.y)
	add_item_showhide($"interface_menu_tabs/Single Frames/player_dropdowns/playerframe_res_showtoggle")
	add_item_orientation($"interface_menu_tabs/Single Frames/player_dropdowns/playerframe_res_orientation_entry")
	$"interface_menu_tabs/Single Frames/player_dropdowns/playerframe_res_showtoggle".selected = player_resbar.visible
	$"interface_menu_tabs/Single Frames/player_dropdowns/playerframe_res_orientation_entry".selected = player_resbar.fill_mode

func _on_interface_menu_apply_pressed():
	var player_hpbar = Autoload.player_ui_main_reference.get_node("ui_persistent").get_node("playerframe").get_node("playerframe_hpbar")
	var player_resbar = Autoload.player_ui_main_reference.get_node("ui_persistent").get_node("playerframe").get_node("playerframe_resbar")
	# validity of single frame values
	var apply_validity = apply_int_check($"interface_menu_tabs/Single Frames/player_values")
	if not apply_validity:
		return
	player_hpbar.size.x = int($"interface_menu_tabs/Single Frames/player_values/playerframe_hp_width_entry".text)
	player_hpbar.size.y = int($"interface_menu_tabs/Single Frames/player_values/playerframe_hp_height_entry".text)
	player_hpbar.position.x = int($"interface_menu_tabs/Single Frames/player_values/playerframe_hp_h_position_entry".text)
	player_hpbar.position.y = int($"interface_menu_tabs/Single Frames/player_values/playerframe_hp_v_position_entry".text)
	player_hpbar.fill_mode = $"interface_menu_tabs/Single Frames/player_dropdowns/playerframe_hp_orientation_entry".selected
	player_hpbar.visible = $"interface_menu_tabs/Single Frames/player_dropdowns/playerframe_hp_showtoggle".selected
	Autoload.player_ui_main_reference.get_node("ui_persistent").get_node("playerframe").get_node("playerframe_playername").visible = \
		$"interface_menu_tabs/Single Frames/player_dropdowns/playerframe_hp_showtoggle".selected
	Autoload.player_ui_main_reference.get_node("ui_persistent").get_node("playerframe").get_node("playerframe_hpvalue").visible = \
		$"interface_menu_tabs/Single Frames/player_dropdowns/playerframe_hp_showtoggle".selected
	player_resbar.size.x = int($"interface_menu_tabs/Single Frames/player_values/playerframe_res_width_entry".text)
	player_resbar.size.y = int($"interface_menu_tabs/Single Frames/player_values/playerframe_res_height_entry".text)
	player_resbar.position.x = int($"interface_menu_tabs/Single Frames/player_values/playerframe_res_h_position_entry".text)
	player_resbar.position.y = int($"interface_menu_tabs/Single Frames/player_values/playerframe_res_v_position_entry".text)
	player_resbar.fill_mode = $"interface_menu_tabs/Single Frames/player_dropdowns/playerframe_res_orientation_entry".selected
	player_resbar.visible = $"interface_menu_tabs/Single Frames/player_dropdowns/playerframe_res_showtoggle".selected
	Autoload.player_ui_main_reference.get_node("ui_persistent").playerframe_initialize()

func apply_int_check(value_node):
	for child in value_node.get_children():
		var text = child.text
		if ! text.is_valid_int():
			print("ERROR: invalid integer!")
			return false
		# also check if int is positive, because interface elements can't have negative size
		if int(text) < 0:
			print("ERROR: integer cannot be negative!")
			return false
	return true

func add_item_showhide(node):
	node.add_item("Hide")
	node.add_item("Show")

func add_item_orientation(node):
	node.add_item("L to R")
	node.add_item("R to L")
	node.add_item("T to B")
	node.add_item("B to T")
