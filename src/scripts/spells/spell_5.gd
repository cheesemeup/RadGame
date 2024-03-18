# Player Test Heal
extends BaseSpell

func _ready():
	initialize_base_spell("5")

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
	# check range
	if is_not_in_range(source.position,target.position,spell_current["max_range"]):
		return 4
	# check line of sight, NOT FUNCTIONAL
	if is_not_in_line_of_sight(source,target.position):
		return 5
	# send gcd
	if spell_current["on_gcd"] == 1:
		get_parent().send_gcd()
	# send event to combat script
	Combat.combat_event_entrypoint(spell_current,source,target)
