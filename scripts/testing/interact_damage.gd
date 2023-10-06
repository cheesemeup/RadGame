extends BaseUnit

func _ready():
	if multiplayer.is_server():
		ready_server()

func ready_server():
	initialize_base_unit("npc","0")

func interaction(body):
	if not multiplayer.is_server():
		return
	var spell = $spells/spell_0.spell_current
	# source and target are flipped here, because the source of the interaction
	# (the player) turns into the target of the spell
	$"spells/spell_0".trigger(self,body)
