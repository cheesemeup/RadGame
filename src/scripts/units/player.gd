extends BaseUnit

@onready var synchronizer = $mpsynchronizer
@onready var input = $player_input

var playermodel_reference = null

# speed cannot be read from stats directly, so the speed var needs to be updated
# when speed changes
#var speed: float = 10.0
const jump_velocity: float = 4.5
var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")

# targeting vars
var space_state
#var unit_selectedtarget = null
#var unit_mouseover_target = null
var interactables: Array = []
var current_interactable = null  # the currently active interactable

# spells
var spell_map: Dictionary


####################################################################################################
# FRAME
func _physics_process(delta) -> void:
	# movement
	if not is_dead:
		handle_movement(delta)
	# player only section
	if input.is_multiplayer_authority():
		# space state for targeting
		space_state = get_world_3d().direct_space_state
	# server only section
	if not $mpsynchronizer.is_multiplayer_authority():
		return
	# get nearest interactable
	current_interactable = get_nearest_interactable()


####################################################################################################
# SPAWNING
func _enter_tree() -> void:
	$player_input.set_multiplayer_authority(str(name).to_int())


func pre_ready(peer_id: int) -> void:
	name = str(peer_id)
	# initialize stats for all peers
	initialize_base_unit("player","3")


func _ready():
	# load model
	set_model(model)


func post_ready(peer_id: int) -> void:
	# some things should be done after _ready is finished
	rpc_id(peer_id,"peer_post_ready")
	# set position to spawn position
	set_position_and_rotation(
		$/root/main/maps.get_node("active_map").current_spawn_position,
		$/root/main/maps.get_node("active_map").current_spawn_rotation
	)
	print("player %s ready"%name)


@rpc("authority","call_local")
func peer_post_ready():
	References.player_reference = self
	add_cd_timers()
	UIHandler.init_ui()
	load_spell_map()
	initialize_actionbar_slots()
	add_player_camera()
	call_set_input_process()


func add_cd_timers() -> void:
	var cd_timer_scene = preload("res://scenes/functionalities/cd_timer.tscn")
	var timer: Timer
	for spell in stats_current["spell_list"]:
		timer = cd_timer_scene.instantiate()
		timer.name = "cd_timer_spell_%s"%spell
		timer.one_shot = true
		get_node("cd_timer_container").add_child(timer,true)


func load_spell_map() -> void:
	# this is a temporary workaround, and spell_map should be made persistent in a file
	# in the future, with every class/role combination having a separate map to make sure
	# that swapping classes and roles is smooth
	spell_map["10"] = ["fingersoffrost",["1_1"]]
	spell_map["11"] = ["abyssalshell",["1_3"]]
	spell_map["12"] = ["mendingwater",["1_2"]]
	spell_map["13"] = ["deepcurrent",["1_4"]]
	spell_map["14"] = ["succumb",["1_5"]]
	spell_map["16"] = ["fingersoffrost",["2_1"]]
	spell_map["17"] = ["fingersoffrost",["2_2"]]
	spell_map["18"] = ["fingersoffrost",["2_3"]]
	spell_map["19"] = ["fingersoffrost",["2_4"]]


func initialize_actionbar_slots() -> void:
	var actionbars = References.player_ui_main_reference.get_node("actionbars")
	for key in spell_map.keys():
		for slot in spell_map[key][1]:
			actionbars.get_node("actionbar%s"%slot[0]).get_node("actionbar%s"%slot).\
				init([key,spell_map[key][0]])


func add_player_camera() -> void:
	add_child(preload("res://scenes/functionalities/player_camera.tscn").instantiate())
	$camera_rotation/camera_arm/player_camera.current = true


func call_set_input_process() -> void:
	input.set_process(true)
	input.set_process_unhandled_input(true)


####################################################################################################
# TARGETING
func targeting(event_position: Vector2) -> void:
	# send a target ray, and check for collision with any object
	var target_dict = targetray(event_position)
	# check if collision is with a legal target, else set target to null
	if not is_legal_target(target_dict):
		target = null
		rpc_id(1,"set_target","","")
		$"/root/main/ui/unitframe_target".target_reference = target
		UIHandler.hide_targetframe()
		return
	target = target_dict["collider"]
	rpc_id(
		1,
		"set_target",
		target_dict["collider"].name,
		target_dict["collider"].get_parent().name,
		target_dict["collider"].is_in_group("player")
		)
	$"/root/main/ui/unitframe_target".target_reference = target
	UIHandler.show_targetframe()


