extends CanvasLayer

@export var SUB_MENUS: Array[SubMenu]

const BACK_BUTTON = preload("res://main_menu/components/back_button.tscn")

@onready var main_menu: VBoxContainer = %MainMenu
@onready var sub_menu_buttons: VBoxContainer = %SubMenuButtons
@onready var sub_menus: Control = %SubMenus

func _ready() -> void:
	for sub_menu in SUB_MENUS:
		var sub_menu_wrapper = VBoxContainer.new()
		sub_menu_wrapper.hide()
		sub_menu_wrapper.add_child(sub_menu.get_sub_menu_title())
		sub_menu_wrapper.add_child(sub_menu.sub_menu_scene.instantiate())
		sub_menu_wrapper.add_child(sub_menu.get_back_button(hide_sub_menu.bind(sub_menu_wrapper)))
		sub_menus.add_child(sub_menu_wrapper)
		
		var sub_menu_button: Button = sub_menu.get_sub_menu_button()
		sub_menu_button.pressed.connect(show_sub_menu.bind(sub_menu_wrapper))
		sub_menu_buttons.add_child(sub_menu_button)

func hide_sub_menu(sub_menu: Node):
	sub_menu.hide()
	main_menu.show()

func show_sub_menu(sub_menu: Node):
	main_menu.hide()
	sub_menu.show()

func _on_quit_button_pressed():
	get_tree().quit()
