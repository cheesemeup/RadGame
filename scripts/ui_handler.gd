# This script loads, unloads, shows and hides UI elements
extends Node

var targetframe

####################################################################################################
# MENUS
func load_mainmenu():
	var mainmenu = preload("res://scenes/ui/mainmenu.tscn")
	mainmenu = mainmenu.instantiate()
	add_child(mainmenu)

####################################################################################################
# UNITFRAMES
func load_unitframes():
	# initially invisible targetframe
	targetframe = preload("res://scenes/ui/unitframe_target.tscn")
	targetframe = targetframe.instantiate()
	$"/main/ui".add_child(targetframe)
	print("targetframe loaded")

# TARGEFRAME
func show_targetframe():
	targetframe.visible = true
	# enable processing health and resource information
	targetframe.set_process(true)
func hide_targetframae():
	# disable processing health and resource information
	targetframe.set_process(false)
	targetframe.visible = false
