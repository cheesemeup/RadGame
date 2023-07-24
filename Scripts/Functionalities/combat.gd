extends Node

# preload common auras
var aura_general = preload("res://Scenes/Auras/aura_general.tscn")
var aura_absorb = preload("res://Scenes/Auras/aura_absorb.tscn")

func combat_event(spell,source,target):
	if target == null:
		return
	# check for avoidance if spell is avoidable
	var avoid = spell["avoidable"] * check_avoidance(target)
	if avoid == 1:
		write_to_log_avoid(spell,source,target)
		return
	# check if crit, if crittable
	var is_crit : int = spell["can_crit"] * check_crit(spell,source)
	if spell["spelltype"] == "damage":
		var value = event_damage(spell,source,target,is_crit)
		return value
	elif spell["spelltype"] == "heal":
		event_heal(spell,source,target,is_crit)
	elif spell["spelltype"] == "aura":
		event_aura_general(spell,source,target)
	elif spell["spelltype"] == "absorb":
		event_absorb(spell,source,target)
	
func check_avoidance(target):
	var avoid : int = 0
	# get random number
	var random = RandomNumberGenerator.new()
	random.randomize()
	var p : float = randf()
	# check if below avoidance probability, set avoid to true if true
	if p <= target.stats_curr["avoidance"]:
		avoid = 1
	return avoid
	
func check_crit(spell,source):
	var is_crit : int = 0
	# get random number
	var random = RandomNumberGenerator.new()
	random.randomize()
	var p : float = randf()
	# check if below avoidance probability, set avoid to true if true
	if p <= source.stats_curr["crit_chance"]+spell["crit_chance_modifier"]:
		is_crit = 1
	return is_crit
	
func aura_tick_event(spell,source,target):
	# this function handles aura ticks, as the structure differs from regular combat events
	var is_crit : int = spell["can_crit"] * check_crit(spell,source)
	if spell["auratype"] == "damage":
		event_damage(spell,source,target,is_crit)
	elif spell["auratype"] == "heal":
		event_heal(spell,source,target,is_crit)
	
func event_damage(spell,source,target,is_crit):
	# calculate and apply damage
	var crit_modifier = 1. + is_crit * (1. + spell["crit_damage_modifier"])
	var value : int = int(floor(source.stats_curr[spell["valuebase"]] *\
				spell["primary_modifier"] *\
				source.stats_curr["damage_modifier"][spell["damagetype"]] * \
				target.stats_curr["defense_modifier"][spell["damagetype"]] * \
				crit_modifier))
	# deal damage through absorbs
	apply_damage(spell,value,source,target,is_crit)
	return value
	
func event_heal(spell,source,target,is_crit):
	# calculate and apply healing
	var crit_modifier : float =  1. + is_crit * (1. + spell["crit_heal_modifier"])
	var value : int = int(floor(source.stats_curr[spell["valuebase"]] *\
				spell["primary_modifier"] * \
				source.stats_curr["heal_modifier"][spell["healtype"]] * \
				target.stats_curr["heal_taken_modifier"][spell["healtype"]] * \
				crit_modifier))
	target.stats_curr["health_current"] = min(target.stats_curr["health_current"]+value,target.stats_curr["health_max"])
	write_to_log_heal(spell,source,target,is_crit,value)
	
func event_aura_general(spell,source,target):
	# check if target already has same aura from same source active for hot/dot
	if spell["auratype"] == "damage" or spell["auratype"] == "heal":
		var key_name : String = "%s %s"%[source.stats_curr["name"],spell["name"]]
		if target.aura_dict.has(key_name):
			# remove before reapplication
			target.aura_dict[key_name].reinitialize(spell)
			write_to_log_aura_reapply(spell,source,target)
			return
	# source-agnostic for buff/debuff
	if spell["auratype"] == "buff" or spell["auratype"] == "debuff":
		var key_name : String = "%s"%[spell["name"]]
		if target.aura_dict.has(key_name):
			# remove before reapplication
			target.aura_dict[key_name].reinitialize(spell)
			write_to_log_aura_reapply(spell,source,target)
			return
	var aura = aura_general.instantiate()
	target.get_node("auras").add_child(aura)
	aura.initialize(spell,source,target)
	write_to_log_aura(spell,source,target)

