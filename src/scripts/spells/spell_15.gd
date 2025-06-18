# Signpost Absorb
extends BaseSpell

func _ready():
	initialize_base_spell("15")

func trigger(interactor: CharacterBody3D):
	# set interactor as target
	target = interactor
	Combat.combat_event_aura_entrypoint(spell_current, source, target)
