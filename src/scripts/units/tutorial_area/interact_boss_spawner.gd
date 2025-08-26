extends BaseInteractable


func custom_post_ready():
	$pivot/active_model/sign_text.text = "Spawn Boss"


func custom_trigger(_interactor):
	# check if a boss is already present, and remove if so
	var boss = get_node_or_null(^"/root/main/maps/active_map/npcs/active_tutorialboss")
	if boss:
		print("despawning active_tutorialboss unit")
		boss.free()
		return
	# spawn boss
	Serverscript.spawn_npc_hostile(7, "tutorial_area/tutorial_boss_tank", Vector3(15,-5,-4), Vector3(0,deg_to_rad(90),0))
