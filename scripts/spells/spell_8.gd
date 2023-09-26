extends Node

# Player Test Buff
var spell_base : Dictionary
var spell_curr : Dictionary

func _ready():
	var json_dict = JSON.parse_string(FileAccess.get_file_as_string("res://Data/db_spells.json"))
	spell_base = json_dict["8"]
	spell_curr = spell_base.duplicate(true)

func trigger():
	var sourcenode = get_parent().get_parent()
	# check resource cost
	if sourcenode.stats_curr["resource_current"] < spell_curr["resource_cost"]:
		print("insufficient resources")
		return
	# check target
	var spell_target = sourcenode.get_spell_target(spell_curr)
	if typeof(spell_target) == TYPE_STRING and spell_target == "no_legal_target":
		print("no legal target")
		return
	# check range
	# apply resource cost
	sourcenode.stats_curr["resource_current"] -= spell_curr["resource_cost"]
	# send gcd
	get_parent().send_gcd()
	# fire spell
	Combat.event_aura(spell_curr,sourcenode,spell_target)
