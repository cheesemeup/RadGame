extends Resource
class_name SubMenu

@export var title: String
@export var sub_menu_scene: PackedScene

func instantiate_hidden() -> Node:
	var sub_menu = sub_menu_scene.instantiate()
	sub_menu.hide()
	return sub_menu

func get_button() -> Button:
	var button = Button.new()
	button.text = title
	return button
