extends BaseMap

func initialize():
	print("initializing hub map")
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
	var test_signpost = preload("res://scenes/testing/interact_damage.tscn").instantiate()
	test_signpost.position = Vector3(0,0,-6)
	$interactables.add_child(test_signpost,true)
	test_signpost = preload("res://scenes/testing/interact_heal.tscn").instantiate()
	test_signpost.position = Vector3(3,0,-6)
	$interactables.add_child(test_signpost,true)
	test_signpost = preload("res://scenes/testing/interact_absorb.tscn").instantiate()
	test_signpost.position = Vector3(6,0,-6)
	$interactables.add_child(test_signpost,true)
