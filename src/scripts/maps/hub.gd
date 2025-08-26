extends BaseMap

func initialize():
	print("initializing hub map")
	initial_spawn_position = Vector3(0,20,0)
	current_spawn_position = initial_spawn_position
	init_npcs()
	init_interactables()


func init_npcs():
	# spawn npcs
	var test_npc = preload("res://scenes/testing/test_npc_hostile.tscn").instantiate()
	test_npc.set_process(false)
	test_npc.position = Vector3(-6,0,-6)
	$npcs.add_child(test_npc,true)
	test_npc = preload("res://scenes/testing/test_npc_friendly.tscn").instantiate()
	test_npc.set_process(false)
	test_npc.position = Vector3(-3,0,-6)
	$npcs.add_child(test_npc,true)


func init_interactables():
	interactable_despawn_position = Vector3(0,-10,0)
	Serverscript.spawn_interactable(0, "hub/interact_damage", Vector3(0,0,-6), Vector3(0,0,0))
	Serverscript.spawn_interactable(1, "hub/interact_heal", Vector3(3,0,-6), Vector3(0,0,0))
	Serverscript.spawn_interactable(2, "hub/interact_absorb", Vector3(6,0,-6), Vector3(0,0,0))
	Serverscript.spawn_interactable(3, "hub/interact_tp_to_tutorialmap", Vector3(9,0,-6), Vector3(0,0,0))
