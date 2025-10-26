extends BaseHostile


var energy_tick_timer = Timer.new()


func custom_pre_ready():
	name = "active_boss"
	add_to_group("boss")
	energy_tick_timer.wait_time = 3
	energy_tick_timer.connect("timeout", energy_tick)
	$timer_container.add_child(energy_tick_timer)


func custom_post_ready():
	pass


func custom_start_encounter():
	energy_tick_timer.start()


func custom_hostile_death():
	energy_tick_timer.stop()


func custom_reset():
	energy_tick_timer.stop()


func energy_tick():
	stats_current["resource_current"] += stats_current["resource_regen"]
	if stats_current["resource_current"] == 100:
		print("Energy Reset Spell")
		stats_current["resource_current"] = 0
