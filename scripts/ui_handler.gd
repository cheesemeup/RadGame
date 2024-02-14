# This script loads, unloads, shows and hides UI elements
extends Node

# targetframe
var targetframe
var targetframe_hp_x = 1080  # x position
var targetframe_hp_y = 795  # y position
var targetframe_hp_w = 220  # width
var targetframe_hp_h = 60  # height
var targetframe_res_x = 1080  # x position
var targetframe_res_y = 855  # y position
var targetframe_res_w = 220  # width
var targetframe_res_h = 25  # height

####################################################################################################
# MENUS
func load_mainmenu():
	var mainmenu = preload("res://scenes/ui/mainmenu.tscn")
	mainmenu = mainmenu.instantiate()
	add_child(mainmenu)

####################################################################################################
# UNITFRAMES
func load_unitframes():
	initialize_targetframe()

# TARGEFRAME
func initialize_targetframe():
	# initially invisible targetframe
	targetframe = preload("res://scenes/ui/unitframe_target.tscn")
	targetframe = targetframe.instantiate()
	set_targetframe_position()
	$"/root/main/ui".add_child(targetframe)
func set_targetframe_position():
	# positioning
	targetframe.get_node("hpbar_value").size = Vector2(targetframe_hp_w,targetframe_hp_h)
	targetframe.get_node("hpbar_value").position = Vector2(targetframe_hp_x,targetframe_hp_y)
	targetframe.get_node("hpbar_value").get_node("unitname").size = Vector2(targetframe_hp_w/2,targetframe_hp_h)
	targetframe.get_node("hpbar_value").get_node("health").size = Vector2(targetframe_hp_w/2,targetframe_hp_h)
	targetframe.get_node("hpbar_value").get_node("health").position.x = targetframe.get_node("hpbar_value").position.x + targetframe.get_node("hpbar_value").size.x/2
	targetframe.get_node("resourcebar_value").size = Vector2(targetframe_res_w,targetframe_res_h)
	targetframe.get_node("resourcebar_value").position = Vector2(targetframe_res_x,targetframe_res_y)
	
	
func show_targetframe():
	# set name
	targetframe.get_node("hpbar_value").get_node("unitname").text = targetframe.target_reference.stats_current["unit_name"]
	targetframe.visible = true
	# enable processing health and resource information
	targetframe.set_process(true)
func hide_targetframe():
	# unset name
	targetframe.get_node("hpbar_value").get_node("unitname").text = ""
	# disable processing health and resource information
	targetframe.set_process(false)
	targetframe.visible = false
