extends Node

####################################################################################################
# ENTRYPOINTS
func combat_event_entrypoint(
	spell: Dictionary,
	source: CharacterBody3D,
	target: CharacterBody3D,
	value: int=-1
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
		value = value_query(
			spell["value_modifier"],
			source.stats_current[spell["value_base"]],
			source.stats_current["damage_modifier"][spell["effecttype"]],
			target.stats_current["damage_taken_modifier"][spell["effecttype"]]
		)
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
	apply_damage(value,target)
	# show floating combat test for source via rpc, if source is player
	if source.is_in_group("player"):
		#rpc call to player scene, which call ui function
		pass
	# write to log
	#log_damage(
		#spell["name"],
		#source.stats_current["unit_name"],
		#target.stats_current["unit_name"],
		#value
	#)
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
func combat_event_aura():
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
	target.stats_current["health_current"] = max(0,target.stats_current["health_current"]-value)
func apply_heal(value: int, target: CharacterBody3D):
	var overheal = target.stats_current["health_current"]+value - target.stats_current["health_max"]
	target.stats_current["health_current"] = min(
		target.stats_current["health_current"]+value,
		target.stats_current["health_max"]
	)
	return overheal

####################################################################################################
# LOG MESSAGES
#func log_damage(spell_name: String, source_name: String , target_name: String, value: int, crit: int, kill: bool):
	#print("%s hits %s with %s for %s."%[source_name, target_name, spell_name, value])
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
		crit_suffix = "(Critical)"
	var overheal_suffix = ""
	if overheal > 0:
		overheal_suffix = "(%s overheal)" % overheal
	print("%s heals %s with %s for %s%s." % [source_name, target_name, spell_name, value, crit_suffix])
func log_avoid(spell_name: String, source_name: String , target_name: String):
	print("%s avoided %s of %s."%[source_name, spell_name, target_name])

## preload common auras
#var aura_general = preload("res://scenes/auras/aura_general.tscn")
#var aura_absorb = preload("res://scenes/auras/aura_absorb.tscn")
#
################################################################
#### COMBAT EVENTS
################################################################
#func combat_event_unprescribed(spell,source,target):
	#if combat_event_rng_check(spell.is_avoidable,target.stats.stats_current.avoidance,spell.avoidance_modifier):
		#write_log_avoid(source.unit_name,target.unit_name,spell.spell_name)
		#return 1
	#var is_crit = combat_event_rng_check(
		#spell.can_crit,source.stats.stats_current.crit_chance,spell.crit_chance_modifier
	#)
	#var value = combat_event_value_primary(spell,source,target,is_crit)
	#apply_health_change(target,value)
	#write_log_health_change(source.unit_name,target.unit_name,spell,value,is_crit)
	#return 0
#func combat_event_prescribed(spell,source,target,value,is_crit):
	#if combat_event_rng_check(spell.is_avoidable,target.stats.stats_current.avoidance,spell.avoidance_modifier):
		#write_log_avoid(source.unit_name,target.unit_name,spell.spell_name)
		#return 1
	#apply_health_change(target,value)
	#write_log_health_change(source.unit_name,target.unit_name,spell,value,is_crit)
	#return 0
################################################################
#### RNG CHECKS
################################################################
#func combat_event_rng_check(capability,probability,modifier):
	## get random number
	#var random = RandomNumberGenerator.new()
	#random.randomize()
	#var p : float = randf()
	## check if below avoidance probability, set avoid to 1 if true
	#if p <= probability + modifier:
		#return capability
	#return 0
################################################################
#### UTILITY
################################################################
#func combat_event_value_primary(spell,source,target,is_crit):
	#var crit_modifier = 1. + is_crit * (1. + spell.crit_multiplier_modifier)
	#var value = int(floor(source.stats.stats_current.primary * \
				#spell.base_modifier * \
				#source.stats.stats_current.modifier[spell.event_type][0][spell.effect_type] * \
				#target.stats.stats_current.modifier[spell.event_type][1][spell.effect_type] * \
				#crit_modifier))
	## change sign if damage
	#value += (spell.event_type - 1) * 2 * value
	#return value
#func apply_health_change(target,value):
	#target.stats.stats_current.health_current = clampi(
		#target.stats.stats_current.health_current+value,0,target.stats.stats_current.health_max
	#)
################################################################
#### LOG
################################################################
#func write_log_avoid(source,target,spell):
	#print("%s avoided %s of %s" % [target,spell,source])
#func write_log_health_change(source,target,spell,value,is_crit):
	#var crit_appendix = ""
	#if is_crit:
		#crit_appendix = "(critical)"
	#if spell.event_type == 0:
		#print("%s hits %s with %s for %i %s" % [source,target,spell.spell_name,value,crit_appendix])
	#else:
		#print("%s heals %s with %s for %i %s", [source,target,spell.spell_name,value,crit_appendix])
#
#func check_avoidance(target):
	#var avoid : int = 0
	## get random number
	#var random = RandomNumberGenerator.new()
	#random.randomize()
	#var p : float = randf()
	## check if below avoidance probability, set avoid to 1 if true
	#if p <= target.stats_curr["avoidance"]:
		#avoid = 1
	#return avoid
#
#func check_crit(spell,source):
	#var is_crit : int = 0
	## get random number
	#var random = RandomNumberGenerator.new()
	#random.randomize()
	#var p : float = randf()
	## check if below crit probability, set crit to 1 if true
	#if p <= source.stats_curr["crit_chance"]+spell["crit_chance_modifier"]:
		#is_crit = 1
	#return is_crit
#
#func event_damage(spell,source,target,value:=-1):
	## check avoidance
	#var avoid = spell["avoidable"] * check_avoidance(target)
	#if avoid == 1:
		#write_to_log_avoid(spell,source,target)
		#return
	## use value as noncrit if prescribed
	#if value != -1:
		#apply_damage(spell,value,source,target,0)
		#return value
	## check for crit
	#var is_crit : int = 0
	#if spell["can_crit"] == 1:
		#is_crit = check_crit(spell,source)
	## calculate and apply damage
	#var crit_modifier = 1. + is_crit * (1. + spell["crit_damage_modifier"])
	#value = int(floor(source.stats_curr[spell["valuebase"]] *\
				#spell["primary_modifier"] *\
				#source.stats_curr["damage_modifier"][spell["damagetype"]] * \
				#target.stats_curr["defense_modifier"][spell["damagetype"]] * \
				#crit_modifier))
	## deal damage through absorbs
	#apply_damage(spell,value,source,target,is_crit)
	#return value
#
#func event_heal(spell,source,target,value:=-1):
	## use value as noncrit if prescribed
	#if value != -1:
		#target.stats.stats_current.health_current = min(target.stats.stats_current.health_current+value,target.stats.stats_current.health_max)
		#write_to_log_heal(spell,source,target,0,value)
		#return value
	## check for crit
	#var is_crit : int = 0
	#if spell["can_crit"] == 1:
		#is_crit = check_crit(spell,source)
	## calculate and apply healing
	#var crit_modifier : float =  1. + is_crit * (1. + spell["crit_heal_modifier"])
	#value = int(floor(source.stats_curr[spell["valuebase"]] *\
				#spell["primary_modifier"] * \
				#source.stats_curr["heal_modifier"][spell["healtype"]] * \
				#target.stats_curr["heal_taken_modifier"][spell["healtype"]] * \
				#crit_modifier))
	#target.stats.stats_current.health_current = min(target.stats.stats_current.health_current+value,target.stats.stats_current.health_max)
	#write_to_log_heal(spell,source,target,is_crit,value)
	#return value
#
#func event_aura_general(spell,source,target):
	## check if target already has same aura from same source active for hot/dot
	#if spell["auratype"] == "damage" or spell["auratype"] == "heal":
		#var key_name : String = "%s %s"%[source.stats_curr["name"],spell["name"]]
		#if target.aura_dict.has(key_name):
			## remove before reapplication
			#target.aura_dict[key_name].reinitialize(spell)
			#write_to_log_aura_reapply(spell,source,target)
			#return
	## source-agnostic for buff/debuff
	#if spell["auratype"] == "buff" or spell["auratype"] == "debuff":
		#var key_name : String = "%s"%[spell["name"]]
		#if target.aura_dict.has(key_name):
			## remove before reapplication
			#target.aura_dict[key_name].reinitialize(spell)
			#write_to_log_aura_reapply(spell,source,target)
			#return
	#var aura = aura_general.instantiate()
	#target.get_node("auras").add_child(aura)
	#aura.initialize(spell,source,target)
	#write_to_log_aura(spell,source,target)
#
#func event_absorb(spell,source,target):
	## check if target already has same aura from same source active
	#var key_name : String = "%s %s"%[source.stats_curr["name"],spell["name"]]
	#if target.absorb_dict.has(key_name):
		## reset if already present
		#target.absorb_dict[key_name].reinitialize(spell,source,target)
		#write_to_log_aura_reapply(spell,source,target)
		#return
	#var aura = aura_absorb.instantiate()
	#target.get_node("absorbs").add_child(aura)
	#aura.initialize(spell,source,target)
	#write_to_log_aura(spell,source,target)
#
#func apply_damage(spell,value,source,target,is_crit):
	## check for absorbs
	#for absorb in target.get_node("absorbs").get_children():
		## if shield fully absorbs hit without being depleted
		#if value < absorb.absorb_value:
			#absorb.absorb_value -= value
			#write_to_log_absorb(spell,source,target,absorb,is_crit,value)
			#return
		## if shield fully absorbs hit and is depleted
		#elif value == absorb.absorb_value:
			#absorb.queue_free()
			#write_to_log_absorb(spell,source,target,absorb,is_crit,value)
			#return
		## if hit value is larger than absorb value, reduce remaining value and remove absorb node
		#elif value > absorb.absorb_value:
			#value -= absorb.absorb_value
			#write_to_log_absorb(spell,source,target,absorb,is_crit,absorb.absorb_value)
			#absorb.queue_free()
	## deal unabsorbed damage
	#target.stats.stats_current.health_current = max(target.stats.stats_current.health_current-value,0)
	#write_to_log_damage(spell,source,target,is_crit,value,)
#
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
