extends Node

var exp_timer = Timer.new()
var tick_timer = Timer.new()

# Player Test DoT
func initialize(spell,source,target):
	# start timer with duration
	duration(spell)
	# start tick timer
	tick(spell,source,target)

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

func duration(spell):
	# start timer
	exp_timer.one_shot = true
	exp_timer.wait_time = float(spell["duration"])
	exp_timer.connect("timeout",remove_aura)
	add_child(exp_timer)
	exp_timer.start()

func remove_aura():
	queue_free()
