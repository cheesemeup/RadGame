extends Resource
class_name SubMenu

@export var title: String
@export var sub_menu_scene: PackedScene

const BACK_BUTTON = preload("res://main_menu/back_button.tscn")

func get_sub_menu_title() -> Label:
	var titleLabel = Label.new()
	titleLabel.text = title
	titleLabel.theme_type_variation = "HeaderLarge"
	return titleLabel

func get_sub_menu_button() -> Button:
	var button = Button.new()
	button.text = title
	return button

func get_back_button(connect_to: Callable) -> Button:
	var button = BACK_BUTTON.instantiate()
	button.pressed.connect(connect_to)
	return button
