extends Node

####################################################################################################
# ENTRYPOINTS
func combat_event_entrypoint(
	spell: Dictionary,
	source: CharacterBody3D,
	target: CharacterBody3D,
	value: int = -1
):
	# determine type of event and call appropriate function
	if spell["spelltype"] == "damage":
		combat_event_damage(spell,source,target,value)
	if spell["spelltype"] == "heal":
		combat_event_heal(spell,source,target,value)
func value_query(coeff: float, base: int, mod_inc: float, mod_dec: float):
	# returns the value of a damage or healing spell based on the coefficient, the base value stat,
	# and the two applicable modifiers. Used for combat events and for snapshotting values.
	return int(floor(coeff * base * mod_inc * mod_dec))

####################################################################################################
# COMBAT EVENTS
func combat_event_damage(
	spell: Dictionary,
	source: CharacterBody3D,
	target: CharacterBody3D,
	value: int
):
	# query base value of event if not prescribed
	if value == -1:
		print("querying value")
		value = value_query(
			spell["value_modifier"],
			source.stats_current[spell["value_base"]],
			source.stats_current["damage_modifier"][spell["effecttype"]],
			target.stats_current["defense_modifier"][spell["effecttype"]]
		)
		print("value: %s"%value)
	# determine avoid
	if spell["avoidable"] == 1 and is_avoid(target.stats_current["avoidance"]):
		log_avoid(
			spell["name"],
			source.stats_current["unit_name"],
			target.stats_cruten["unit_name"]
		)
		return
	# determine critical hit
	var crit = 0
	if spell["can_crit"] == 1:
		crit = is_critical(spell["crit_chance_modifier"], source.stats_current["crit_chance"])
		value = value * (1 + crit * spell["crit_magnitude_modifier"])
	# apply damage
	var overkill = apply_damage(value,target)
	# show floating combat test for source via rpc, if source is player
	if source.is_in_group("player"):
		#rpc call to player scene, which call ui function
		pass
	# write to log
	log_damage(
		spell["name"],
		source.stats_current["unit_name"],
		target.stats_current["unit_name"],
		value,
		crit,
		overkill
	)
func combat_event_heal(
	spell: Dictionary,
	source: CharacterBody3D,
	target: CharacterBody3D,
	value: int
):
	# query base value of event if not prescribed
	if value == -1:
		value = value_query(
			spell["value_modifier"],
			source.stats_current[spell["value_base"]],
			source.stats_current["heal_modifier"][spell["effecttype"]],
			target.stats_current["heal_taken_modifier"][spell["effecttype"]]
		)
	# determine critical hit
	var crit = 0
	if spell["can_crit"] == 1:
		crit = is_critical(spell["crit_chance_modifier"],source.stats_current["crit_chance"])
		value = value * (1 + crit * spell["crit_magnitude_modifier"])
	# apply healing
	var overheal = apply_heal(value,target)
	# show floating combat text for source via rpc, if source is player
	if source.is_in_group("player"):
		# rpc call to player scene, which calls ui function
		pass
	# write to log
	log_heal(
		spell["name"],
		source.stats_current["unit_name"],
		target.stats_current["unit_name"],
		value,
		crit,
		overheal
	)
func combat_event_dot():
	# initialize dot scene
	# add dot scene to target
	# add dot to dot dict of target
	pass
func combat_event_absorb():
	# calculate absorb value
	# initialize absorb scene
	# add absorb scene to target
	# add absorb to absorb dict of target
	pass
func combat_event_buff():
	# add buff to buff dict of target
	pass

####################################################################################################
# CHECKS
func is_critical(crit_modifier: float, crit_base: float):
	# get random number
	var random = RandomNumberGenerator.new()
	random.randomize()
	var p: float = randf()
	if p <= crit_base + crit_modifier:
		return 1
	return 0
func is_avoid(avoidance: float):
	var random = RandomNumberGenerator.new()
	random.randomize()
	var p: float = randf()
	if p <= avoidance:
		return true
	return false

####################################################################################################
# VALUE APPLICATION
func apply_damage(value: int, target: CharacterBody3D):
	var overkill = value - target.stats_current["health_current"]
	target.stats_current["health_current"] = max(0,target.stats_current["health_current"]-value)
	return overkill
func apply_heal(value: int, target: CharacterBody3D):
	var overheal = target.stats_current["health_current"]+value - target.stats_current["health_max"]
	target.stats_current["health_current"] = min(
		target.stats_current["health_current"]+value,
		target.stats_current["health_max"]
	)
	return overheal

