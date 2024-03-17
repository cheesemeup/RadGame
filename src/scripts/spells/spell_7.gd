extends Node

# Player Test HoT
var spell_base : Dictionary
var spell_curr : Dictionary
var cd_timer = Timer.new()
var on_cd = false

func _ready():
	var json_dict = JSON.parse_string(FileAccess.get_file_as_string("res://data/db_spells.json"))
	spell_base = json_dict["7"]
	spell_curr = spell_base.duplicate(true)
	cd_timer.one_shot = true
	cd_timer.connect("timeout",set_ready.bind())
	add_child(cd_timer)

func trigger():
	var sourcenode = get_parent().get_parent()
	# check resource cost
	if sourcenode.stats_curr["resource_current"] < spell_curr["resource_cost"]:
		print("insufficient resources")
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
	sourcenode.stats_curr["resource_current"] -= spell_curr["resource_cost"]
	# send gcd
	get_parent().send_gcd()
	# fire spell
	Combat.event_aura(spell_curr,sourcenode,spell_target)

func start_cd(duration):
	cd_timer.wait_time = duration
	cd_timer.start()
	on_cd = true

func set_ready():
	on_cd = false
