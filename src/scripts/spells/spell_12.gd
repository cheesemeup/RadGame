# Mending Water
extends BaseSpell

func _ready():
	ID = "12"
	initialize_base_spell(ID)

func trigger():
	# do not allow casting if already casting
	if source.is_casting:
		check_queue()
		return 6
	# get target node
	target = get_spell_target()
	# set target to self if there is no target
	if target == null:
		target = source
	# check target legality
	if is_illegal_target(spell_current["targetgroup"]):
		target = source
	# check for cooldown
	if is_on_cd():
		check_queue()
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
	# after passing all checks, start cast
	var return_value = start_cast(cast_success)
	return 0


func cast_success() -> void:
	# apply resource cost 
	source.stats_current["resource_current"] = update_resource(
		spell_current["resource_cost"],
		source.stats_current["resource_current"],
		source.stats_current["resource_max"]
	)
	# send event to combat script
	Combat.combat_event_entrypoint(spell_current,source,target)
	# end cast
	finish_cast(cast_success)
