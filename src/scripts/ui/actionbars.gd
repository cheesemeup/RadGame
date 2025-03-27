extends Control

var actionbar_slot = preload("res://scenes/ui/actionbar_slot.tscn")
var actions: Array

func initialize() -> void:
	# add actionbar slots to actionbars, linked later from player scene in post_ready
	for i in range(1,3):
		for j in range(1,13):
			var slot = actionbar_slot.instantiate()
			slot.name = "actionbar%d_%d"%[i,j]
			slot.set_process(false)
			get_node("actionbar%d"%i).add_child(slot)
	# get all actionbar InputMap actions and set text to primary event
	actions = get_actionbar_actions()
	set_text()


func get_actionbar_actions() -> Array:
	var input_actions = InputMap.get_actions()
	actions = []
	for action in input_actions:
		if action.left(9) == "actionbar":
			actions.append(action)
	return actions


func set_text() -> void:
	# set button.text to primary event of action
	for action in actions:
		if InputMap.action_get_events(action) == []:
			continue
		get_node(NodePath("%s"%action.left(10))).get_node(NodePath(action)).\
			get_node(NodePath("hotkey")).text = \
			gen_text(InputMap.action_get_events(action)[0].as_text())


func gen_text(text: String) -> String:
	if not "+" in text:
		text = text.trim_suffix(" (Physical)")
		if text == "Minus":
			return "-"
		elif text == "Equal":
			return "="
		else:
			return text
	var returntext: String = ""
	var textarray = text.split("+")
	for substring in textarray:
		substring = substring.trim_suffix(" (Physical)")
		if substring == "Shift":
			returntext = "%s%s"%[returntext,"S+"]
		elif substring == "Minus":
			returntext = "%s%s"%[returntext,"-"]
		elif substring == "Equal":
			returntext = "%s%s"%[returntext,"="]
		else:
			returntext = "%s%s"%[returntext,substring]
	return returntext


func toggle_cd_swipes(enabled: bool):
	for container in get_children():
		for slot in container.get_children():
			slot.swipe_enabled = enabled
