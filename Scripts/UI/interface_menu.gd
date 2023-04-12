extends Control


# Called when the node enters the scene tree for the first time.
func _ready():
	$"interface_menu_tabs/Single Frames/playerframe_width_entry".text = str(Autoload.player_ui_main_reference)
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
