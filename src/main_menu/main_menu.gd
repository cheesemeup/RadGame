extends CanvasLayer

@export var SUB_MENUS: Array[SubMenu]

@onready var main_menu: VBoxContainer = $CenterContainer/MarginContainer/VBoxContainer/MainMenu
@onready var back_button: Button = $CenterContainer/MarginContainer/VBoxContainer/back_button
@onready var sub_menu_buttons: VBoxContainer = $CenterContainer/MarginContainer/VBoxContainer/MainMenu/SubMenuButtons
@onready var sub_menus: VBoxContainer = $CenterContainer/MarginContainer/VBoxContainer/SubMenus

func _ready() -> void:
	for sub_menu in SUB_MENUS:
		var sub_menu_node: Node = sub_menu.instantiate_hidden()
		sub_menus.add_child(sub_menu_node)
		var sub_menu_button: Button = sub_menu.get_button()
		sub_menu_button.pressed.connect(func (): show_submenu(sub_menu_node))
		sub_menu_buttons.add_child(sub_menu_button)

func _on_back_button_pressed():
	for sub_menu in sub_menus.get_children():
		sub_menu.hide()
	main_menu.show()
	back_button.hide()

func show_submenu(submenu: Node):
	main_menu.hide()
	submenu.show()
	back_button.show()

func _on_quit_button_pressed():
	get_tree().quit()
