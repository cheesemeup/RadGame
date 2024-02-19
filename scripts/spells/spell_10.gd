# Fingers of Frost
extends BaseSpell

func _ready():
	initialize_base_spell("10")
	# connect to gcd signal of spell container

func trigger():
	# get source and target nodes
	var source = get_parent().get_parent()
	var target = get_spell_target(source)
	# set target to self if there is no target
	if target == null:
		target = source
	# check target legality
	if is_illegal_target(spell_current["targetgroup"],target):
		return 1
	# check for cooldown
	if is_on_cd():
		return 2
	# check resource availability
	if insufficient_resource(spell_current["resource_cost"],\
								source.stats_current["resource_current"]):
		return 3
	# check range
	if is_not_in_range(source.position,target.position,spell_current["range"]):
		return 4
	# check line of sight
	if is_not_in_line_of_sight(source,target.position):
		return 5
	# apply resource cost 
	# send gcd
	# apply spell cd if not on gcd
	# send event to combat script
