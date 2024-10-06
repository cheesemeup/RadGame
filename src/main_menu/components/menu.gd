class_name Menu extends Container

signal close

@export var SUB_MENUS: Array[SubMenu]
@export var CLOSE_BUTTON_TEXT: String

const BACK_BUTTON = preload("res://main_menu/components/back_button.tscn")

@onready var menu_view: Control = $MenuView
@onready var menu_buttons: VBoxContainer = %MenuButtons
@onready var close_button: Button = %CloseButton
@onready var children_buttons: Node = %ChildrenButtons
@onready var children_views: Control = %ChildrenViews

func _ready() -> void:
	for sub_menu in SUB_MENUS:
		var sub_menu_wrapper = VBoxContainer.new()
		sub_menu_wrapper.hide()
		sub_menu_wrapper.add_child(sub_menu.get_sub_menu_title())
		sub_menu_wrapper.add_child(sub_menu.sub_menu_scene.instantiate())
		sub_menu_wrapper.add_child(sub_menu.get_back_button(hide_sub_menu.bind(sub_menu_wrapper)))
		children_views.add_child(sub_menu_wrapper)
		
		var sub_menu_button: Button = sub_menu.get_sub_menu_button()
		sub_menu_button.pressed.connect(show_sub_menu.bind(sub_menu_wrapper))
		children_buttons.add_child(sub_menu_button)
	
	if not CLOSE_BUTTON_TEXT.is_empty():
		close_button.text = CLOSE_BUTTON_TEXT
	close_button.pressed.connect(_on_close_button_pressed)

func hide_sub_menu(sub_menu: Node):
	sub_menu.hide()
	menu_view.show()

func show_sub_menu(sub_menu: Node):
	print('show sub menu')
	menu_view.hide()
	sub_menu.show()

func _on_close_button_pressed() -> void:
	print("close emit")
	close.emit()
