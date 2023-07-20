extends Node

# Fingers of Frost
var spell_base : Dictionary
var spell_curr : Dictionary

func _ready():
	var json_dict = JSON.parse_string(FileAccess.get_file_as_string("res://Data/db_spells.json"))
	spell_base = json_dict["10"]
	spell_curr = spell_base.duplicate(true)

func trigger():
	# check resource cost
	if get_parent().get_parent().stats_curr["resource_current"] < spell_curr["resource_cost"]:
		print("insufficient resources")
		return
	# check target
	var spell_target = get_parent().get_parent().get_spell_target(spell_curr)
	if typeof(spell_target) == TYPE_STRING and  spell_target == "no_legal_target":
		print("no legal target")
		return
	# check range
	# apply resource cost
	get_parent().get_parent().stats_curr["resource_current"] -= spell_curr["resource_cost"]
	# send gcd
	get_parent().send_gcd()
	# fire spell
	Combat.combat_event(spell_curr,get_parent().get_parent(),spell_target)

# role swap effects
func swap_tank():
	spell_curr["damagetype"] = "magic"
func swap_heal():
	spell_curr["damagetype"] = "magic"
func swap_meleedps():
	spell_curr["damagetype"] = "physical"
func swap_rangedps():
	spell_curr["damagetype"] = "magic"

# talent effects
