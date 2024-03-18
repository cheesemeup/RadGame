extends Node

####################################################################################################
# PRELOAD
var dot_preload = preload("res://scenes/functionalities/aura_dot.tscn")
var buff_preload = preload("res://scenes/functionalities/aura_buff.tscn")
var absorb_preload = preload("res://scenes/functionalities/aura_absorb.tscn")

####################################################################################################
# ENTRYPOINTS
func combat_event_entrypoint(
	spell: Dictionary,
	source,
	target: CharacterBody3D,
	value: int = -1
):
	# determine type of event and call appropriate function
	if spell["spelltype"] == "damage":
		combat_event_damage(spell,source,target,value)
	if spell["spelltype"] == "heal":
		combat_event_heal(spell,source,target,value)

func combat_event_aura_entrypoint(
	spell: Dictionary,
	source: CharacterBody3D,
	target: CharacterBody3D,
	remove: bool = false
):
	# apply and remove aura scenes
	if remove:
		combat_event_aura_remove(spell,source,target)
		return
	combat_event_aura(spell,source,target)

func buff_application(
	spell: Dictionary,
	source: CharacterBody3D,
	target: CharacterBody3D,
	remove: bool = false
):
	if remove:
		remove_buff(spell,source.stats_current["unit_name"],target)
		return
	apply_buff(spell,source.stats_current["unit_name"],target)

func value_query(coeff: float, base: int, mod_inc: float, mod_dec: float):
	# returns the value of a damage or healing spell based on the coefficient, the base value stat,
	# and the two applicable modifiers. Used for combat events and for snapshotting values.
	return int(floor(coeff * base * mod_inc * mod_dec))

