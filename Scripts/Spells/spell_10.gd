extends Node

# Fingers of Frost
var spell_base : Dictionary
var spell_curr : Dictionary
var cd_timer = Timer.new()
var on_cd = false
var actionbar = []

func _ready():
	var json_dict = JSON.parse_string(FileAccess.get_file_as_string("res://Data/db_spells.json"))
	spell_base = json_dict["10"]
	spell_curr = spell_base.duplicate(true)
	cd_timer.one_shot = true
	cd_timer.connect("timeout",set_ready.bind())
	add_child(cd_timer)

func trigger():
	var sourcenode = get_parent().get_parent()
	# check cooldown
	if on_cd:
		print("on cooldown")
		return
	# check target
	var spell_target = sourcenode.get_spell_target(spell_curr)
	if typeof(spell_target) == TYPE_STRING and spell_target == "no_legal_target":
		print("no legal target")
		return
	# check range
	if sourcenode.global_transform.origin.distance_to(spell_target.global_transform.origin) - spell_target.stats_curr["size"] > spell_curr["range"]:
		print("out of range")
		return
	# apply resource cost
	sourcenode.stats_curr["resource_current"] = min(sourcenode.stats_curr["resource_current"]-spell_curr["resource_cost"],sourcenode.stats_curr["resource_max"])
	# send gcd
	get_parent().send_gcd()
	# fire spell
	Combat.combat_event(spell_curr,sourcenode,spell_target)

func start_cd(duration):
	# start timer
	cd_timer.wait_time = duration
	cd_timer.start()
	on_cd = true
	# instantiate cd swipe scene

func set_ready():
	on_cd = false

# role swap effects
func swap_tank():
	spell_curr["damagetype"] = "magic"
func swap_heal():
	spell_curr["damagetype"] = "magic"
	spell_curr["resource_cost"] = 0
	spell_curr["range"] = 30
func swap_meleedps():
	spell_curr["damagetype"] = "physical"
func swap_rangedps():
	spell_curr["damagetype"] = "magic"
	spell_curr["range"] = 30

# talent effects  
