extends BaseMap

var targetdummy_dps = preload("res://scenes/units/tutorial_area/targetdummy_dps.tscn")
var targetdummy_heal = preload("res://scenes/units/tutorial_area/targetdummy_heal.tscn")
var targetdummy_tank = preload("res://scenes/units/tutorial_area/targetdummy_tank.tscn")

func initialize() -> void:
	print("initializing tutorial area")
	initial_spawn_position = Vector3(0,-5,-30)
	current_spawn_position = initial_spawn_position
	init_npcs()


func init_npcs() -> void:
	# npcs must be spawned via code to ensure forced readable names
	# dps dummies
	var spawn_position = [
		Vector3(-8,-5,26),
		Vector3(-31,-5,26),
		Vector3(-33,-5,28),
		Vector3(-29,-5,28),
		Vector3(-33,-5,24),
		Vector3(-29,-5,24)
	]
	spawn_dummygroup(targetdummy_dps,spawn_position)
	# heal dummies
	spawn_position = [
		Vector3(-32,-5,12),
		Vector3(-30,-5,-1),
		Vector3(-34,-5,-1),
		Vector3(-32,-5,-3),
		Vector3(-30,-5,-5),
		Vector3(-34,-5,-5),
	]
	spawn_dummygroup(targetdummy_heal,spawn_position)
	# tank dummies
	spawn_position = [
		Vector3(-32,-5,-8),
		Vector3(-30,-5,-21),
		Vector3(-34,-5,-21),
		Vector3(-32,-5,-23),
		Vector3(-30,-5,-25),
		Vector3(-34,-5,-25),
	]
	spawn_dummygroup(targetdummy_heal,spawn_position)


func spawn_dummygroup(dummy_preload: PackedScene, spawn_position: Array):
	for i in spawn_position.size():
		var dummy_instance = dummy_preload.instantiate()
		dummy_instance.position = spawn_position[i]
		$npcs.add_child(dummy_instance,true)
