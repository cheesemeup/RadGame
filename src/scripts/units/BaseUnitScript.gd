class_name BaseUnit
extends CharacterBody3D

# spawn
var spawn_position: Vector3
var spawn_rotation: Vector3

# combat and stats
var speed_factor = 1
@export var stats_current: Dictionary
var stats_base: UnitStats
var stat_mult: Dictionary
var stat_add: Dictionary
var aura_list: Array = []
var absorb_array: Array = []

# targeting
var target = null  # for unitframes, only local
var selected_target = null  # for targeting with spells
var mouseover_target = null  # for targeting with spells


####################################################################################################
# INITIALIZATION
func init_base_unit() -> void:
	stat_init()
	var spell_container = preload("res://scenes/functionalities/spell_container.tscn").instantiate()
	add_child(spell_container)
	spell_container_init(stats_current.spell_list)
	var aura_container = preload("res://scenes/functionalities/aura_container.tscn").instantiate()
	add_child(aura_container)


func stat_init() -> void:
	stats_current = self.stats_base.init_stats_current()
	stat_mult = self.stats_base.init_statmult()
	stat_add = self.stats_base.init_statadd()
	#speed = stats_current["movement_speed"]
	scale = Vector3(stats_base.size,stats_base.size,stats_base.size)


func spell_container_init(spell_list: Array) -> void:
	# remove any previous spells before adding new ones
	for spell in $spell_container.get_children():
		spell.queue_free()
	for spell in spell_list:
		var spell_scene = load("res://scenes/functionalities/spell_base.tscn")
		var spell_script = load("res://scripts/spells/spell_%d.gd"%spell)
		spell_scene = spell_scene.instantiate()
		spell_scene.name = "spell_%d"%spell
		spell_scene.set_script(spell_script)
		$spell_container.add_child(spell_scene)


####################################################################################################
# CAST TIMER
func send_start_casttimer(cast_time: float) -> void:
	rpc("start_casttimer",cast_time)


@rpc("authority","call_local")
func start_casttimer(cast_time: float) -> void:
	get_node("casttimer").wait_time = cast_time
	get_node("casttimer").start()


################################################################################
# MODELS AND ANIMATIONS
func set_model() -> void:
	# unload previous model if it exists
	if $pivot.get_node_or_null("active_model"):
		$pivot/active_model.free()
	# load new model
	var model_scene = load("res://scenes/models/%s.tscn"%stats_current["model"]).instantiate()
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
	if not is_on_floor():
		play_animation("Jump_Idle")
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
# Utilities
func set_position_and_rotation(new_position: Vector3, new_rotation: Vector3) -> void:
	# use this when scene is already in the tree
	# otherwise, use spawn_and_rotate
	global_position = new_position
	$pivot.rotation = new_rotation


func set_spawn_position_and_rotation(new_position: Vector3, new_rotation: Vector3) -> void:
	spawn_position = new_position
	spawn_rotation = new_rotation


func spawn_and_rotate() -> void:
	# when spawning, global_position cannot be used before the scene enters the tree
	# therefore, position is used here instead of global_position
	position = spawn_position
	$pivot.rotation = spawn_rotation


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
		send_toggle_castbar.rpc_id(name.to_int(),new_value)
		if new_value:
			# possibly add log message for very detailed logging
			play_animation("Spellcasting")
@rpc("authority","call_local")
func send_toggle_castbar(visibility: bool):
	UIHandler.toggle_castbar(visibility)

@export var is_in_combat: bool = false:
	set(new_value):
		is_in_combat = new_value
		if new_value:
			custom_enter_combat()
func custom_enter_combat():
	# override in unit script
	pass
