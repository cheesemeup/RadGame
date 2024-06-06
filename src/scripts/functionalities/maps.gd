extends Node

func swap_map(new_map_name: String):
	# disable physics for players
	rpc("disable_physics")
	
	# remove old map and add new map
	get_child(0).queue_free()
	var newmap = load("res://scenes/maps/"+new_map_name).instantiate()
	newmap.initialize()
	add_child(newmap)
	
	# move players to spawn location and resume physics
	for child in $/root/players.get_children():
		if not child.is_in_group("player"):
			continue
		child.position = newmap.current_spawn_position
	rpc("enable_physics")


@rpc("authority","call_local")
func disable_physics():
	for child in $/root/players.get_children():
		if not child.is_in_group("player"):
			child.set_physics_process(false)
			continue


@rpc("authority","call_local")
func enable_physics():
	for child in $/root/players.get_children():
		if not child.is_in_group("player"):
			continue
		child.set_physics_process(true)
