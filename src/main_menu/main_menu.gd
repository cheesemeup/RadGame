extends CanvasLayer

@onready var menu: Menu = %Menu

func _ready() -> void:
	menu.connect("close", get_tree().quit)
