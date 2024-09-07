# Mending Water
extends BaseSpell

func _ready():
	initialize_base_spell("12")

func trigger():
	# get target node
	var target = get_spell_target()
	# set target to self if there is no target
	if target == null:
		target = source
	# check target legality
	if is_illegal_target(spell_current["targetgroup"]):
		target = source
	# check for cooldown
	if is_on_cd():
		return 2
	# check resource availability
	if insufficient_resource(
		spell_current["resource_cost"],
		source.stats_current["resource_current"]
	):
		return 3
	# check range
	if is_not_in_range(source.position,target.position,spell_current["max_range"]):
		return 4
	# check line of sight, NOT FUNCTIONAL
	#if is_not_in_line_of_sight(source,target.position):
		#return 5
	# apply resource cost 
	source.stats_current["resource_current"] = update_resource(
		spell_current["resource_cost"],
		source.stats_current["resource_current"],
		source.stats_current["resource_max"]
	)
	# send gcd
	if spell_current["on_gcd"] == 1:
		get_parent().send_gcd()
	# send event to combat script
	Combat.combat_event_entrypoint(spell_current,source,target)
	# end cast
	#finish_cast()
	return 0
