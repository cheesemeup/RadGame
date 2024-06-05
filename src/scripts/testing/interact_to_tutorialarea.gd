extends BaseInteractable

func _enter_tree():
	# set authority
	$mpsynchronizer.set_multiplayer_authority(1)


func _ready():
	if not $mpsynchronizer.is_multiplayer_authority():
		# create interact prompt text locally for all peers
		$interact_prompt.text = create_prompt_text()
		return
	# initialize BaseInteractable on server
	initialize_base_interactable("1")


func trigger(interactor):
	# write interaction to log
	Combat.log_interact(interactor.stats_current["unit_name"],self.stats_current["unit_name"])
	# trigger map swap
	rpc_id(1,"request_map_swap","tutorial_area.tscn")


@rpc("any_peer")
func request_map_swap(map_name: String):
	Serverscript.request_map_swap(map_name)
