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
		is_crit = check_crit(spell,source)
	if spell["spelltype"] == "damage":
		event_damage(spell,source,target,is_crit)
	elif spell["spelltype"] == "heal":
		event_heal(spell,source,target,is_crit)
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
	return avoid
	
func check_crit(spell,source):
	var is_crit = false
	# get random number
	var random = RandomNumberGenerator.new()
	random.randomize()
	var p = randf()
	# check if below avoidance probability, set avoid to true if true
	if p <= source.stats_curr["crit_chance"]+spell["crit_chance_modifier"]:
		is_crit = true
	return is_crit
	
func aura_tick_event(spell,source,target):
	# this function handles aura ticks, as the structure differs from regular combat events
	var is_crit = false
	if spell["can_crit"]:
		is_crit = check_crit(spell,source)
	if spell["auratype"] == "damage":
		event_damage(spell,source,target,is_crit)
	elif spell["auratype"] == "heal":
		event_heal(spell,source,target,is_crit)
	
func event_damage(spell,source,target,is_crit):
	# calculate and apply damage
	var value : int
	var crit_modifier : float =  1. 
	if is_crit:
		crit_modifier = crit_modifier + 1. + spell["crit_damage_modifier"]
	if spell["valuetype"] == "absolute":
		value = int(floor(\
			source.stats_curr["primary"] * \
			spell["primary_modifier"] * \
			source.stats_curr["damage_modifier"][spell["damagetype"]] * \
			target.stats_curr["defense_modifier"][spell["damagetype"]] * \
			crit_modifier))
	elif spell["valuetype"] == "relative":
		value = int(floor(\
			spell["primary_modifier"] * \
			source.stats_curr[spell["valuebase"]] * \
			source.stats_curr["damage_modifier"][spell["damagetype"]] * \
			target.stats_curr["defense_modifier"][spell["damagetype"]] * \
			crit_modifier))
	# check for absorb
	target.stats_curr["health_current"] = max(target.stats_curr["health_current"]-value,0)
	# write to log
	if is_crit:
		print("%s hits %s with %s for %.f damage (critical)."%\
		[source.stats_curr["name"],target.stats_curr["name"],\
		  spell["name"],value])
	else:
		print("%s hits %s with %s for %.f damage."%\
		[source.stats_curr["name"],target.stats_curr["name"],\
		  spell["name"],value])
	
func event_heal(spell,source,target,is_crit):
	# calculate and apply healing
	var value : int
	var crit_modifier : float =  1. 
	if is_crit:
		crit_modifier = crit_modifier + 1. + spell["crit_heal_modifier"]
	if spell["valuetype"] == "absolute":
		value = int(floor(source.stats_curr["primary"] * \
			spell["primary_modifier"] * \
			source.stats_curr["heal_modifier"][spell["healtype"]] * \
			target.stats_curr["heal_taken_modifier"][spell["healtype"]] * \
			crit_modifier))
	elif spell["valuetype"] == "relative":
		value = int(floor(spell["primary_modifier"] * \
			source.stats_curr[spell["valuebase"]] * \
			source.stats_curr["heal_modifier"][spell["healtype"]] * \
			target.stats_curr["heal_taken_modifier"][spell["healtype"]] * \
			crit_modifier))
	target.stats_curr["health_current"] = min(target.stats_curr["health_current"]+value,target.stats_curr["health_max"])
	# write to log (or console for now)
	if is_crit:
		print("%s heals %s with %s for %.f damage (critical)."%\
		[source.stats_curr["name"],target.stats_curr["name"],\
		  spell["name"],value])
	else:
		print("%s heals %s with %s for %.f damage."%\
		[source.stats_curr["name"],target.stats_curr["name"],\
		  spell["name"],value])
	
func event_aura(spell,source,target):
	# check if target already has same aura from same source active for hot/dot
	if spell["auratype"] == "damage" or spell["auratype"] == "heal":
		var key_name = "%s %s"%[source.stats_curr["name"],spell["name"]]
		if target.aura_dict.has(key_name):
			# remove before reapplication
			target.aura_dict[key_name].remove_aura(spell,source,target)
	# source-agnostic for buff/debuff
	if spell["auratype"] == "buff" or spell["auratype"] == "debuff":
		var key_name = "%s"%[spell["name"]]
		if target.aura_dict.has(key_name):
			# remove before reapplication
			target.aura_dict[key_name].remove_aura(spell,source,target)
	var aura = aura_general.instantiate()
	target.get_node("auras").add_child(aura)
	aura.initialize(spell,source,target)
	print("%s applies %s to %s"%[source.stats_curr["name"],spell["name"],target.stats_curr["name"]])

func apply_damage(value,source,target,is_crit):
	# check for absorbs
	# deal damage to absorbs with shortest remaining duration
	pass

### stat calculations
###################################################################################################
# calculate all stats when changing class or talents, should only be done outside of combat
func stat_calculation_full(body):
	# loop through all stats
	for statkey in body.stats_curr:
		# skip if current health or resource
		if statkey in ["health_current","resource_current"]:
			continue
		# call single stat calculation
		single_stat_calculation(body,statkey)

# change single stat when buff or debuff is applied
func single_stat_calculation(body,statkey):
	var stat_add : int = 0
	var stat_mult : float = 1.
	# get additive and multiplicative modifiers
	if body.stats_base["stat_add"].has(statkey):
		for value in body.stats_base["stat_add"][statkey].keys():
			stat_add = stat_add + body.stats_base["stat_add"][statkey][value]
	if body.stats_base["stat_mult"].has(statkey):
		for value in body.stats_base["stat_mult"][statkey].keys():
			stat_mult = stat_mult * body.stats_base["stat_mult"][statkey][value]
	# apply to base stat
	body.stats_curr[statkey] = (body.stats_base[statkey] + stat_add) * stat_mult
	# adjust current health and resource if above maximum
	if statkey == "health_max" and body.stats_curr["health_current"] > body.stats_curr["health_max"]:
		body.stats_curr["health_current"] = body.stats_curr["health_max"]
	if statkey == "resource_max" and body.stats_curr["resource_current"] > body.stats_curr["resource_max"]:
		body.stats_curr["resource_current"] = body.stats_curr["resource_max"]