####################################################################################################
# COMBAT EVENTS
func combat_event_damage(
	spell: Dictionary,
	source,
	target: CharacterBody3D,
	value: int
):
	# query base value of event if not prescribed
	if value == -1:
		value = value_query(
			spell["value_modifier"],
			source.stats_current[spell["value_base"]],
			source.stats_current["damage_modifier"][spell["effecttype"]],
			target.stats_current["defense_modifier"][spell["effecttype"]]
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
	# go through absorbs
	if not target.get_node("aura_container").get_node("absorb_container").get_children() == []:
		value = apply_absorb(
			value,
			target,
			spell["name"],
			source.stats_current["unit_name"],
			target.stats_current["unit_name"]
		)
	# return if damage is fully absorbed
	if value == 0:
		return
	# apply remaining damage
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

func combat_event_aura(
	spell: Dictionary,
	source: CharacterBody3D,
	target: CharacterBody3D
):
	# reset aura if already present on target from same source
	var aura_list_name = "%s"%spell["name"]
	if spell["unique"] == 0:
		aura_list_name = "%s %s"%[aura_list_name,source.stats_current["unit_name"]]
	if target.aura_list.has(aura_list_name):
		# reset aura
		target.get_node("aura_container").get_node("%s_container"%spell["auratype"]).\
			get_node(aura_list_name).reinitialize(spell)
		return
	# initialize aura scene
	var aura_scene
	if spell["auratype"] == "dot" or spell["auratype"] == "hot":
		aura_scene = dot_preload.instantiate()
	elif spell["auratype"] == "buff" or spell["auratype"] == "debuff":
		aura_scene = buff_preload.instantiate()
	elif spell["auratype"] == "absorb":
		aura_scene = absorb_preload.instantiate()
	aura_scene.name = aura_list_name
	aura_scene.initialize(spell,source,target)
	# add aura scene to target
	target.get_node("aura_container").get_node("%s_container"%spell["auratype"]).\
		add_child(aura_scene)
	# add aura to aura_list of target
	target.aura_list.append(aura_list_name)
	log_aura(spell["name"],source.stats_current["unit_name"],target.stats_current["unit_name"])

func combat_event_aura_remove(
	spell: Dictionary,
	source: CharacterBody3D,
	target: CharacterBody3D
):
	var aura_list_name = "%s"%spell["name"]
	if spell["unique"] == 0:
		aura_list_name = "%s %s"%[aura_list_name,source.stats_current["unit_name"]]
	target.aura_list.erase(aura_list_name)
	target.get_node("aura_container").get_node("%s_container"%spell["auratype"]).\
		get_node(aura_list_name).queue_free()
	log_aura_remove(spell["name"],source.stats_current["unit_name"],target.stats_current["unit_name"])

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

func apply_absorb(
	value: int,
	target: CharacterBody3D,
	spell_name: String,
	source_name: String,
	target_name: String
):
	# loop through absorbs
	for absorb in target.get_node("aura_container").get_node("absorb_container").get_children():
		# compare absorb value to damage value
		var absorbed_value: int
		if value >= absorb.remaining_value:
			absorbed_value = absorb.remaining_value
			absorb.remove_absorb()
		else:
			absorbed_value = value
			absorb.remaining_value -= value
		# write to log
		log_absorb(
			spell_name,
			source_name,
			target_name,
			absorbed_value,
			absorb.aura_spell["name"],
			absorb.aura_source.stats_current["unit_name"]
		)
		# adjust value
		value -= absorbed_value
		if value == 0:
			break
	return value

func apply_heal(value: int, target: CharacterBody3D):
	var overheal = target.stats_current["health_current"]+value - target.stats_current["health_max"]
	target.stats_current["health_current"] = min(
		target.stats_current["health_current"]+value,
		target.stats_current["health_max"]
	)
	return overheal

####################################################################################################
# STAT MODIFICATION
func apply_buff(spell: Dictionary, source_name: String, target: CharacterBody3D):
	# apply buff in appropriate stat dicts, overwrites old value if already present
	var buffname = "%s"%spell["name"]
	if spell["unique"] == 0:
		buffname = "%s %s"%[buffname,source_name]
	for i in range(spell["modifies"].size()):
		if spell["modify_type"][i] == "add":
			target.stats_add[spell["modifies"][i]][buffname] = spell["modify_value"][i]
		elif spell["modify_type"][i] == "mult":
			target.stats_mult[spell["modifies"][i]][buffname] = spell["modify_value"][i]
	# calculate new current stats from base stats
	calc_current_from_base_partial(target,spell["modifies"])

func remove_buff(spell: Dictionary, source_name: String, target: CharacterBody3D):
	# remove buff in appropriate stat dicts
	var buffname = "%s"%spell["name"]
	if spell["unique"] == 0:
		buffname = "%s %s"%[buffname,source_name]
	for i in range(spell["modifies"].size()):
		if spell["modify_type"][i] == "add":
			target.stats_add[spell["modifies"][i]].erase(buffname)
		elif spell["modify_type"][i] == "mult":
			target.stats_mult[spell["modifies"][i]].erase(buffname)
	# calculate new current stats from base stats
	calc_current_from_base_partial(target,spell["modifies"])

####################################################################################################
# STAT CALCULATIONS
func calc_current_from_base_partial(target: CharacterBody3D, stat_list: Array):
	# calculate the listed stats from base values and add and mult modifiers
	var stat_add: int
	var stat_mult: float
	var diff: int = 0
	for stat in stat_list:
		# get total additive and multiplicative modifiers
		stat_add = 0
		stat_mult = 1
		if target.stats_add.has(str(stat)):
			for value in target.stats_add[stat].values():
				stat_add = stat_add + value
		if target.stats_mult.has(stat):
			for value in target.stats_mult[stat].values():
				stat_mult = stat_mult + value
		# if stat is health_max or resource_max, get difference to previous value
		if stat == "health_max" or stat == "resource_max":
			diff = target.stats_current[stat]
		# calculate final stat
		target.stats_current[stat] = (target.stats_base[stat] + stat_add) * stat_mult
		# calculate difference for health_max and resource_max
		if stat == "health_max" or stat == "resource_max":
			diff = target.stats_current[stat] - diff
		# for decrease, set current to either itself or new maximum, to not overcap
		if diff < 0:
			if stat == "health_max":
				target.stats_current["health_current"] = min(
				target.stats_current["health_current"],
				target.stats_current["health_max"]
			)
			if stat == "resource_max":
				target.stats_current["resource_current"] = min(
				target.stats_current["resource_current"],
				target.stats_current["resource_max"]
			)

func calc_current_from_base_full(target: CharacterBody3D):
	# calculate the listed stats from base values and add and mult modifiers
	var stat_add: int
	var stat_mult: float
	var diff: int = 0
	for stat in target.stats_current.keys():
		# get total additive and multiplicative modifiers
		stat_add = 0
		stat_mult = 1
		if target.stats_add.has(stat):
			for value in target.stat_add[stat].values():
				stat_add = stat_add + value
		if target.stats_mult.has(stat):
			for value in target.stat_mult[stat].values():
				stat_mult = stat_mult + value
		# if stat is health_max or resource_max, get difference to previous value
		if stat == "health_max" or stat == "resource_max":
			diff = target.stats_current[stat]
		# calculate final stat
		target.stats_current[stat] = (target.stats_base[stat] + stat_add) * stat_mult
		# calculate difference for health_max and resource_max
		if stat == "health_max" or stat == "resource_max":
			diff = target.stats_current[stat] - diff
		# for decrease, set current to either itself or new maximum, to not overcap
		if diff < 0:
			if stat == "health_max":
				target.stats_current["health_current"] = min(
				target.stats_current["health_current"],
				target.stats_current["health_max"]
			)
			if stat == "resource_max":
				target.stats_current["resource_current"] = min(
				target.stats_current["resource_current"],
				target.stats_current["resource_max"]
			)

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

func log_absorb(
	spell_name: String,
	source_name: String,
	target_name: String,
	absorb_value: int,
	absorb_name: String,
	absorb_source: String
):
	print("absorb log")
	var source_name_poss: String
	if source_name[-1] == "s":
		source_name_poss = "%s'"%source_name
	else:
		source_name_poss = "%s's"%source_name
	print("%s absorbs %s %s for %s with %s of %s"%[
		target_name,
		source_name_poss,
		spell_name,
		absorb_value,
		absorb_name,
		absorb_source
	])
	pass

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

func log_aura(spell_name: String, source_name: String, target_name: String):
	print("%s applies %s to %s"%[source_name, spell_name, target_name])

func log_aura_remove(spell_name: String, source_name: String, target_name: String):
	var source_name_poss: String
	if source_name[-1] == "s":
		source_name_poss = "%s'"%source_name
	else:
		source_name_poss = "%s's"%source_name
	print("%s application of %s fades on %s."%[source_name_poss, spell_name, target_name])

func log_avoid(spell_name: String, source_name: String , target_name: String):
	print("%s avoided %s of %s."%[source_name, spell_name, target_name])

func log_interact(source_name: String, target_name: String):
	print("%s interacts with %s"%[source_name, target_name])

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
