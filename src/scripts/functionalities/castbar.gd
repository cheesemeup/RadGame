extends ProgressBar


var timer: Timer = get_parent().get_node("casttimer")


func _process(delta: float) -> void:
	value = timer.time_left
