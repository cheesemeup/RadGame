extends BaseMap

var targetdummy_dps = preload("res://scenes/units/targetdummy_dps.tscn")

func initialize():
	print("initializing tutorial area")
	initial_spawn_position = Vector3(0,-5,-30)
	init_npcs()


func init_npcs():
	# npcs must be spawned via code to ensure forced readable names
	# dps dummies
	var spawn_position = [
		Vector3(-8,-5,27),
		Vector3(-31,-5,26),
		Vector3(-33,-5,28),
		Vector3(-29,-5,28),
		Vector3(-33,-5,24),
		Vector3(-29,-5,24)
	]
	print("calling spawn_dummygroup")
	spawn_dummygroup(targetdummy_dps,spawn_position)


func spawn_dummygroup(dummy_preload, spawn_position: Array):
	print("spawn_position.size is %s"%spawn_position.size())
	for i in spawn_position.size():
		print("spawning dummy %s"%i)
		var dummy_instance = dummy_preload.instantiate()
		dummy_instance.position = spawn_position[i]
		$npcs.add_child(dummy_instance,true)
