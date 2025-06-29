# Player Test Buff
extends BaseSpell

var spell_heal: Dictionary = {}

func _ready():
	initialize_base_spell("8")
	spell_heal["spelltype"] = "heal"
	spell_heal["can_crit"] = 0

func trigger():
	## get source and target nodes
	#var source = get_parent().get_parent()
	var target = get_spell_target()
	# set target to self if there is no target
	if target == null:
		target = source
	# check target legality
	if is_illegal_target(spell_current["targetgroup"]):
		print("illegal target")
		return 1
	# check for cooldown
	if is_on_cd():
		print("on cd")
		return 2
	# check range
	if is_not_in_range(source.position,target.position,spell_current["max_range"]):
		print("not in range")
		return 4
	# check line of sight, NOT FUNCTIONAL
	#if is_not_in_line_of_sight(source,target.position):
		#print("not in line of sight")
		#return 5
	# send gcd
	if spell_current["on_gcd"] == 1:
		get_parent().send_gcd()
	# send event to combat script
	print("sending combat event")
	Combat.combat_event_aura_entrypoint(spell_current,source,target)
	# also send heal, to apply to the buffed maximum health to current health, and count as heal
	Combat.combat_event_entrypoint(spell_heal,source,target,spell_current["modify_value"][1])
