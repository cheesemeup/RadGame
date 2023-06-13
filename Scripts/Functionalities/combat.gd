extends Node

# test dict
#var spell_db

#func _ready():
#	var file = "res://Data/db_spells.json"
#	var spell_db_string = FileAccess.get_file_as_string(file)
#	spell_db = JSON.parse_string(spell_db_string)

func combat_event(spell,source,target):
	if target == null:
		return
	# error handling to be implemented
	if spell["spelltype"] == "damage":
		event_damage(spell,source,target)
	elif spell["spelltype"] == "heal":
		event_healing(spell,source,target)
#	elif spelltype == "aura":
#		event_aura()
	
func event_damage(spell,source,target):
	# check if avoided, hit, or crit
	# calculate and apply damage
	var value : int
	if spell["valuetype"] == "absolute":
		value = int(floor(source.stats_curr["primary"] * spell["primary_modifier"] * \
			source.stats_curr["damage modifier"][spell["damagetype"]] * \
			target.stats_curr["defense modifier"][spell["damagetype"]]))
	elif spell["valuetype"] == "relative":
		value = int(floor(spell["primary_modifier"]*source.stats_curr[spell["valuebase"]]))
	target.stats_curr["health_current"] = max(target.stats_curr["health_current"]-value,0)
	# write to log
	print("%s hits %s with %s for %.f damage."%\
		[source.stats_curr["name"],target.stats_curr["name"],\
		  spell["name"],value])
	
func event_healing(spell,source,target):
	# calculate and apply healing
	var value = int(floor(source.stats_curr["primary"] * spell["primary_modifier"] * \
		source.stats_curr["heal modifier"][spell["healtype"]] * \
		target.stats_curr["heal taken modifier"][spell["healtype"]]))
	target.stats_curr["health_current"] = min(target.stats_curr["health_current"]+value,target.stats_curr["health_max"])
	# write to log
	print("%s heals %s with %s for %.f damage."%\
		[source.stats_curr["name"],target.stats_curr["name"],\
		  spell["name"],value])
	
func event_aura():
	# this function applies aura scenes
	pass
