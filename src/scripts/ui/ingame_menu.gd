extends CanvasLayer

@onready var menu: VBoxContainer = %Menu

func _ready() -> void:
	menu.connect("close", UIHandler.close_ingame_menu)
