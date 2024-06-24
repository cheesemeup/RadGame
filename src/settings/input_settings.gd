class_name InputSettings extends Resource

@export var input_event_map: Dictionary

func initialize_with_defaults() -> void:
	# make sure we have all mapped keys, even if they weren't saved to settings
	input_event_map = get_game_actions() \
		.reduce(
			func (dict, action):
				if not dict.has(action):
					dict[action] = InputMap.action_get_events(action).front()
				return dict,
			input_event_map
		)

func get_game_actions() -> Array:
	return InputMap.get_actions() \
		.filter(func (action): return not action.begins_with("ui_")) \
		.map(func (action): return str(action))

func get_input_event(action: String) -> InputEvent:
	if input_event_map.has(action):
		return input_event_map[action]
	else:
		var event = InputMap.action_get_events(action).front()
		input_event_map[action] = event
		return event

func set_action_input_event(action: StringName, input_event: InputEvent) -> void:
	if InputMap.has_action(action):
		input_event_map[action] = input_event
		emit_changed()
	else:
		printerr("trying to set input event %s for unknown action %s" % [input_event.as_text(), action])

func apply() -> void:
	for action in get_game_actions():
		if (
			input_event_map[action] and
			input_event_map[action].as_text() != InputMap.action_get_events(action).front().as_text()
		):
			print("applying InputMap: action %s to key %s" % [action, input_event_map[action]])
			InputMap.action_erase_events(action)
			InputMap.action_add_event(action, input_event_map[action])

func _to_string() -> String:
	return (
		"Input Settings:" +
		input_event_map.keys().reduce(
			func (acc, action):
				return acc + "\n\t%s:\t%s" % [action, (input_event_map[action] as InputEvent).as_text()],
			""
		)
	)
