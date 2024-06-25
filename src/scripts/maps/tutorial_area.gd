extends BaseMap

var targetdummy_dps = preload("res://scenes/units/targetdummy_dps.tscn")

func initialize():
	print("initializing tutorial area")
	initial_spawn_position = Vector3(0,-5,-30)
	init_npcs()


func init_npcs():
	# npcs must be spawned via code to ensure forced readable names
	var dummy_instance = targetdummy_dps.instantiate()
	dummy_instance.position = Vector3(-8,-5,27)
	$npcs.add_child(dummy_instance,true)
	# targetdummies dps multitarget
	var spawn_position = [
		Vector3(-31,-5,26),
		Vector3(-33,-5,28),
		Vector3(-29,-5,28),
		Vector3(-33,-5,24),
		Vector3(-29,-5,24)
	]
	for i in range(5):
		dummy_instance = targetdummy_dps.instantiate()
		dummy_instance.position = spawn_position[i]
		$npcs.add_child(dummy_instance,true)
