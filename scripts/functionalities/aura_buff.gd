extends Node

var aura_spell: Dictionary
var aura_source: CharacterBody3D
var aura_target: CharacterBody3D
var expiration_timer = Timer.new()
var duration: float

# initialize relevant spell data
func initialize(spell: Dictionary ,source: CharacterBody3D, target: CharacterBody3D):
	print("aura_buff initialize")
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
	print("aura_buff ready")
	Combat.buff_application(aura_spell,aura_source,aura_target)
	expiration_timer.start()

# reinitialization for overwriting before expiration
func reinitialize(spell: Dictionary):
	print("aura_buff reinitialize")
	aura_spell = spell
	expiration_timer.stop()
	Combat.buff_application(aura_spell,aura_source,aura_target)
	expiration_timer.start()

# removal
func remove_aura():
	print("aura_buff remove_aura")
	expiration_timer.stop()
	Combat.combat_event_aura_entrypoint(aura_spell,aura_source,aura_target,true)
	Combat.buff_application(aura_spell,aura_source,aura_target,true)
