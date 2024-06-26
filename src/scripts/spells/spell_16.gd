# Barotrauma
extends BaseSpell

func _ready():
	ID = "16"
	initialize_base_spell(ID)

func trigger() -> int:
	# do not allow casting if already casting
	if source.is_casting:
		check_queue()
		return 6
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
	# CAST BEGIN
	# send gcd
	if spell_current["on_gcd"] == 1:
		get_parent().send_gcd()
	# start cast, link timer to cast_success
	start_cast(cast_success)
	return 0


func cast_success() -> void:
	# apply resource cost 
	source.stats_current["resource_current"] = update_resource(
		spell_current["resource_cost"],
		source.stats_current["resource_current"],
		source.stats_current["resource_max"]
	)
	# send event to combat script
	Combat.combat_event_aura_entrypoint(spell_current,source,source)
	# end cast
	finish_cast(cast_success)
