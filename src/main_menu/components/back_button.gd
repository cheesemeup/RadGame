extends Button

signal back

func _ready() -> void:
	pressed.connect(func (): back.emit())
