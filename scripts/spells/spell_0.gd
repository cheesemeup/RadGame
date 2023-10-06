# Signpost Damage
extends BaseSpell

func _ready():
	initialize_base_spell("0")

func trigger(source,target):
	# request combat event from server
	Serverscript.request_combat_event_targeted(source,target,spell_current)
