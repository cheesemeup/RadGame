# Fingers of Frost
extends BaseSpell

func _ready():
	initialize_base_spell("10")
	# connect to gcd signal of spell container

func trigger():
	# PUT A LOT OF THIS INTO BASE SPELL CLASS
	# get source and target nodes
	var source = get_parent().get_parent()
	var target = 0
	# check for cooldown
	if is_on_cd():
		return 1
	# check resource availability
	if insufficient_resource(spell_current["resource_cost"],\
								source.stats_current["resource_current"]):
		return 2
	# check range
	if is_not_in_range(source.position,target.position,spell_current["range"]):
		return 3
	# check line of sight
	if is_not_in_line_of_sight():
		return 3
	# apply resource cost
	# send gcd
	# apply spell cd if not on gcd
	# send event to combat script
