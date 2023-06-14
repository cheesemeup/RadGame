extends Node

var exp_timer = Timer.new()
var tick_timer = Timer.new()

# Player Test DoT
func initialize(spell,source,target):
	# set node name in parentparent script
	target.aura_dict["%s %s"%[source.stats_curr["name"],spell["name"]]] = {"node":self}
	# start tick timer
	tick(spell,source,target)
	# start timer with duration, if duration is finite
	if spell["duration"] > 0:
		duration(spell,source,target)

func tick(spell,source,target):
	# set up tick timer
	tick_timer.one_shot = false
	tick_timer.wait_time = float(spell["tick"])
	tick_timer.connect("timeout",tick_expires.bind(spell,source,target))
	add_child(tick_timer)
	tick_timer.start()

func tick_expires(spell,source,target):
	# send combat event on tick
	Combat.aura_tick_event(spell,source,target)

func duration(spell,source,target):
	# start timer
	exp_timer.one_shot = true
	exp_timer.wait_time = float(spell["duration"])
	exp_timer.connect("timeout",remove_aura.bind(spell,source,target))
	add_child(exp_timer)
	exp_timer.start()

func remove_aura(spell,source,target):
	target.aura_dict.erase("%s %s"%[source.stats_curr["name"],spell["name"]])
	print("%s's %s faded from %s"%[source.stats_curr["name"],spell["name"],target.stats_curr["name"]])
	queue_free()
