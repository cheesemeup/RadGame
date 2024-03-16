extends BaseInteractable

var spell

func _enter_tree():
	# set authority
	$mpsynchronizer.set_multiplayer_authority(1)

func _ready():
	# initialize BaseInteractable on server
	if not $mpsynchronizer.is_multiplayer_authority():
		return
	initialize_base_interactable("0")
	$"range/range_shape".shape.radius = 3
	var json_dict = JSON.parse_string(FileAccess.get_file_as_string("res://data/db_spells.json"))
	spell = json_dict[stats_base["spell_list"][0]]

func trigger(interactor):
	# write interaction to log
	Combat.log_interact(interactor.stats_current["unit_name"],self.stats_current["unit_name"])
	# send spell to combat script
	Combat.combat_event_entrypoint(spell, get_child(0).get_parent(), interactor)
	print("trigger overridden")

#func ready_server():
	#initialize_base_interactable("0")

#func interaction(body):
	#if not multiplayer.is_server():
		#return
	## source and target are flipped here, because the source of the interaction
	## (the player) turns into the target of the spell
	#$spell_container/spell_0.trigger(self,body)
