# Fingers of Frost
extends BaseSpell

func _ready():
	initialize_base_spell("10")

func trigger():
	# get source and target nodes
	var source = get_parent().get_parent()
	var target = get_spell_target(source)
	# set target to self if there is no target
	if target == null:
		target = source
	# check target legality
	if is_illegal_target(spell_current["targetgroup"], target):
		return 1
	# check for cooldown
	if is_on_cd():
		return 2
	# check resource availability
	print("checking resource")
	if insufficient_resource(
		spell_current["resource_cost"],
		source.stats_current["resource_current"]
	):
		print("insufficient resources")
		return 3
	# check range
	print("checking range")
	if is_not_in_range(source.position,target.position,spell_current["range"]):
		print("not in range")
		return 4
	# check line of sight, NOT FUNCTIONAL
	print("checking line of sight")
	if is_not_in_line_of_sight(source,target.position):
		print("not in line of sight")
		return 5
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
	print("triggering event in combat script")
	Combat.combat_event_entrypoint(spell_current,source,target)
