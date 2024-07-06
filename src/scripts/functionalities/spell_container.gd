extends Node

var player = get_parent()
var gcd_timer: float = 1.5
var result: int
signal signal_gcd(duration)

################################################################################
# ENTRYPOINT FROM ACTIONBAR
func spell_entrypoint(spell_id: String) -> int:
	# determine whether spell is present in container
	var node_name = "spell_"+spell_id
	var spell_node = get_node_or_null(node_name)
	if spell_node == null:
		print("spell %s not known"%spell_id)
		return 1  # spell not known
	# trigger spell
	print("triggering ",spell_id)
	result = spell_node.trigger()
	## player specific section
	#if not player.is_in_group("player"):
		#return result
	#if result == 0:
		## trigger cd in cd timer of player
		#player.get_node("cd_timers").start_cd_timer(
			#spell_id,spell_node.spell_current["cooldown"],spell_node.cd_timer.wait_time
			#)
	return result

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
	# emit signal, true to denote gcd
	signal_gcd.emit(gcd_timer,true)
