extends Button

signal remap_action(action: StringName, input_event: InputEvent)

var action: StringName
var input_event: InputEvent
var listen_for_input := false

func _ready() -> void:
	text = input_event.as_text()
	pressed.connect(start_remapping, CONNECT_ONE_SHOT)

func _unhandled_key_input(event: InputEvent) -> void:
	if listen_for_input and event is InputEventKey:
		listen_for_input = false
		if event.is_action("ui_cancel"):
			text = input_event.as_text()
		else:
			remap_action.emit(action, event)
			text = event.as_text()
		disabled = false
		pressed.connect(start_remapping, CONNECT_ONE_SHOT)

func _gui_input(event: InputEvent) -> void:
	if listen_for_input and event is InputEventMouseButton:
		listen_for_input = false
		remap_action.emit(action, event)
		text = event.as_text()
		disabled = false
		get_tree().create_timer(0.1).timeout.connect(
			# defer, to avoid instantly pressing the button again
			func(): pressed.connect(start_remapping, CONNECT_ONE_SHOT)
		)

func start_remapping() -> void:
	text = "Press any key..."
	disabled = true
	listen_for_input = true
