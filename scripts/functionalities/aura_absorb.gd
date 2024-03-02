extends Node

var remaining_value: int = 0
var aura_spell: Dictionary
var aura_source: CharacterBody3D
var aura_target: CharacterBody3D
var expiration_timer = Timer.new()

# initialize relevant spell data
func initialization(spell,source,target):
	aura_source = source
	aura_target = target
	# get absorb amount
	remaining_value = Combat.value_query(
		spell["value_modifier"],
		source.stats_current[spell["value_base"]],
		source.stats_current["heal_modifier"][spell["effecttype"]],
		target.stats_current["heal_taken_modifier"][spell["effecttype"]]
	)
	# initialize timer
	expiration_timer.wait_time = aura_spell["duration"]
	expiration_timer.connect("timeout",remove_aura)
	add_child(expiration_timer)

# start timer when ready
func _ready():
	expiration_timer.start()

func reinitialization(spell):
	# stop timer
	expiration_timer.stop()
	# reset to new absorb amount
	remaining_value = Combat.value_query(
		spell["value_modifier"],
		aura_source.stats_current[spell["value_base"]],
		aura_source.stats_current["heal_modifier"][spell["effecttype"]],
		aura_target.stats_current["heal_taken_modifier"][spell["effecttype"]]
	)
	# start timer
	expiration_timer.wait_time = spell["duration"]
	expiration_timer.start()

	# removal
func remove_aura():
	print("remaining value of absorb is %s"%remaining_value)
	remaining_value = 0
	Combat.combat_event_aura_entrypoint(aura_spell,aura_source,aura_target,true)
