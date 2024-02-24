extends Node

var aura_spell: Dictionary
var aura_source: CharacterBody3D
var aura_target: CharacterBody3D
var expiration_timer = Timer.new()
var duration: float

# initialize relevant spell data
func initialize(spell: Dictionary ,source: CharacterBody3D, target: CharacterBody3D):
	aura_spell = spell
	aura_source = source
	aura_target = target
	duration = spell["duration"]
	# initialize timer
	expiration_timer.wait_time = duration
	expiration_timer.connect("timeout",remove_aura)
	add_child(expiration_timer)

# start timer when ready
func _ready():
	stat_calc()
	expiration_timer.start()

# reinitialization for overwriting before expiration
func reinitialize(spell: Dictionary):
	aura_spell = spell
	expiration_timer.stop()
	stat_calc()
	expiration_timer.start()

# calculate stats
func stat_calc(remove: bool = false):
	# write buff data into stat dicts of target
	Combat.buff_application(aura_spell, aura_target, remove)
	# calculate new current stats
	Combat.stat_calculation(aura_target)

# removal
func remove_aura():
	expiration_timer.stop()
	Combat.combat_event_aura_entrypoint(aura_spell,aura_source,aura_target,true)
	stat_calc(true)
