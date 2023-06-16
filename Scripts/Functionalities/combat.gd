extends Node

# preload common auras
var aura_general = preload("res://Scenes/Auras/aura_general.tscn")

func combat_event(spell,source,target):
	if target == null:
		return
	# check for avoidance if spell is avoidable
	if spell["avoidable"]:
		var avoid = check_avoidance(spell,target)
		if avoid:
			print("%s has avoided %s from %s."%[target.stats_curr["name"],spell["name"],source.stats_curr["name"]])
			return
	# check if crit, if crittable
	var is_crit = false
	if spell["can_crit"]:
		is_crit = check_crit()
	if spell["spelltype"] == "damage":
		event_damage(spell,source,target)
	elif spell["spelltype"] == "heal":
		event_heal(spell,source,target)
	elif spell["spelltype"] == "aura":
		event_aura(spell,source,target)
	
func check_avoidance(spell,target):
	var avoid = false
	# get random number
	var random = RandomNumberGenerator.new()
	random.randomize()
	var p = randf()
	# check if below avoidance probability, set avoid to true if true
	if p <= target.stats_curr["avoidance"]+spell["avoidance_modifier"]:
		avoid = true
	print(p,target.stats_curr["avoidance"])
	return avoid
	
func check_crit():
	var crit = false
	return crit
	
func aura_tick_event(spell,source,target):
	# this function handles aura ticks, as the structure differs from regular combat events
	if spell["auratype"] == "damage":
		event_damage(spell,source,target)
	elif spell["auratype"] == "heal":
		event_heal(spell,source,target)
	
func event_damage(spell,source,target):
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
	# check if target already has same aura from same source active for hot/dot
	if spell["auratype"] == "damage" or spell["auratype"] == "heal":
		var key_name = "%s %s"%[source.stats_curr["name"],spell["name"]]
		if target.aura_dict.has(key_name):
			# remove before reapplication
			target.aura_dict[key_name].queue_free()
			target.aura_dict.erase(key_name)
	# source-agnostic for buff/debuff
	if spell["auratype"] == "buff" or spell["auratype"] == "debuff":
		var key_name = "%s"%[spell["name"]]
		if target.aura_dict.has(key_name):
			# remove before reapplication
			target.aura_dict[key_name].queue_free()
			target.aura_dict.erase(key_name)
	var aura = aura_general.instantiate()
	target.get_node("auras").add_child(aura)
	aura.initialize(spell,source,target)
	print("%s applies %s to %s"%[source.stats_curr["name"],spell["name"],target.stats_curr["name"]])
	
# calculating stats needs to go somewhere, but having it's own script seems excessive
# so it goes here, because it is related to the application and removal of auras
func stat_calculation(body):
	pass
