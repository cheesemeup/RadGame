extends Node

# test dict
var spell_db

func _ready():
	var file = "res://Data/db_spells.json"
	var spell_db_string = FileAccess.get_file_as_string(file)
	spell_db = JSON.parse_string(spell_db_string)

func combat_event(spell,source,target):
	print("combat event using %s from %s to %s"%[spell["name"],source,target])
	print(spell)
	# error handling to be implemented
	if spell["spelltype"] == "damage":
		event_damage(spell,source,target)
#	elif spelltype == "dot":
#		event_dot()
	elif spell["spelltype"] == "heal":
		event_healing(spell,source,target)
#	elif spelltype == "hot":
#		event_hot()
#	elif spelltype == "aura":
#		event_aura()
	# get spell information
	# get damage modifiers
	# get mitigation modifiers
	pass

func event_damage(spell,source,target):
	# calculate and apply damage
	var value = int(floor(source.stats_curr["primary"] * \
		source.stats_curr["damage modifier"][spell["damagetype"]] * \
		target.stats_curr["defense modifier"][spell["damagetype"]]))
	target.stats_curr["health_current"] = max(target.stats_curr["health_current"]-value,0)
	print(target.stats_curr["health_current"])
	# write to log
	print("%s hits %s with %s for %.f damage."%\
		[source.stats_curr["name"],target.stats_curr["name"],\
		  spell["name"],value])
	
	
func event_dot():
	pass
	
func event_healing(spell,source,target):
	# calculate and apply healing
	var value = int(floor(source.stats_curr["primary"] * \
		source.stats_curr["heal modifier"][spell["healtype"]] * \
		target.stats_curr["heal taken modifier"][spell["healtype"]]))
	target.stats_curr["health_current"] = min(target.stats_curr["health_current"]+value,target.stats_curr["health_max"])
	print(target.stats_curr["health_current"])
	# write to log
	print("%s heals %s with %s for %.f damage."%\
		[source.stats_curr["name"],target.stats_curr["name"],\
		  spell["name"],value])
	
func event_hot():
	pass
	
func event_aura():
	pass
