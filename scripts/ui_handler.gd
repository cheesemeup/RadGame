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
	add_child(targetframe)

# SHOULD NOT BE A TOGGLE, AS SOME FUNCTIONS WILL WANT TO SPECIFICALL SHOW, OTHERS WANT TO SPECIFICALLY HIDE, TOGGLE NOT REALLY THE WAY TO GO
func toggle_targetframe():
	if targetframe.visible:
		targetframe.visible = false
		return
	targetframe.visible = true
