extends Node

class_name BaseSpell

var spell_base: Dictionary
var spell_current: Dictionary
var result_strings
var cd_timer = Timer.new()
var on_cd = false

func _ready():
	cd_timer.one_shot = true
	cd_timer.connect("timeout",set_ready.bind())
	add_child(cd_timer)

func initialize_base_spell(spell_id: String):
	var json_dict = JSON.parse_string(FileAccess.get_file_as_string("res://data/db_spells.json"))
	spell_base = json_dict[spell_id]
	spell_current = spell_base.duplicate(true)
	result_strings = [
		"insufficient resources",
		"invalid target",
		"out of range"
	]

####################################################################################################
# CHECKS

####################################################################################################
# COOLDOWN
func trigger_cd(duration):
	# check if current cooldown exceeds requested cooldown
	if cd_timer.time_left > duration:
		return
	# start timer
	cd_timer.wait_time = duration
	cd_timer.start()
	on_cd = true
func set_ready():
	on_cd = false
