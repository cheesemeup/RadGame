# Abyssal Shell
extends BaseSpell

func _ready():
	initialize_base_spell("11")

func trigger():
	# get source and target nodes
	var source = get_parent().get_parent()
	# check for cooldown
	if is_on_cd():
		return 2
	# check resource availability
	if insufficient_resource(
		spell_current["resource_cost"],
		source.stats_current["resource_current"]
	):
		return 3
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
	Combat.combat_event_aura_entrypoint(spell_current,source,source)
