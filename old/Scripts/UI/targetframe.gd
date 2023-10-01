extends Control

# mouseover targeting of frame
func _on_targetframe_hpbar_mouse_entered():
	Autoload.player_reference.unit_mouseover_target = Autoload.player_reference.unit_selectedtarget
func _on_targetframe_hpbar_mouse_exited():
	Autoload.player_reference.unit_mouseover_target = null
func _on_targetframe_resbar_mouse_entered():
	Autoload.player_reference.unit_mouseover_target = Autoload.player_reference.unit_selectedtarget
func _on_targetframe_resbar_mouse_exited():
	Autoload.player_reference.unit_mouseover_target = null
