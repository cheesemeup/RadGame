# Test NPC Heal Self
extends BaseSpell

func _ready():
	initialize_base_spell("2")

func trigger():
	## checks not necessary for this spell, as it is free, off gcd, and cast on self
	#var source = get_parent().get_parent()
	Combat.combat_event_entrypoint(spell_current,source,source)
