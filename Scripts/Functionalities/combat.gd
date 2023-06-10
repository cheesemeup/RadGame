extends Node

# test dict
var spell_db

func _ready():
	var file = "res://Data/db_spells.json"
	var spell_db_string = FileAccess.get_file_as_string(file)
	spell_db = JSON.parse_string(spell_db_string)

func combat_event(spell,source,target):
	print("combat event using %s from %s to %s"%[spell["name"],source,target])
	# error handling to be implemented
	if spell["spelltype"] == "damage":
		event_damage(spell,source,target)
#	elif spelltype == "dot":
#		event_dot()
#	elif spelltype == "healing":
#		event_healing()
#	elif spelltype == "hot":
#		event_hot()
#	elif spelltype == "aura":
#		event_aura()
	# get spell information
	# get damage modifiers
	# get mitigation modifiers
	pass

func event_damage(spell,source,target):
	# get source info
	var primary = source.stats_curr["primary"]
	var sourcemod = source.stats_curr["damage modifier"][spell["damagetype"]]
	# get target info
	var targetmod = target.stats_curr["defense modifier"][spell["damagetype"]]
	# get spell info
	# calculate damage
	# write to log
	pass
	
func event_dot():
	pass
	
func event_healing():
	pass
	
func event_hot():
	pass
	
func event_aura():
	pass
