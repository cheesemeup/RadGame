extends Node

class_name BaseInteractable

var stats_base

func initialize_base_interactable(unit_id: String):
	# read stats dict from file
	var file = "res://data/db_stats_interactable.json"
	var json_dict = JSON.parse_string(FileAccess.get_file_as_string(file))
	stats_base = json_dict[unit_id]
	connect_signals()

func connect_signals():
	$range.connect("area_entered",add_interactable)
	$range.connect("area_exited",remove_interactable)

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
