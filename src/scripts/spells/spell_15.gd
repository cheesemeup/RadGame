# Signpost Heal
extends BaseSpell

func _ready():
	initialize_base_spell("15")

func trigger(target: CharacterBody3D):
	# get source and target nodes
	var source = get_parent().get_parent()
	# send combat event to combat script
	Combat.combat_event_entrypoint(spell_current, source, target)
