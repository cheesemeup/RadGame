extends BaseMap

var targetdummy_dps = preload("res://scenes/units/targetdummy_dps.tscn")

func initialize():
	print("initializing tutorial area")
	initial_spawn_position = Vector3(0,-5,-30)


func init_npcs():
	# NPCs must be spawned via code to ensure forced readable names
	var dummy_instance = targetdummy_dps.instantiate()
	dummy_instance.name = "targetdummy_dps_singletarget"
	dummy_instance.position = Vector3(-8,-5,27)
	$npcs.add_child(dummy_instance,true)
	pass
