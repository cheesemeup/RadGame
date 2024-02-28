extends Node

var aura_spell: Dictionary
var aura_source: CharacterBody3D
var aura_target: CharacterBody3D
var tickrate: float
var ticks: float
var nticks: float = 0
var tick_timer = Timer.new()

# initialize relevant spell data
func initialize(spell: Dictionary, source: CharacterBody3D, target: CharacterBody3D):
	aura_spell = spell
	aura_source = source
	aura_target = target
	ticks = spell["ticks"]
	tickrate = spell["tickrate"]
	# initialize timer
	tick_timer.wait_time = tickrate
	tick_timer.connect("timeout",tick)
	add_child(tick_timer)

# start timer when ready
func _ready():
	tick_timer.start()

# reinitialization for overwriting before expiration
func reinitialize(spell: Dictionary):
	aura_spell = spell
	tick_timer.stop()
	nticks = 0
	ticks = spell["ticks"]
	tick_timer.wait_time = spell["tickrate"]
	tick_timer.start()
	
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
	Combat.combat_event_aura_entrypoint(aura_spell,aura_source,aura_target,true)