func event_absorb(spell,source,target):
	# check if target already has same aura from same source active
	var key_name : String = "%s %s"%[source.stats_curr["name"],spell["name"]]
	if target.absorb_dict.has(key_name):
		# reset if already present
		target.absorb_dict[key_name].reinitialize(spell,source,target)
		write_to_log_aura_reapply(spell,source,target)
		return
	var aura = aura_absorb.instantiate()
	target.get_node("absorbs").add_child(aura)
	aura.initialize(spell,source,target)
	write_to_log_aura(spell,source,target)

func apply_damage(spell,value,source,target,is_crit):
	# check for absorbs
	for absorb in target.get_node("absorbs").get_children():
		# if shield fully absorbs hit without being depleted
		if value < absorb.absorb_value:
			absorb.absorb_value -= value
			write_to_log_absorb(spell,source,target,absorb,is_crit,value)
			return
		# if shield fully absorbs hit and is depleted
		elif value == absorb.absorb_value:
			absorb.queue_free()
			write_to_log_absorb(spell,source,target,absorb,is_crit,value)
			return
		# if hit value is larger than absorb value, reduce remaining value and remove absorb node
		elif value > absorb.absorb_value:
			value -= absorb.absorb_value
			write_to_log_absorb(spell,source,target,absorb,is_crit,absorb.absorb_value)
			absorb.queue_free()
	# deal unabsorbed damage
	target.stats_curr["health_current"] = max(target.stats_curr["health_current"]-value,0)
	write_to_log_damage(spell,source,target,is_crit,value,)

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
	# apply to current stats
	body.stats_curr[statkey] = (body.stats_base[statkey] + stat_add) * stat_mult
	# adjust current health and resource if above maximum
	if statkey == "health_max" and body.stats_curr["health_current"] > body.stats_curr["health_max"]:
		body.stats_curr["health_current"] = body.stats_curr["health_max"]
	if statkey == "resource_max" and body.stats_curr["resource_current"] > body.stats_curr["resource_max"]:
		body.stats_curr["resource_current"] = body.stats_curr["resource_max"]

### write to log
###################################################################################################
func write_to_log_damage(spell,source,target,is_crit,value):
	var ending : String = "."
	if is_crit:
		ending = " (critical)."
	print("%s hits %s with %s for %.f %s damage%s"%\
		[source.stats_curr["name"],target.stats_curr["name"],\
		 spell["name"],value,spell["damagetype"],ending])
func write_to_log_absorb(spell,source,target,absorb,is_crit,value):
	var ending : String = "."
	if is_crit:
		ending = " (critical)."
	print("%s of %s absorbs %.f damage of %s used on %s by %s%s"%\
		[absorb.spellname,absorb.absorb_source,value,spell["name"],\
		target.stats_curr["name"],source.stats_curr["name"],ending])
func write_to_log_heal(spell,source,target,is_crit,value):
	var ending : String = "."
	if is_crit:
		ending = " (critical)."
	print("%s heals %s with %s for %.f %s healing%s"%\
		[source.stats_curr["name"],target.stats_curr["name"],\
		 spell["name"],value,spell["healtype"],ending])
func write_to_log_avoid(spell,source,target):
	print("%s has avoided %s from %s."%[target.stats_curr["name"],spell["name"],source.stats_curr["name"]])
func write_to_log_aura(spell,source,target):
	print("%s applies %s to %s"%[source.stats_curr["name"],spell["name"],target.stats_curr["name"]])
func write_to_log_aura_reapply(spell,source,target):
	print("%s reapplies %s to %s"%[source.stats_curr["name"],spell["name"],target.stats_curr["name"]])
func write_to_log_aura_fade(spell,source,target):
	print("%s's %s faded from %s"%[source.stats_curr["name"],spell["name"],target.stats_curr["name"]])
