extends CharacterBody3D

class_name BaseUnit

# combat
var speed: float 
@export var stats_current: Dictionary
var stats_base: Dictionary
var stats_mult: Dictionary
var stats_add: Dictionary
var aura_list: Array = []
var absorb_array: Array = []

# targeting
var target = null  # for unitframes, only local
var selected_target = null  # for targeting with spells
var mouseover_target = null  # for targeting with spells


# model
@export var model: String


####################################################################################################
# INITIALIZATION

func initialize_base_unit(unittype: String, unit_id: String) -> void:
	# stats
	stat_init(unittype,unit_id)
	# spells
	var spell_container = preload("res://scenes/functionalities/spell_container.tscn").instantiate()
	add_child(spell_container)
	spell_container_init(self.stats_current.spell_list)
	# auras
	var aura_container = preload("res://scenes/functionalities/aura_container.tscn").instantiate()
	add_child(aura_container)


func stat_init(unit_type: String, unit_id: String) -> void:
	# read stats dict from file
	var file = "res://data/db_stats_"+unit_type+".json"
	var json_dict = JSON.parse_string(FileAccess.get_file_as_string(file))
	stats_base = json_dict[unit_id]
	# extract base model information
	model = stats_base["model"]
	stats_base.erase("model")
	# create duplicate for current stats
	stats_current = stats_base.duplicate(true)
	stats_mult = initialize_statmult()
	stats_add = initialize_statadd()
	# set speed
	speed = stats_current["speed"]


func initialize_statmult() -> Dictionary:
	var stat_mult = {}
	stat_mult["size"] = {}
	stat_mult["speed"] = {}
	stat_mult["size"] = {}
	stat_mult["health_max"] = {}
	stat_mult["resource_max"] = {}
	stat_mult["primary"] = {}
	stat_mult["damage_modifier_physical"] = {}
	stat_mult["damage_modifier_magic"] = {}
	stat_mult["heal_modifier_physical"] = {}
	stat_mult["heal_modifier_magic"] = {}
	stat_mult["defense_modifier_physical"] = {}
	stat_mult["defense_modifier_magic"] = {}
	stat_mult["heal_taken_modifier_physical"] = {}
	stat_mult["heal_taken_modifier_magic"] = {}
	return stat_mult


func initialize_statadd() -> Dictionary:
	var stat_add = {}
	stat_add["health_max"] = {}
	stat_add["resource_max"] = {}
	stat_add["primary"] = {}
	stat_add["avoidance"] = {}
	stat_add["crit_chance"] = {}
	return stat_add


func spell_container_init(spell_list: Array) -> void:
	# remove previous spells
	for spell in $spell_container.get_children():
		spell.queue_free()
	# add spells to spell container
	for spell in spell_list:
		var spell_scene = load("res://scenes/functionalities/spell_base.tscn")
		var spell_script = load("res://scripts/spells/spell_%d.gd"%spell)
		spell_scene = spell_scene.instantiate()
		spell_scene.name = "spell_%d"%spell
		spell_scene.set_script(spell_script)
		$spell_container.add_child(spell_scene)


####################################################################################################
# CAST TIMER
func send_start_casttimer(cast_time: float):
	rpc("start_casttimer",cast_time)


@rpc("authority","call_local")
func start_casttimer(cast_time: float):
	get_node("casttimer").wait_time = cast_time
	get_node("casttimer").start()


################################################################################
# MODELS AND ANIMATIONS
func set_model(model_name: String) -> void:
	# unload previous model if it exists
	if $pivot.get_node_or_null("active_model"):
		$pivot/active_model.free()
	# load new model
	var model_scene = load("res://scenes/models/%s.tscn"%model_name).instantiate()
	model_scene.name = "active_model"
	$pivot.add_child(model_scene, true)
	play_animation("Idle")


func play_animation(animation_name: String) -> void:
	if $pivot.get_node_or_null("active_model"):
		$pivot.get_node("active_model").get_node("AnimationPlayer").play(animation_name)


func queue_animation(animation_name: String) -> void:
	if $pivot.get_node_or_null("active_model"):
		$pivot.get_node("active_model").get_node("AnimationPlayer").queue(animation_name)


func determine_movement_animation() -> void:
	# only play movement animation if on ground, jump idle is already queued when jumping
	if not is_on_floor():
		return
	if not is_moving:
		play_animation("Idle")
		return
	if is_backpedaling:
		play_animation("Walking_Backwards")
	elif is_strafing_left:
		play_animation("Running_Strafe_Left")
	elif is_strafing_right:
		play_animation("Running_Strafe_Right")
	else:
		play_animation("Running_A")


################################################################################
# STATES
@export var is_moving: bool = false:
	set(new_value):
		is_moving = new_value
		determine_movement_animation()


@export var is_strafing_left: bool = false:
	set(new_value):
		is_strafing_left = new_value
		determine_movement_animation()
@export var is_strafing_right: bool = false:
	set(new_value):
		is_strafing_right = new_value
		determine_movement_animation()
@export var is_backpedaling: bool = false:
	set(new_value):
		is_backpedaling = new_value
		determine_movement_animation()
		if new_value:
			# reduce movement speed
			speed = stats_current["speed"] / 2
		else:
			# restore movement speed
			speed = stats_current["speed"]


@export var is_dead: bool = false:
	set(new_value):
		is_dead = new_value
		if new_value:
			# combat log message
			Combat.log_death(self.name)
			is_moving = false
			is_casting = false
			is_strafing_left = false
			is_strafing_right = false
			target = null
			play_animation("Death_A")


@export var is_casting: bool = false:
	set(new_value):
		is_casting = new_value
		# toggle castbar
		rpc_id(name.to_int(),"send_toggle_castbar",new_value)
		if new_value:
			# possibly add log message for very detailed logging
			play_animation("Spellcasting")
@rpc("authority","call_local")
func send_toggle_castbar(visibility: bool):
	UIHandler.toggle_castbar(visibility)
