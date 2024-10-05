extends Node

var ground_spell: Dictionary
var ground_source: CharacterBody3D
var ground_target: CharacterBody3D
var tickrate: float
var ticks: float
var nticks: float = 0
var tick_timer = Timer.new()
var radius: float

# initialize relevant spell data
func initialize(spell: Dictionary, source: CharacterBody3D, target: CharacterBody3D):
	ground_spell = spell
	ground_source = source
	ticks = spell["ticks"]
	tickrate = spell["tickrate"]
	# initialize timer
	tick_timer.wait_time = tickrate
	tick_timer.autostart=true
	tick_timer.connect("timeout",tick)
	add_child(tick_timer)


# start timer when ready
func _ready():
	tick_timer.start()
	var effect = preload("res://assets/particles/test_particles.tscn")
	var instance = effect.instantiate()
	$particles.add_child(instance, true)


# event tick
func tick():
	#Combat.combat_event_entrypoint(ground_spell,ground_source,ground_target)
	nticks += 1
	# restart timer if there are ticks left
	if nticks < ticks:
		return
	# remove aura if all ticks occurred
	remove_effect()

# removal
func remove_effect():
	tick_timer.stop()
	#Combat.combat_event_aura_entrypoint(ground_spell,ground_source,ground_target,true)