func targetray(event_position: Vector2) -> Dictionary:
	# only the controlling player can do this, as the camera is required
	var origin = $"camera_rotation/camera_arm/player_camera"
	var from = origin.project_ray_origin(event_position)
	var to = from + origin.project_ray_normal(event_position) * 1000
	var query = PhysicsRayQueryParameters3D.create(from,to)
	var target_dict = space_state.intersect_ray(query)
	return target_dict


func is_legal_target(target_dict: Dictionary) -> bool:
	# check if there is an object
	if target_dict == {}:
		return false
	# check if object is in appropriate group
	if not (target_dict["collider"].is_in_group("npc") or\
		target_dict["collider"].is_in_group("player")):
		return false
	return true


@rpc("any_peer","call_local")
func set_target(requested_target: String, parent: String, is_player: bool = false) -> void:
	if requested_target == "":
		selected_target = null
	elif is_player:
		selected_target = get_node("/root/main/%s/%s"%[parent,requested_target])
	else:
		selected_target = get_node("/root/main/maps/active_map/%s/%s"%[parent,requested_target])


####################################################################################################
# INTERACTABLES
func get_nearest_interactable() -> Node:
	# get the interactable that is nearest to the player unit
	var nearest_interactable = null
	# if only one interactable in range, set to that
	if interactables.size() == 1:
		nearest_interactable = interactables[0]
	# get closest if more than one interactable exists
	elif interactables.size() > 1:
		nearest_interactable = interactables[0]
		var distance = self.global_position.distance_to(nearest_interactable.position)
		var new_distance = distance
		for interactable in interactables:
			# get range to current interactable in loop
			new_distance = self.global_position.distance_to(interactable.position)
			# set nearest interactable if closer than previous closest
			if new_distance < distance:
				nearest_interactable = interactable
				distance = new_distance
	# trigger removal and reapplication of interact prompt if nearest interactable changes
	if nearest_interactable != current_interactable:
		if current_interactable != null:
			rpc_id(name.to_int(),"hide_interact_prompt",current_interactable.name)
		if nearest_interactable != null:
			rpc_id(name.to_int(),"show_interact_prompt",nearest_interactable.name)
	return nearest_interactable


@rpc("authority","call_local")
func show_interact_prompt(interactable_name: String) -> void:
	# rpc that makes interact prompt visible locally
	$/root/main/maps/active_map/interactables.get_node(interactable_name).\
	get_node("interact_prompt").visible = true


@rpc("authority","call_local")
func hide_interact_prompt(interactable_name: String) -> void:
	# rpc that makes interact prompt invisible locally
	$/root/main/maps/active_map/interactables.get_node(interactable_name).\
	get_node("interact_prompt").visible = false


################################################################################
# MOVEMENT
func handle_movement(delta: float) -> void:
	# jumping
	if input.jumping and is_on_floor():
		velocity.y = jump_velocity
	if not is_on_floor():
		velocity.y -= gravity * delta
	input.jumping = false
	var direction = (transform.basis * Vector3(input.direction.x, 0, input.direction.y)).normalized()
	if direction:
		velocity.x = direction.x * speed
		velocity.z = direction.z * speed
	else:
		velocity.x = move_toward(velocity.x, 0, speed)
		velocity.z = move_toward(velocity.z, 0, speed)
	move_and_slide()
	# set movement state on server
	if not $mpsynchronizer.is_multiplayer_authority():
		return
	if velocity == Vector3(0,0,0):
		if is_moving:
			is_moving = false
	else:
		if not is_moving:
			is_moving = true
		# set orientation of player
		set_orientation(direction)


func set_orientation(direction: Vector3) -> void:
	var offset = direction
	if is_strafing_left:
		offset = Vector3(-direction.z,direction.y,direction.x)
	if is_strafing_right:
		offset = Vector3(direction.z,direction.y,-direction.x)
	if is_backpedaling:
		offset = Vector3(-direction.x,direction.y,-direction.z)
	if offset == Vector3(0,0,0):
		return
	$pivot.look_at(global_position + offset)


func set_position_and_rotation(new_position: Vector3, new_rotation: Vector3) -> void:
	# set position to spawn position
	global_position = new_position
	$pivot.rotation = new_rotation
	rpc_id(name.to_int(),"set_camera_rotation",new_rotation)


@rpc("authority","call_local")
func set_camera_rotation(new_rotation: Vector3) -> void:
	get_node("camera_rotation").set_camera_rotation(new_rotation)
