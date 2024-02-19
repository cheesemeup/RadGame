extends Node

class_name BaseSpell

var spell_base: Dictionary
var spell_current: Dictionary
var result_strings
var cd_timer = Timer.new()
var mouseover = false

func _ready():
	cd_timer.one_shot = true
	add_child(cd_timer)

func initialize_base_spell(spell_id: String):
	var json_dict = JSON.parse_string(FileAccess.get_file_as_string("res://data/db_spells.json"))
	spell_base = json_dict[spell_id]
	spell_current = spell_base.duplicate(true)
	# connect gcd signal if spell is on gcd
	if spell_current["on_gcd"] == 1:
		get_parent().signal_gcd.connect(trigger_cd)

####################################################################################################
# TARGET
func get_spell_target(source: CharacterBody3D):
	# return either selected or mouseovered target, depending on setting
	if mouseover:
		return source.mouseover_target
	return source.selected_target

####################################################################################################
# CHECKS
func is_illegal_target(valid_group,target):
	if target.is_in_group(valid_group):
		return false
	return true
func is_on_cd():
	if cd_timer.time_left > 0:
		return true
	return false
func insufficient_resource(cost: int, resource: int):
	if cost < resource:
		return false
	return true
func is_not_in_range(source_position: Vector3, target_position: Vector3, range: float):
	if source_position.distance_to(target_position) > range:
		return true
	return false
func is_not_in_line_of_sight(source: CharacterBody3D,target_position: Vector3):
	# cast a ray that uses the collision layer for terrain (layer 1)
	var query = PhysicsRayQueryParameters3D.create(source.position,target_position)
	print(source.space_state.intersect_ray(query)["collider"])
	if source.space_state.intersect_ray(query)["collider"] == null:
		return false
	return true

####################################################################################################
# COOLDOWN
func trigger_cd(duration: float):
	# check if current cooldown exceeds requested cooldown
	if cd_timer.time_left > duration:
		return
	# start timer
	cd_timer.wait_time = duration
	cd_timer.start()
