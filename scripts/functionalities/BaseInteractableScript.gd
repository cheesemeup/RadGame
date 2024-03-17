extends Node

class_name BaseInteractable

var stats_current

func initialize_base_interactable(unit_id: String):
	# read stats dict from file
	var file = "res://data/db_stats_interactable.json"
	var json_dict = JSON.parse_string(FileAccess.get_file_as_string(file))
	stats_current = json_dict[unit_id]
	# spell container for interactables
	var spell_container = preload(
		"res://scenes/functionalities/spells_interactable.tscn"
		).instantiate()
	add_child(spell_container)
	for spell in stats_current["spell_list"]:
		var spell_scene = load("res://scenes/spells/spell_%s.tscn" % spell)
		spell_scene = spell_scene.instantiate()
		$spells_interactable.add_child(spell_scene)
	# connect enter and exit signals
	connect_signals()
	# set interact radius
	$"range/range_shape".shape.radius = stats_current["interact_range"]

func connect_signals():
	$range.connect("body_entered",add_interactable)
	$range.connect("body_exited",remove_interactable)

func add_interactable(target: CharacterBody3D):
	print("add")
	# append interactable to player's interactable list
	if not target.is_in_group("player"):
		return
	target.interactables.append(self)

func remove_interactable(target: CharacterBody3D):
	print("remove")
	# delete interactable from player's interactable list
	if not target.is_in_group("player"):
		return
	target.interactables.erase(self)

func trigger(_interactor):
	# Log interaction in combat script
	# If no override is present in specific interactable, print message
	print("Trigger has not been overriden!")
