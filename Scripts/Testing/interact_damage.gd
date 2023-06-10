extends Node3D

var stats_base: Dictionary
@export var stats_curr: Dictionary
var spells_base: Dictionary
@export var spells_curr: Dictionary

func _ready():
	# load stats and spells
	var file = "res://Data/db_stats.json"
	var json_dict = JSON.parse_string(FileAccess.get_file_as_string(file))
	stats_base = json_dict["0"]
	stats_curr = stats_base
	file = "res://Data/db_spells.json"
	json_dict = JSON.parse_string(FileAccess.get_file_as_string(file))
	spells_base["0"] = json_dict["0"]
	spells_curr = spells_base

func interaction(body):
	print("interacted with interact_damage sign")
	Combat.combat_event(spells_curr["0"],self,body)
	body.unit_hp_current = max(body.unit_hp_current-100,0)

func calculate_stats():
	pass
