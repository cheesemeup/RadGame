extends Node

#Test NPC Heal Self
var spell_base : Dictionary
var spell_curr : Dictionary

func _ready():
	var json_dict = JSON.parse_string(FileAccess.get_file_as_string("res://data/db_spells.json"))
	spell_base = json_dict["2"]
	spell_curr = spell_base.duplicate(true)

func trigger():
	# checks not necessary for this spell, as it is free, off gcd, and cast on self
	var source = get_parent().get_parent()
	Combat.combat_event_entrypoint(spell_curr,source,source)
