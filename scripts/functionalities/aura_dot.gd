extends Node

var aura_spell: Dictionary
var aura_source: CharacterBody3D
var aura_target: CharacterBody3D
var tickrate: float
var ticks: float
var nticks: float = 0
var tick_timer = Timer.new()

# initialize relevant spell data
func initialize(spell,source,target):
	print("begin init")
	aura_spell = spell
	aura_source = source
	aura_target = target
	ticks = spell["ticks"]
	tickrate = spell["tickrate"]
	print("init timer")
	# initialize timer
	tick_timer.wait_time = tickrate
	tick_timer.connect("timeout",tick)
	add_child(tick_timer)

# start timer when ready
func _ready():
	print("trying to start a timer here")
	tick_timer.start()

# reinitialization for overwriting before expiration

# event tick
func tick():
	Combat.combat_event_entrypoint(aura_spell,aura_source,aura_target)
	nticks += 1
	# restart timer if there are ticks left
	if nticks < ticks:
		return
	# remove aura if all ticks occurred
	remove_aura()

# removal
func remove_aura():
	tick_timer.stop()
	pass
