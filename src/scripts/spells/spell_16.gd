<<<<<<< HEAD
# Player Test DoT
extends BaseSpell

func _ready():
	initialize_base_spell("16")

func trigger():
	# get source and target nodes
	var source = get_parent().get_parent()
	# check for cooldown
	if is_on_cd():
		print("on cd")
		return 2
	# check range - todo: impl ground target range
	#if is_not_in_range(source.position,target.position,spell_current["max_range"]):
		#print("not in range")
		#return 4
	# send gcd
	if spell_current["on_gcd"] == 1:
		get_parent().send_gcd()
	# send event to combat script
	print("changing to ground targeting mode")
	source.is_ground_targeting["state"] = true
	source.is_ground_targeting["spell_id"] = "16"
	
# once clicked, trigger the actual ground effect
func ground_effect(position: Vector3):
	print("triggering ground effect and stopping targeting mode")
	var effect = preload("res://scenes/functionalities/spell_ground_effect.tscn")
	var instance = effect.instantiate()
	instance.global_position = position
	$/root/main/maps/active_map/ground_effects.add_child(instance, true)
	

	
	
=======
# Barotrauma
extends BaseSpell

func _ready():
	ID = "16"
	initialize_base_spell(ID)

func trigger() -> int:
	# do not allow casting if already casting
	if source.is_casting:
		check_queue()
		return 6
	# check for cooldown
	if is_on_cd():
		check_queue()
		return 2
	# check resource availability
	if insufficient_resource(
		spell_current["resource_cost"],
		source.stats_current["resource_current"]
	):
		return 3
	# CAST BEGIN
	# send gcd
	if spell_current["on_gcd"] == 1:
		get_parent().send_gcd()
	# start cast, link timer to cast_success
	start_cast(cast_success)
	return 0


func cast_success() -> void:
	# apply resource cost 
	source.stats_current["resource_current"] = update_resource(
		spell_current["resource_cost"],
		source.stats_current["resource_current"],
		source.stats_current["resource_max"]
	)
	# send event to combat script
	Combat.combat_event_aura_entrypoint(spell_current,source,source)
	# end cast
	finish_cast(cast_success)
>>>>>>> f94e23b (baromancer_basic (#41))
