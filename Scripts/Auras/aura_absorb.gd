extends Node

var exp_timer = Timer.new()
@export var absorb_value : int
var absorb_source : String
var spellname : String

# general aura scene for dots, hots, buffs and debuffs
func initialize(spell,source,target):
	# add to absorb dict on target
	target.absorb_dict["%s %s"%[source.stats_curr["name"],spell["name"]]] = self
	# declare source and spellname
	absorb_source = source.stats_curr["name"]
	spellname = spell["name"]
	# determine absorb amount
	absorb_value = int(floor(source.stats_curr[spell["valuebase"]] *\
				spell["primary_modifier"] * \
				source.stats_curr["heal_modifier"][spell["healtype"]] * \
				target.stats_curr["heal_taken_modifier"][spell["healtype"]]))
	# set duration and start timer
	duration(spell,source,target)

func reinitialize(spell,source,target):
	calc_absorb_value(spell,source,target)
	exp_timer.stop()
	exp_timer.wait_time = float(spell["duration"])
	exp_timer.start()

func calc_absorb_value(spell,source,target):
	if spell["valuetype"] == "absolute":
		absorb_value = int(floor(source.stats_curr["primary"] * \
						spell["primary_modifier"] * \
						source.stats_curr["heal_modifier"][spell["healtype"]] * \
						target.stats_curr["heal_taken_modifier"][spell["healtype"]]))
	elif spell["valuetype"] == "relative":
		absorb_value = int(floor(spell["primary_modifier"] * \
						source.stats_curr[spell["valuebase"]] * \
						source.stats_curr["heal_modifier"][spell["healtype"]] * \
						target.stats_curr["heal_taken_modifier"][spell["healtype"]]))

func duration(spell,source,target):
	# start timer
	exp_timer.one_shot = true
	exp_timer.wait_time = float(spell["duration"])
	exp_timer.connect("timeout",remove_aura.bind(spell,source,target))
	add_child(exp_timer)
	exp_timer.start()

func remove_aura(spell,source,target):
	# remove from absorb dict and remove scene
	target.absorb_dict.erase("%s %s"%[source.stats_curr["name"],spell["name"]])
	Combat.write_to_log_aura_fade(spell,source,target)
	queue_free()
