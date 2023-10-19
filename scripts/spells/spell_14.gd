extends Node

# Deep Current
var spell_base : Dictionary
var spell_curr : Dictionary
var cd_timer = Timer.new()
var on_cd = false
var actionbar = []

func _ready():
	var json_dict = JSON.parse_string(FileAccess.get_file_as_string("res://data/db_spells.json"))
	spell_base = json_dict["14"]
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
	# apply aura
	Combat.event_aura_general(spell_curr,sourcenode,sourcenode)
	# cooldown
	trigger_cd(spell_curr["cooldown"])
	# start cd swipe
	for ab in actionbar:
		ab.start_cd(spell_curr["cooldown"])

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
