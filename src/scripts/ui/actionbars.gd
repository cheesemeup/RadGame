extends Control

var actionbar_slot = preload("res://scenes/ui/actionbar_slot.tscn")
var actions: Array
var spell_map: Dictionary

func initialize() -> void:
	# add actionbar slots to actionbars
	for i in range(1,2):
		for j in range(1,13):
			var slot = actionbar_slot.instantiate()
			slot.name = "actionbar%s_%s"%[i,j]
			get_node("actionbar%s"%i).add_child(slot)
	print("actionbar1: ",$actionbar1.get_children())
	print("actionbar2: ",$actionbar2.get_children())
	# get all actionbar InputMap actions and set text to primary event
	actions = get_actionbar_actions()
	set_text()
	# initialize all slots with spell id and spell icon
	# silly workaround, make persistent spell map later
	spell_map["1_1"] = "10"
	spell_map["1_2"] = "12"
	spell_map["1_3"] = "11"
	spell_map["1_4"] = "13"
	spell_map["1_5"] = "14"
	for key in spell_map.keys():
		get_node(NodePath("actionbar%s"%key[0])).\
			get_node(NodePath("actionbar%s"%key)).init(spell_map[key])


func get_actionbar_actions() -> Array:
	var input_actions = InputMap.get_actions()
	actions = []
	for action in input_actions:
		if action.left(9) == "actionbar":
			actions.append(action)
	return actions


func set_text() -> void:
	# set button.text to primary event of action
	var actionbar: NodePath
	for action in actions:
		if InputMap.action_get_events(action) == []:
			continue
		#actionbar = "./%s"%action.left(10)
		#get_node(NodePath(actionbar)).get_node(NodePath(action)).\
			#get_node(NodePath("hotkey")).text = \
			#gen_text(InputMap.action_get_events(action)[0].as_text())


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
