# Big Builder
extends BaseSpell

func _ready():
	ID = "17"
	initialize_base_spell(ID)

func trigger():
	# do not allow casting if already casting
	if source.is_casting:
		check_queue()
		return 6
	# get target node
	target = get_spell_target()
	# check target legality
	if is_illegal_target(spell_current["targetgroup"]):
		return 1
	# check for cooldown
	if is_on_cd():
		check_queue()
		return 2
	# check range
	if is_not_in_range(source.position,target.position,spell_current["max_range"]):
		return 4
	# after passing all checks, start cast
	start_cast(cast_success)
	return 0


func cast_success():
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
