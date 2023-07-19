extends Node

# Test NPC Damage Self
var spell_base : Dictionary
var spell_curr : Dictionary

func _ready():
	var json_dict = JSON.parse_string(FileAccess.get_file_as_string("res://Data/db_spells.json"))
	spell_base = json_dict["4"]
	spell_curr = json_dict["4"]

func trigger():
	get_parent().get_parent().send_combat_event(spell_curr)
