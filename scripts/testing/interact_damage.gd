extends BaseInteractable

func _enter_tree():
	# set authority
	$mpsynchronizer.set_multiplayer_authority(1)

func _ready():
	# initialize BaseInteractable
	initialize_base_interactable("0")
	$"range/range_shape".shape.radius = 3
	#set_process(false)
	#if $mpsynchronizer.is_multiplayer_authority():
		#set_process(true)

#func ready_server():
	#initialize_base_interactable("0")

#func interaction(body):
	#if not multiplayer.is_server():
		#return
	## source and target are flipped here, because the source of the interaction
	## (the player) turns into the target of the spell
	#$spell_container/spell_0.trigger(self,body)