####################################################################################################
# LOG MESSAGES
func log_damage(
	spell_name: String,
	source_name: String,
	target_name: String,
	value: int,
	crit: int,
	overkill: int
):
	var crit_suffix = ""
	if crit == 1:
		crit_suffix = " (critical)"
	var overkill_suffix = ""
	if overkill > 0:
		overkill_suffix = " (%s overkill)" % overkill
	print(
		"%s hits %s with %s for %s%s%s."%
		[source_name, target_name, spell_name, value, crit_suffix, overkill_suffix]
	)
func log_heal(
	spell_name: String,
	source_name: String,
	target_name: String,
	value: int,
	crit: int,
	overheal: int
):
	var crit_suffix = ""
	if crit == 1:
		crit_suffix = " (critical)"
	var overheal_suffix = ""
	if overheal > 0:
		overheal_suffix = " (%s overheal)" % overheal
	print(
		"%s heals %s with %s for %s%s%s."%
		[source_name, target_name, spell_name, value, crit_suffix, overheal_suffix]
	)
func log_avoid(spell_name: String, source_name: String , target_name: String):
	print("%s avoided %s of %s."%[source_name, spell_name, target_name])

#### stat calculations
####################################################################################################
## calculate all stats when changing class or talents, should only be done outside of combat
#func stat_calculation_full(body):
	## loop through all stats
	#for statkey in body.stats_curr:
		## skip if current health or resource
		#if statkey in ["health_current","resource_current"]:
			#continue
		## call single stat calculation
		#single_stat_calculation(body,statkey)
#
## change single stat when buff or debuff is applied
#func single_stat_calculation(body,statkey):
	#var stat_add : int = 0
	#var stat_mult : float = 1.
	## get additive and multiplicative modifiers
	#if body.stats_base["stat_add"].has(statkey):
		#for value in body.stats_base["stat_add"][statkey].keys():
			#stat_add = stat_add + body.stats_base["stat_add"][statkey][value]
	#if body.stats_base["stat_mult"].has(statkey):
		#for value in body.stats_base["stat_mult"][statkey].keys():
			#stat_mult = stat_mult * body.stats_base["stat_mult"][statkey][value]
	## apply to current stats
	#body.stats_curr[statkey] = (body.stats_base[statkey] + stat_add) * stat_mult
	## adjust current health and resource if above maximum
	#if statkey == "health_max" and body.stats_curr["health_current"] > body.stats_curr["health_max"]:
		#body.stats_curr["health_current"] = body.stats_curr["health_max"]
	#if statkey == "resource_max" and body.stats_curr["resource_current"] > body.stats_curr["resource_max"]:
		#body.stats_curr["resource_current"] = body.stats_curr["resource_max"]
#
#### write to log
####################################################################################################
#func write_to_log_damage(spell,source,target,is_crit,value):
	#var ending : String = "."
	#if is_crit:
		#ending = " (critical)."
	#print("%s hits %s with %s for %.f %s damage%s"%\
		#[source.stats_curr["unit_name"],target.stats_curr["unit_name"],\
		 #spell["name"],value,spell["damagetype"],ending])
#func write_to_log_absorb(spell,source,target,absorb,is_crit,value):
	#var ending : String = "."
	#if is_crit:
		#ending = " (critical)."
	#print("%s of %s absorbs %.f damage of %s used on %s by %s%s"%\
		#[absorb.spellname,absorb.absorb_source,value,spell["name"],\
		#target.stats_curr["name"],source.stats_curr["name"],ending])
#func write_to_log_heal(spell,source,target,is_crit,value):
	#var ending : String = "."
	#if is_crit:
		#ending = " (critical)."
	#print("%s heals %s with %s for %.f %s healing%s"%\
		#[source.stats_curr["unit_name"],target.stats_curr["unit_name"],\
		 #spell["name"],value,spell["healtype"],ending])
#func write_to_log_avoid(spell,source,target):
	#print("%s has avoided %s from %s."%[target.stats_curr["unit_name"],spell["name"],source.stats_curr["unit_name"]])
#func write_to_log_aura(spell,source,target):
	#print("%s applies %s to %s"%[source.stats_curr["unit_name"],spell["name"],target.stats_curr["unit_name"]])
#func write_to_log_aura_reapply(spell,source,target):
	#print("%s reapplies %s to %s"%[source.stats_curr["unit_name"],spell["name"],target.stats_curr["unit_name"]])
#func write_to_log_aura_fade(spell,source,target):
	#print("%s's %s faded from %s"%[source.stats_curr["unit_name"],spell["name"],target.stats_curr["unit_name"]])
