extends Timer


# full duration can differ from the actual wait_time, as it is only used to normalize
# the cd swipe position. this is useful for spells that have their cd affected by other events.
var cd_full_duration: float
var spell_node: Node


func trigger_cd(full_duration: float, duration: float) -> void:
	# set full duration
	cd_full_duration = full_duration
	wait_time = duration
	start()
