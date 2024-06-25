extends Node

# Mending Waters
var spell_base : Dictionary
var spell_curr : Dictionary
var cd_timer = Timer.new()
var on_cd = false
var actionbar = []

func _ready():
	var json_dict = JSON.parse_string(FileAccess.get_file_as_string("res://data/db_spells.json"))
	spell_base = json_dict["12"]
	spell_curr = spell_base.duplicate(true)
	cd_timer.one_shot = true
	cd_timer.connect("timeout",set_ready.bind())
	add_child(cd_timer)

func trigger():
	print("spell 12 triggered")
	var sourcenode = get_parent().get_parent()
	print("sourcenode set to %s"%sourcenode)
	# check cooldown
	print("checking cd")
	if on_cd:
		print("on cooldown")
		return
	# check resource cost
	print("checking resource sufficiency")
	if sourcenode.stats_curr["resource_current"] < spell_curr["resource_cost"]:
		print("insufficient resources")
		return
	# check target
	print("check target")
	var spell_target = sourcenode.get_spell_target(spell_curr)
	if typeof(spell_target) == TYPE_STRING and spell_target == "no_legal_target":
		print("no legal target")
		return
	# check range
	print("check range")
	if sourcenode.global_transform.origin.distance_to(spell_target.global_transform.origin) - spell_target.stats_curr["size"] > spell_curr["range"]:
		print("out of range")
		return
	# apply resource cost
	print("apply cost")
	sourcenode.stats_curr["resource_current"] = min(sourcenode.stats_curr["resource_current"]-spell_curr["resource_cost"],sourcenode.stats_curr["resource_max"])
	# send gcd
	print("send gcd")
	get_parent().send_gcd
	# fire spell
	print("firing spell")
	Combat.event_heal(spell_curr,sourcenode,spell_target)

func trigger_cd(duration):
	# start timer
	cd_timer.wait_time = duration
	cd_timer.start()
	on_cd = true
	# start cd swipe
	for ab in actionbar:
		ab.start_cd(duration)

func set_ready():
	on_cd = false
	for ab in actionbar:
		ab.end_cd()

# role swap effects
func swap_tank():
	pass
func swap_heal():
	pass
func swap_meleedps():
	pass
func swap_rangedps():
	pass
	
# talent effects  
