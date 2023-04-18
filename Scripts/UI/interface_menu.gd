extends Control


# Called when the node enters the scene tree for the first time.
func _ready():
	# player frame
	var playerframe = Autoload.player_ui_main_reference.get_node("ui_persistent").get_node("playerframe").get_node("playerframe_hpbar")
	$"interface_menu_tabs/Single Frames/values/playerframe_hp_width_entry".text = str(playerframe.size.x)
	$"interface_menu_tabs/Single Frames/values/playerframe_hp_height_entry".text = str(playerframe.size.y)
	$"interface_menu_tabs/Single Frames/values/playerframe_hp_h_position_entry".text = str(playerframe.position.x)
	$"interface_menu_tabs/Single Frames/values/playerframe_hp_v_position_entry".text = str(playerframe.position.y)
	$"interface_menu_tabs/Single Frames/dropdowns/playerframe_hp_showtoggle".add_item("Show")
	$"interface_menu_tabs/Single Frames/dropdowns/playerframe_hp_showtoggle".add_item("Hide")
	$"interface_menu_tabs/Single Frames/dropdowns/playerframe_hp_orientation_entry".add_item("L to R")
	$"interface_menu_tabs/Single Frames/dropdowns/playerframe_hp_orientation_entry".add_item("R to L")
	$"interface_menu_tabs/Single Frames/dropdowns/playerframe_hp_orientation_entry".add_item("T to B")
	$"interface_menu_tabs/Single Frames/dropdowns/playerframe_hp_orientation_entry".add_item("B to T")


func _on_interface_menu_apply_pressed():
	var playerframe = Autoload.player_ui_main_reference.get_node("ui_persistent").get_node("playerframe").get_node("playerframe_hpbar")
	var apply_validity = apply_int_check(get_node("interface_menu_tabs").get_node("Single Frames").get_node("values"))
	# return if not all values are convertable to int
	if not apply_validity:
		return
	playerframe.size.x = int($"interface_menu_tabs/Single Frames/values/playerframe_hp_width_entry".text)
	playerframe.size.y = int($"interface_menu_tabs/Single Frames/values/playerframe_hp_height_entry".text)
	playerframe.position.x = int($"interface_menu_tabs/Single Frames/values/playerframe_hp_h_position_entry".text)
	playerframe.position.y = int($"interface_menu_tabs/Single Frames/values/playerframe_hp_v_position_entry".text)
	playerframe.fill_mode = $"interface_menu_tabs/Single Frames/dropdowns/playerframe_hp_orientation_entry".selected

func apply_int_check(value_node):
	for child in value_node.get_children():
		var text = child.text
		if ! text.is_valid_int():
			print("ERROR: invalid integer!")
			return false
	return true
