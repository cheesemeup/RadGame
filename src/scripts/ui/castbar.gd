extends ProgressBar

var casttimer: Timer
var time_left_text: Label


func _ready()-> void:
	casttimer = References.player_reference.get_node("casttimer")
	time_left_text = $time_left_text

# update value when casting
func _process(_delta) -> void:
	# this function is only enabled when is_casting is true on the player
	# set value to normalized cast progress
	value = (casttimer.wait_time - casttimer.time_left) / casttimer.wait_time
	time_left_text.text = "%.1f"%casttimer.time_left
