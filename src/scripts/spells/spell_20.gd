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
	

	
	
