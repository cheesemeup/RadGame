extends BaseInteractable

func _ready():
	if multiplayer.is_server():
		ready_server()

func ready_server():
	initialize_base_interactable("0")

func interaction(body):
	if not multiplayer.is_server():
		return
	# source and target are flipped here, because the source of the interaction
	# (the player) turns into the target of the spell
	$spell_container/spell_0.trigger(self,body)
