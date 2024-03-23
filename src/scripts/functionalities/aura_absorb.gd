extends Node

var remaining_value: int = 0
var aura_spell: Dictionary
var aura_source: CharacterBody3D
var aura_target: CharacterBody3D
var expiration_timer = Timer.new()

func initialize(spell,source,target):
	aura_source = source
	aura_target = target
	aura_spell = spell
	# get absorb amount
	remaining_value = Combat.value_query(
		spell["value_modifier"],
		source.stats_current[spell["value_base"]],
		source.stats_current["heal_modifier"][spell["effecttype"]],
		target.stats_current["heal_taken_modifier"][spell["effecttype"]]
	)
	# initialize timer
	expiration_timer.wait_time = aura_spell["duration"]
	expiration_timer.connect("timeout",remove_absorb)
	add_child(expiration_timer)

func _ready():
	# start timer
	expiration_timer.start()
	# sort absorbs by increasing time remaining
	sort_absorbs()

func reinitialize(spell):
	# update spell data
	aura_spell = spell
	# stop timer
	expiration_timer.stop()
	# reset to new absorb amount
	remaining_value = Combat.value_query(
		spell["value_modifier"],
		aura_source.stats_current[spell["value_base"]],
		aura_source.stats_current["heal_modifier"][spell["effecttype"]],
		aura_target.stats_current["heal_taken_modifier"][spell["effecttype"]]
	)
	# update duration and restart timer
	expiration_timer.wait_time = spell["duration"]
	expiration_timer.start()
	# sort absorbs by increasing time remaining
	sort_absorbs()

func sort_absorbs():
	# sort absorbs by increasing time remaining, also adds new absrbs to the array
	var updated_absorbs = []
	# get absorbs and remaining times
	for child in $"..".get_children():
		updated_absorbs.append([
			child.expiration_timer.get_time_left(),
			str(child.name)
		])
	# sort
	updated_absorbs.sort_custom(func(a,b): return a[0] < b[0])
	# update absorb array
	$"../../..".absorb_array = updated_absorbs

func remove_absorb():
	# set remaining absorb value to zero to prevent unintended absorb while removing
	remaining_value = 0
	# get index to be removed
	var remove_index: int
	for i in range($"../../../".absorb_array.size()):
		if $"../../../".absorb_array[i][1] == name:
			remove_index = i
	# remove outside of iteration
	$"../../../".absorb_array.remove_at(remove_index)
	# remove scene via combat script
	Combat.combat_event_aura_entrypoint(aura_spell,aura_source,aura_target,true)
