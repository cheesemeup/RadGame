# Signpost Damage
extends BaseSpell

func _ready():
	initialize_base_spell("0")

func trigger(interactor: CharacterBody3D):
	# set interactor as target
	target = interactor
	Combat.combat_event_entrypoint(spell_current, source, target)
