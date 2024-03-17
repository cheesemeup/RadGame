extends BaseInteractable

func _enter_tree():
	# set authority
	$mpsynchronizer.set_multiplayer_authority(1)

func _ready():
	# initialize BaseInteractable on server
	if not $mpsynchronizer.is_multiplayer_authority():
		return
	initialize_base_interactable("0")

func trigger(interactor):
	# write interaction to log
	Combat.log_interact(interactor.stats_current["unit_name"],self.stats_current["unit_name"])
	# trigger spell ID 0
	$"spell_container/spell_0".trigger(interactor)
