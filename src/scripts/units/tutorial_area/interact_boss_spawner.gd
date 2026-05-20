extends BaseInteractable


func custom_post_ready():
	$pivot/active_model/sign_text.text = "Spawn Boss"


func custom_trigger(_interactor):
	# check if a boss is already present, and remove if so
	var boss = get_node_or_null(^"/root/main/maps/active_map/npcs/active_boss")
	if boss:
		print("despawning active_boss unit")
		boss.free()
		return
	# spawn boss
	Serverscript.spawn_npc_hostile("map01/map01_boss01", Vector3(15,-5,-4), Vector3(0,PI/2,0))
