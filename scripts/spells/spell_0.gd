# Signpost Damage
extends BaseSpell

func _ready():
	initialize_base_spell("0")

func trigger(target: CharacterBody3D):
	print("trigger spell 0")
	# get source and target nodes
	var source = get_parent().get_parent()
	# send combat event to combat script
	Combat.combat_event_entrypoint(spell_current, source, target)
