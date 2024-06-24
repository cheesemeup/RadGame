extends BaseUnit

@onready var synchronizer = $mpsynchronizer
@onready var input = $player_input

var playermodel_reference = null

# speed cannot be read from stats directly, so the speed var needs to be updated
# when speed changes
var speed: float = 10.0
const jump_velocity: float = 4.5

# targeting vars
var space_state
#var unit_selectedtarget = null
#var unit_mouseover_target = null
var interactables: Array = []
var current_interactable = null  # the currently active interactable

# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")

####################################################################################################
# FRAME
func _physics_process(delta) -> void:
	# movement
	handle_movement(delta)
	# player only section
	if input.is_multiplayer_authority():
		# space state for targeting
		space_state = get_world_3d().direct_space_state
		return
	# server only section
	if $mpsynchronizer.is_multiplayer_authority():
		# get nearest interactable
		current_interactable = get_nearest_interactable()


####################################################################################################
# SPAWNING
func _enter_tree():
	$player_input.set_multiplayer_authority(str(name).to_int())


func pre_ready(peer_id: int):
	name = str(peer_id)
	# initialize stats for all peers
	initialize_base_unit("player","0")


func post_ready(peer_id: int):
	# some things should be done after _ready is finished
	# add player camera node for authority only
	rpc_id(peer_id,"add_player_camera")
	# add UI elements
	rpc_id(peer_id,"load_ui_initial")
#	# activate input _process for authority
	rpc_id(peer_id,"call_set_input_process")
	if input.is_multiplayer_authority():
		References.player_reference = self
	print("player %s ready" % name)


@rpc("authority")
func add_player_camera():
	add_child(load("res://scenes/functionalities/player_camera.tscn").instantiate())
	$camera_rotation/camera_arm/player_camera.current = true
@rpc("authority")
func load_ui_initial():
	# set player reference before initializing the unitframes
	References.player_reference = self
	UIHandler.load_unitframes()
@rpc("authority")
func call_set_input_process():
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
		rpc_id(1,"set_target",null,null)
		$"/root/main/ui/unitframe_target".target_reference = target
		UIHandler.hide_targetframe()
		return
	target = target_dict["collider"]
	rpc_id(1,"set_target",target_dict["collider"].name,target_dict["collider"].get_parent().name)
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


@rpc("any_peer")
func set_target(requested_target,parent):
	if requested_target == null:
		selected_target = null
	else:
		selected_target = get_node("/root/main/maps/active_map/%s/%s"%[parent,requested_target])


####################################################################################################
# INTERACTABLES
func get_nearest_interactable():
	# get the interactable that is nearest to the player unit
	var nearest_interactable = null
	# if only one interactable in range, set to that
	if interactables.size() == 1:
		nearest_interactable = interactables[0]
	# get closest if more than one interactable exists
	elif interactables.size() > 1:
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


@rpc("authority")
func show_interact_prompt(interactable_name: String):
	# rpc that makes interact prompt visible locally
	$/root/main/maps/active_map/interactables.get_node(interactable_name).\
	get_node("interact_prompt").visible = true


@rpc("authority")
func hide_interact_prompt(interactable_name: String):
	# rpc that makes interact prompt invisible locally
	$/root/main/maps/active_map/interactables.get_node(interactable_name).\
	get_node("interact_prompt").visible = false


func handle_movement(delta):
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
