# Signpost Damage
extends BaseSpell



func _ready():
	initialize_base_spell("0")

func trigger(source,target):
	if on_cd:
		print("spell on cooldown")
		return
	# request combat event from server
	var result = Serverscript.request_combat_event_targeted(source,target,spell_current)
	if result < 2:
		if spell_base.on_gcd == 1:
			get_parent().send_gcd
	else:
		print(result_strings[result-2])


