extends Node

# preload auras
var aura_tick = preload("res://Scenes/Auras/aura_tick.tscn")

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
		event_heal(spell,source,target)
	elif spell["spelltype"] == "aura":
		event_aura(spell,source,target)
	
func aura_tick_event(spell,source,target):
	# this function handles aura ticks, as the structure differs from regular combat events
	if spell["auratype"] == "damage":
		event_damage(spell,source,target)
	elif spell["auratype"] == "heal":
		event_heal(spell,source,target)
	
func event_damage(spell,source,target):
	# check if avoided, hit, or crit
	# calculate and apply damage
	var value : int
	if spell["valuetype"] == "absolute":
		value = int(floor(source.stats_curr["primary"] * spell["primary_modifier"] * \
			source.stats_curr["damage_modifier"][spell["damagetype"]] * \
			target.stats_curr["defense_modifier"][spell["damagetype"]]))
	elif spell["valuetype"] == "relative":
		value = int(floor(spell["primary_modifier"]*source.stats_curr[spell["valuebase"]] * \
			source.stats_curr["damage_modifier"][spell["damagetype"]] * \
			target.stats_curr["defense_modifier"][spell["damagetype"]]))
	target.stats_curr["health_current"] = max(target.stats_curr["health_current"]-value,0)
	# write to log
	print("%s hits %s with %s for %.f damage."%\
		[source.stats_curr["name"],target.stats_curr["name"],\
		  spell["name"],value])
	
func event_heal(spell,source,target):
	# calculate and apply healing
	var value : int
	if spell["valuetype"] == "absolute":
		value = int(floor(source.stats_curr["primary"] * spell["primary_modifier"] * \
			source.stats_curr["heal_modifier"][spell["healtype"]] * \
			target.stats_curr["heal_taken_modifier"][spell["healtype"]]))
	elif spell["valuetype"] == "relative":
		value = int(floor(spell["primary_modifier"]*source.stats_curr[spell["valuebase"]] * \
			source.stats_curr["heal_modifier"][spell["healtype"]] * \
			target.stats_curr["heal_taken_modifier"][spell["healtype"]]))
	target.stats_curr["health_current"] = min(target.stats_curr["health_current"]+value,target.stats_curr["health_max"])
	# write to log (or console for now)
	print("%s heals %s with %s for %.f damage."%\
		[source.stats_curr["name"],target.stats_curr["name"],\
		  spell["name"],value])
	
func event_aura(spell,source,target):
	# this function applies aura scenes
	print("aura time",spell)
	var aura = aura_tick.instantiate()
	target.add_child(aura)
	aura.initialize(spell,source,target)
