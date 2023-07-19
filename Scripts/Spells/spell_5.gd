extends Node

# Player Test Heal
var spell_base : Dictionary
var spell_curr : Dictionary

func _ready():
	var json_dict = JSON.parse_string(FileAccess.get_file_as_string("res://Data/db_spells.json"))
	spell_base = json_dict["5"]
	spell_curr = spell_base.duplicate(true)

func trigger():
	print("triggered spell ID 5")
	print()
	get_parent().get_parent().send_combat_event(spell_curr)
