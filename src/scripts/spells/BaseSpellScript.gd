extends Node

class_name BaseSpell

var source: CharacterBody3D = null
var spell_base: Dictionary
var spell_current: Dictionary
var cd_timer = Timer.new()
var use_mouseover_target = false
var full_duration: float  # full duration of the cooldown, not necessarily equal to timer wait_time
var spell_id_string: String


func initialize_base_spell(spell_id: String) -> void:
	source = get_parent().get_parent()
	spell_id_string = spell_id
	# load spell data from data file
	var json_dict = JSON.parse_string(FileAccess.get_file_as_string("res://data/db_spells.json"))
	spell_base = json_dict[spell_id]
	spell_current = spell_base.duplicate(true)
	# connect gcd signal if spell is on gcd
	if spell_current["on_gcd"] == 1:
		get_parent().signal_gcd.connect(trigger_cd)
	cd_timer.one_shot = true
	add_child(cd_timer)


####################################################################################################
# TARGET
func get_spell_target() -> CharacterBody3D:
	# return either selected or mouseovered target, depending on setting
	if use_mouseover_target:
		return source.mouseover_target
	return source.selected_target


####################################################################################################
# CHECKS
func is_illegal_target(valid_group: String, target: CharacterBody3D) -> bool:
	# check if the target is in a valid target group for the spell
	if target.is_in_group(valid_group):
		return false
	return true


func is_on_cd() -> bool:
	# check if the spell is on cooldown
	if cd_timer.time_left > 0:
		return true
	return false


func insufficient_resource(cost: int, resource: int) -> bool:
	# check if there are sufficient resources to cast the spell
	if cost <= resource:
		return false
	return true


func is_not_in_range(source_position: Vector3, target_position: Vector3, max_range: float) -> bool:
	# check if the spell is in range
	if source_position.distance_to(target_position) > max_range:
		return true
	return false


func is_not_in_line_of_sight(target_position: Vector3) -> bool:
	# check if the target is in line of sight of the source
	# cast a ray that uses the collision layer for terrain (layer 1)
	var query = PhysicsRayQueryParameters3D.create(source.position,target_position)
	if source.space_state.intersect_ray(query)["collider"] == null:
		return false
	return true


####################################################################################################
# COOLDOWN
func trigger_cd(duration: float, is_gcd: bool = false) -> void:
	# check if current cooldown exceeds requested cooldown
	if cd_timer.time_left > duration:
		return
	# start timer
	cd_timer.wait_time = duration
	cd_timer.start()
	# start timer in player actionbars
	if not source.is_in_group("player"):
		return
	if is_gcd:
		full_duration = get_parent().gcd_timer
	else:
		full_duration = spell_current["cooldown"]
	source.get_node("cd_timer_container").\
		relay_cd_timer(spell_id_string,full_duration,duration)


####################################################################################################
# FUNCTIONALITIES
func update_resource(cost: int, current_resource: int, current_resource_max: int) -> int:
	# update the new current resource value of the source after the spell cost is applied
	return clamp(current_resource-cost, 0, current_resource_max)


func finish_cast() -> void:
	# play cast end animation
	source.play_animation("Spellcast_Shoot")
	# set casting state
	if source.is_casting:
		source.is_casting = false
