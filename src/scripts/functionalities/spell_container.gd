extends Node

var gcd_timer = 1.5
signal signal_gcd(duration)

################################################################################
# ENTRYPOINT FROM ACTIONBAR
func spell_entrypoint(spell_id: String):
	# determine whether spell is present in container
	var node_name = "spell_"+spell_id
	var spell_node = get_node_or_null(node_name)
	if spell_node == null:
		print("spell %s not known"%spell_id)
		return 1  # spell not known
	# trigger spell
	print("triggering ",spell_id)
	spell_node.trigger()

# ENTRYPOINT to place ground effect
func ground_effect_entrypoint(spell_id: String, position: Vector3):
	# determine whether spell is present in container
	var node_name = "spell_"+spell_id
	var spell_node = get_node_or_null(node_name)
	if spell_node == null:
		print("spell not found")
		return 1  # spell not known
	# trigger ground effect
	print("triggering ground effect")
	spell_node.ground_effect(position)



# apply role swap changes

# apply talent changes

# send gcd
func send_gcd() -> void:
	# emit signal
	signal_gcd.emit(gcd_timer)
