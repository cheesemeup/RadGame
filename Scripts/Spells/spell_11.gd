extends Node

# Abyssal Shell
var spell_base : Dictionary
var spell_curr : Dictionary
var cd_timer = Timer.new()
var on_cd = false
var actionbar = []

func _ready():
	var json_dict = JSON.parse_string(FileAccess.get_file_as_string("res://Data/db_spells.json"))
	spell_base = json_dict["11"]
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
	# check resource cost
	if sourcenode.stats_curr["resource_current"] < spell_curr["resource_cost"]:
		print("insufficient resources")
		return
	# apply resource cost
	sourcenode.stats_curr["resource_current"] = min(sourcenode.stats_curr["resource_current"]-spell_curr["resource_cost"],sourcenode.stats_curr["resource_max"])
	# fire spell
	Combat.combat_event(spell_curr,sourcenode,sourcenode)
	# cooldown
	cd_timer.wait_time = spell_curr["cooldown"]
	cd_timer.start()
	on_cd = true

func set_ready():
	on_cd = false

# role swap effects
func swap_tank():
	spell_curr["cooldown"] = 60
func swap_heal():
	spell_curr["cooldown"] = 120
func swap_meleedps():
	spell_curr["cooldown"] = 120
func swap_rangedps():
	spell_curr["cooldown"] = 120

# talent effects  
