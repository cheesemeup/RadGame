# This script loads, unloads, shows and hides UI elements
extends Node

# playerframe
var playerframe
var playerframe_hp_x = 1130  # x position
var playerframe_hp_y = 735  # y position
var playerframe_hp_w = 220  # width
var playerframe_hp_h = 70  # height
var playerframe_res_x = 790  # x position
var playerframe_res_y = 735  # y position
var playerframe_res_w = 300  # width
var playerframe_res_h = 25  # height

# targetframe
var targetframe
var targetframe_hp_x = 1130  # x position
var targetframe_hp_y = 805  # y position
var targetframe_hp_w = 220  # width
var targetframe_hp_h = 60  # height
var targetframe_res_x = 1130  # x position
var targetframe_res_y = 865  # y position
var targetframe_res_w = 220  # width
var targetframe_res_h = 25  # height

# actionbars
var actionbars

# castbars
var castbar_player: ProgressBar
var castbar_player_x = 790
var castbar_player_y = 760
var castbar_player_width = 300
var castbar_player_height = 25

####################################################################################################
# INIT
func init_ui():
	References.player_ui_main_reference = $/root/main/ui
	init_unitframes()
	init_actionbars()
	init_castbars()

####################################################################################################
# MENUS
var main_menu: Node
func load_main_menu() -> void:
	var main_menu_scene = preload("res://main_menu/main_menu.tscn")
	main_menu = main_menu_scene.instantiate()
	add_child(main_menu)

func hide_main_menu() -> void:
	main_menu.hide()


####################################################################################################
# UNITFRAMES
func init_unitframes():
	initialize_playerframe()
	initialize_targetframe()


# PLAYERFRAME
func initialize_playerframe():
	playerframe = preload("res://scenes/ui/unitframe_player.tscn")
	playerframe = playerframe.instantiate()
	set_playerframe_position()
	References.player_ui_main_reference.add_child(playerframe)


func set_playerframe_position():
	playerframe.get_node("hpbar_value").size = Vector2(playerframe_hp_w,playerframe_hp_h)
	playerframe.get_node("hpbar_value").position = Vector2(playerframe_hp_x,playerframe_hp_y)
	playerframe.get_node("hpbar_value").get_node("unitname").size = Vector2(playerframe_hp_w,playerframe_hp_h)
	playerframe.get_node("hpbar_value").get_node("health").size = Vector2(playerframe_hp_w,playerframe_hp_h)
	playerframe.get_node("hpbar_value").get_node("healthpercent").size = Vector2(playerframe_hp_w,playerframe_hp_h)
	playerframe.get_node("resourcebar_value").size = Vector2(playerframe_res_w,playerframe_res_h)
	playerframe.get_node("resourcebar_value").position = Vector2(playerframe_res_x,playerframe_res_y)
	playerframe.get_node("resourcebar_value").get_node("resource").size = Vector2(playerframe_res_w,playerframe_res_h)
	playerframe.get_node("resourcebar_value").get_node("resourcepercent").size = Vector2(playerframe_res_w,playerframe_res_h)


# TARGEFRAME
func initialize_targetframe():
	# initially invisible targetframe
	targetframe = preload("res://scenes/ui/unitframe_target.tscn")
	targetframe = targetframe.instantiate()
	set_targetframe_position()
	References.player_ui_main_reference.add_child(targetframe)


func set_targetframe_position():
	targetframe.get_node("hpbar_value").size = Vector2(targetframe_hp_w,targetframe_hp_h)
	targetframe.get_node("hpbar_value").position = Vector2(targetframe_hp_x,targetframe_hp_y)
	targetframe.get_node("hpbar_value").get_node("unitname").size = Vector2(targetframe_hp_w,targetframe_hp_h)
	targetframe.get_node("hpbar_value").get_node("health").size = Vector2(targetframe_hp_w,targetframe_hp_h)
	targetframe.get_node("hpbar_value").get_node("healthpercent").size = Vector2(targetframe_hp_w,targetframe_hp_h)
	targetframe.get_node("resourcebar_value").size = Vector2(targetframe_res_w,targetframe_res_h)
	targetframe.get_node("resourcebar_value").position = Vector2(targetframe_res_x,targetframe_res_y)
	targetframe.get_node("resourcebar_value").get_node("resource").size = Vector2(targetframe_res_w,targetframe_res_h)
	targetframe.get_node("resourcebar_value").get_node("resourcepercent").size = Vector2(targetframe_res_w,targetframe_res_h)


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


####################################################################################################
# ACTIONBARS
func init_actionbars():
	actionbars = preload("res://scenes/ui/actionbars.tscn").instantiate()
	actionbars.initialize()
	References.player_ui_main_reference.add_child(actionbars)


####################################################################################################
# CASTBARS
func init_castbars() -> void:
	castbar_player = preload("res://scenes/ui/castbar.tscn").instantiate()
	castbar_player.position = Vector2(castbar_player_x,castbar_player_y)
	castbar_player.size = Vector2(castbar_player_width,castbar_player_height)
	References.player_ui_main_reference.add_child(castbar_player)


func toggle_castbar(visibility: bool):
	castbar_player.visible = visibility
	castbar_player.set_process(visibility)
