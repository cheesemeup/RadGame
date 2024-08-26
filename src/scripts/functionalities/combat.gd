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
	source: CharacterBody3D,
	target: CharacterBody3D,
	value: int = -1
) -> void:
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
) -> void:
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
) -> void:
	if remove:
		remove_buff(spell,source.stats_current["unit_name"],target)
		return
	apply_buff(spell,source.stats_current["unit_name"],target)

func value_query(coeff: float, base: int, mod_inc: float, mod_dec: float) -> int:
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
) -> void:
	# query base value of event if not prescribed
	if value == -1:
		value = value_query(
			spell["value_modifier"],
			source.stats_current[spell["value_base"]],
			source.stats_current["damage_modifier_%s"%spell["effecttype"]],
			target.stats_current["defense_modifier_%s"%spell["effecttype"]]
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
		#rpc call to player scene, which calls ui function
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
	# check if target died
	if overkill >= 0:
		target.is_dead = true

func combat_event_heal(
	spell: Dictionary,
	source: CharacterBody3D,
	target: CharacterBody3D,
	value: int
) -> void:
	# query base value of event if not prescribed
	if value == -1:
		value = value_query(
			spell["value_modifier"],
			source.stats_current[spell["value_base"]],
			source.stats_current["heal_modifier_%s"%spell["effecttype"]],
			target.stats_current["heal_taken_modifier_%s"%spell["effecttype"]]
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
) -> void:
	# reset aura if already present on target from same source
	var aura_list_name = "%s"%spell["name"]
	if spell["unique"] == 0:
		aura_list_name = "%s %s"%[aura_list_name,source.stats_current["unit_name"]]
	if target.aura_list.has(aura_list_name):
		# reset aura
		target.get_node("aura_container").get_node("%s_container"%spell["auratype"]).\
			get_node(aura_list_name).reinitialize(spell)
		log_aura(spell["name"],source.stats_current["unit_name"],target.stats_current["unit_name"])
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
) -> void:
	var aura_list_name = "%s"%spell["name"]
	if spell["unique"] == 0:
		aura_list_name = "%s %s"%[aura_list_name,source.stats_current["unit_name"]]
	target.aura_list.erase(aura_list_name)
	target.get_node("aura_container").get_node("%s_container"%spell["auratype"]).\
		get_node(aura_list_name).queue_free()
	log_aura_remove(spell["name"],source.stats_current["unit_name"],target.stats_current["unit_name"])

####################################################################################################
# CHECKS
func is_critical(crit_modifier: float, crit_base: float) -> int:
	# get random number
	var random = RandomNumberGenerator.new()
	random.randomize()
	var p: float = randf()
	if p <= crit_base + crit_modifier:
		return 1
	return 0

func is_avoid(avoidance: float) -> bool:
	var random = RandomNumberGenerator.new()
	random.randomize()
	var p: float = randf()
	if p <= avoidance:
		return true
	return false

####################################################################################################
# VALUE APPLICATION
func apply_damage(value: int, target: CharacterBody3D) -> int:
	var overkill = value - target.stats_current["health_current"]
	target.stats_current["health_current"] = max(0,target.stats_current["health_current"]-value)
	return overkill

func apply_absorb(
	value: int,
	target: CharacterBody3D,
	spell_name: String,
	source_name: String,
	target_name: String
) -> int:
	# loop through absorbs
	var absorb: Node
	var remove: Array = []
	for absorb_entry in target.absorb_array:
		absorb = target.get_node("aura_container").get_node("absorb_container").\
			get_node(absorb_entry[1])
		# compare absorb value to remaining damage value
		var absorbed_value: int
		if value >= absorb.remaining_value:
			absorbed_value = absorb.remaining_value
			absorb.remaining_value = 0
			remove.append(absorb)
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
		# adjust remaining damage value
		value -= absorbed_value
		if value == 0:
			break
	# remove depleted absorbs outside of the iteration
	for scene in remove:
		scene.remove_absorb()
	return value

func apply_heal(value: int, target: CharacterBody3D) -> int:
	var overheal = target.stats_current["health_current"]+value - target.stats_current["health_max"]
	target.stats_current["health_current"] = min(
		target.stats_current["health_current"]+value,
		target.stats_current["health_max"]
	)
	return overheal

####################################################################################################
# STAT MODIFICATION
func apply_buff(spell: Dictionary, source_name: String, target: CharacterBody3D) -> void:
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

func remove_buff(spell: Dictionary, source_name: String, target: CharacterBody3D) -> void:
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
func calc_current_from_base_partial(target: CharacterBody3D, stat_list: Array) -> void:
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

func calc_current_from_base_full(target: CharacterBody3D) -> void:
	# calculate all stats from base values and add and mult modifiers
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
) -> void:
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
) -> void:
	var source_name_poss: String
	if source_name[-1] == "s":
		source_name_poss = "%s'"%source_name
	else:
		source_name_poss = "%s's"%source_name
	print("%s absorbs %s damage of %s %s with %s of %s"%[
		target_name,
		absorb_value,
		source_name_poss,
		spell_name,
		absorb_name,
		absorb_source
	])

func log_heal(
	spell_name: String,
	source_name: String,
	target_name: String,
	value: int,
	crit: int,
	overheal: int
) -> void:
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

func log_aura(spell_name: String, source_name: String, target_name: String) -> void:
	print("%s applies %s to %s"%[source_name, spell_name, target_name])

func log_aura_remove(spell_name: String, source_name: String, target_name: String) -> void:
	var source_name_poss: String
	if source_name[-1] == "s":
		source_name_poss = "%s'"%source_name
	else:
		source_name_poss = "%s's"%source_name
	print("%s application of %s fades on %s."%[source_name_poss, spell_name, target_name])

func log_avoid(spell_name: String, source_name: String , target_name: String) -> void:
	print("%s avoided %s of %s."%[source_name, spell_name, target_name])

func log_interact(source_name: String, target_name: String) -> void:
	print("%s interacts with %s"%[source_name, target_name])

func log_death(source_name: String) -> void:
	print("%s has died"%source_name)
