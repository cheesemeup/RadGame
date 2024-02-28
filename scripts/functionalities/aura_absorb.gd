extends Node

var remaining_value: int = 0
var aura_spell: Dictionary
var aura_source: CharacterBody3D
var aura_target: CharacterBody3D
var duration_timer = Timer.new()

func initialization(spell,source,target):
	# get absorb amount
	remaining_value = query_absorb_value(aura_spell,aura_source,aura_target)
	# start timer
	duration_timer.wait_time = aura_spell["duration"]
	duration_timer.start()
	pass

func reinitialization(spell):
	# stop timer
	duration_timer.stop()
	# reset to new absorb amount
	# start timer
	duration_timer
	pass

func query_absorb_value(spell,source,target):
	pass

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
