# Fingers of Frost
extends BaseSpell

func _ready():
	initialize_base_spell("10")
	# connect to gcd signal of spell container

func trigger():
	print("trigger entered")
	# get source and target nodes
	print("setting source")
	var source = get_parent().get_parent()
	print("setting target")
	var target = get_spell_target(source)
	print("target: ",target)
	# set target to self if there is no target
	if target == null:
		print("resetting target to self")
		target = source
	# check target legality
	print("checking legality of target", target)
	if is_illegal_target(spell_current["targetgroup"],target):
		print("illegal target: ",spell_current["targetgroup"],target)
		return 1
	# check for cooldown
	print("checking cd")
	if is_on_cd():
		print("spell on cd")
		return 2
	# check resource availability
	print("checking resource")
	if insufficient_resource(spell_current["resource_cost"],\
								source.stats_current["resource_current"]):
		print("insufficient resources")
		return 3
	# check range
	print("checking range")
	if is_not_in_range(source.position,target.position,spell_current["range"]):
		print("not in range")
		return 4
	# check line of sight
	print("checking line of sight")
	if is_not_in_line_of_sight(source,target.position):
		print("not in line of sight")
		return 5
	# apply resource cost 
	print("applying resource cost")
	# send gcd
	print("sending gcd")
	# apply spell cd if not on gcd
	print("applying spell cd")
	# send event to combat script
	print("triggering event in combat script")
