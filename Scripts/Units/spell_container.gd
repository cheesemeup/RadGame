extends Node

var gcd_timer = 1.5

# apply role swap changes

# apply talent changes

# send gcd
func send_gcd():
	for spell in get_children():
		if spell.spell_curr["on_gcd"] == 0:
			continue
		spell.start_cd(gcd_timer)
