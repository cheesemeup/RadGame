extends BaseUnit


#@onready var player_cam = $camera_rotation/camera_arm/player_camera
@onready var synchronizer = $mpsynchronizer
@onready var input = $player_input

var playermodel_reference = null

# speed cannot be read from stats directly, so the speed var needs to be updated
# when speed changes
var speed = 10.0
const jump_velocity = 4.5

# targeting vars - NEEDS REWORK FOR MULTIPLAYER
var space_state
#var unit_selectedtarget = null
#var unit_mouseover_target = null
#var interactables_in_range = []
#var current_interact_target = null

# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")

####################################################################################################
# FRAME
func _physics_process(delta):
	handle_movement(delta)
	# section that is only relevant for specific player
	if not input.is_multiplayer_authority():
		return
	space_state = get_world_3d().direct_space_state

####################################################################################################
# SPAWNING
func _enter_tree():
	$player_input.set_multiplayer_authority(str(name).to_int())

func pre_ready(peer_id):
	name = str(peer_id)
	initialize_base_unit("player","0")

@rpc("authority")
func add_player_camera():
	add_child(load("res://scenes/functionalities/player_camera.tscn").instantiate())
	$camera_rotation/camera_arm/player_camera.current = true
@rpc("authority")
func load_ui_initial():
	UIHandler.load_unitframes()
@rpc("authority")
func call_set_input_process():
	input.set_process(true)
	input.set_process_unhandled_input(true)

func post_ready(peer_id):
	# some things should be done after _ready is finished
	# add player camera node for authority only
	rpc_id(peer_id,"add_player_camera")
	# add UI elements
	rpc_id(peer_id,"load_ui_initial")
#	# activate input _process for authority
	rpc_id(peer_id,"call_set_input_process")
	if input.is_multiplayer_authority():
		Autoload.player_reference = self
	print("player %s ready" % name)

####################################################################################################
# TARGETING
	# sync target to all peers
func targeting(event_position):
	# send a target ray, and check for collision with any object
	var target_dict = targetray(event_position)
	# check if collision is with a legal target, else set target to null
	if not is_legal_target(target_dict):
		target = null
		$"/root/main/ui/targetframe".target_reference = target
		UIHandler.hide_targetframe()
		return
	target = target_dict["collider"]
	$"/root/main/ui/targetframe".target_reference = target
	UIHandler.show_targetframe()

func targetray(event_position):
	# only the controlling player can do this, as the camera is required
	var origin = $"camera_rotation/camera_arm/player_camera"
	print("getting ray endpoints")
	var from = origin.project_ray_origin(event_position)
	var to = from + origin.project_ray_normal(event_position) * 1000
	print("casting ray")
	var query = PhysicsRayQueryParameters3D.create(from,to)
	print("query space state")
	var target_dict = space_state.intersect_ray(query)
	return target_dict
func is_legal_target(target_dict):
	print("checking target legality")
	# check if there is an object
	if target_dict == {}:
		return false
	# check if object is in appropriate group
	if not (target_dict["collider"].is_in_group("npc") or target_dict["collider"].is_in_group("player")):
		return false
	return true

#func _ready():
#	# TODO: read save file
#	input.set_process(false)
#	if not multiplayer.is_server():
#		return

#func _input(event):
#	if not synchronizer.is_multiplayer_authority():
#		return
#	if event.is_action_pressed("escape") and esc_level == 0:
#		Autoload.player_ui_main_reference.esc_menu()
#	if event.is_action_pressed("interact"):
#		if current_interact_target != null:
#			current_interact_target.interaction_start(self.name)

#func _unhandled_input(event):
#	#targeting
#	if event is InputEventMouseButton and event.pressed and event.button_index == 1:
#		print("re-implement targeting ray in player_input script")
##		# targeting ray
##		var result = targetray(event.position)
##		targeting(result)

#func _process(_delta):
#	# resource regen
##	if stats_curr["resource_regen"] != 0:
##		stats_curr["resource_current"] = max(min(stats_curr["resource_current"]+stats_curr["resource_regen"]*delta,stats_curr["resource_max"]),0)
#	# interaction target sorting
#	if interactables_in_range.size() > 0:
#		var distance = 10000.
#		var distance_new = 0.
#		var old_interactable = null
#		if is_instance_valid(current_interact_target):
#			old_interactable = current_interact_target
#		for interactable_nearby in interactables_in_range:
#			distance_new = self.global_position.distance_to(interactable_nearby.global_position)
#			if distance_new < distance:
#				distance = distance_new
#				current_interact_target = interactable_nearby
#		if not old_interactable == current_interact_target:
#			if is_instance_valid(old_interactable):
#				old_interactable.hide_interact_popup()
#		current_interact_target.show_interact_popup()

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

## set player model
#@rpc("any_peer")
#func set_model(model_name,peer_id):
#	var playernode = $/root/main/players.find_child(str(peer_id),true,false)
#	if playernode.get_child(0).get_child_count() > 0:
#		for node in playernode.get_child(0).get_children():
#			node.queue_free()
#	var model = load(model_name).instantiate()
#	playernode.get_child(0).add_child(model,true)

###################################################################################################
# target ray
#func targetray(eventposition):
#	var origin = player_cam
#	var from = origin.project_ray_origin(eventposition)
#	var to = from + origin.project_ray_normal(eventposition) * 1000
#	var query = PhysicsRayQueryParameters3D.create(from,to)
#	var result = space_state.intersect_ray(query)
#	return result
	
#func targeting(result) -> void:
#	# unset target and return if no collider is hit (like when clicking the sky)
#	if not result.has("collider"):
#		unit_selectedtarget = null
#		Autoload.player_ui_main_reference.targetframe_remove()
#		return
#	# set target if player, npc or hostile is hit by ray
#	if result.collider.is_in_group("playergroup") or result.collider.is_in_group("npcgroup_targetable") or\
#	result.collider.is_in_group("hostilegroup_targetable"):
#		unit_selectedtarget = result.collider
#		Autoload.player_ui_main_reference.targetframe_initialize()
#	# unset target if no valid target is hit by ray
#	else:
#		unit_selectedtarget = null
#		Autoload.player_ui_main_reference.targetframe_remove()
###################################################################################################
# set up spells, auras, absorbs
#func sort_absorbs():
#	pass
###################################################################################################
# get spell target
#func get_spell_target(spell):
#	var spell_target = null
#	var ray_result = null
#	# set target to either mouseovered unit frame or ray collider
#	if unit_mouseover_target != null:
#		spell_target = unit_mouseover_target
#	else:
#		ray_result = targetray(get_viewport().get_mouse_position())
#		# check if target ray result has a collider, and check if collider is a valid result
#		if ray_result.has("collider") and (ray_result.collider.is_in_group("playergroup") or \
#			ray_result.collider.is_in_group("npcgroup_targetable") or\
#			ray_result.collider.is_in_group("hostilegroup_targetable")):
#				spell_target = ray_result.collider
#	# check legality of mouseover target
#	if spell_target == null or not spell_target.is_in_group(spell["targetgroup"]):
#		# illegal mouseover target, set target to selected target
#		spell_target = unit_selectedtarget
#		# check legality of selected target
#		if spell_target == null or not spell_target.is_in_group(spell["targetgroup"]):
#			# illegal selected target as well, cannot use spell, so return
#			return "no_legal_target"
#	# return legal target
#	return spell_target
#
## check target and send combat event from action bar
#func send_combat_event(spell) -> void:
#	var spell_target = null
#	var ray_result = null
#	# set target to either mouseovered unit frame or ray collider
#	if unit_mouseover_target != null:
#		spell_target = unit_mouseover_target
#	else:
#		ray_result = targetray(get_viewport().get_mouse_position())
#		# check if target ray result has a collider, and check if collider is a valid result
#		if ray_result.has("collider") and (ray_result.collider.is_in_group("playergroup") or \
#			ray_result.collider.is_in_group("npcgroup_targetable") or\
#			ray_result.collider.is_in_group("hostilegroup_targetable")):
#				spell_target = ray_result.collider
#	# check legality of mouseover target
#	if spell_target == null or not spell_target.is_in_group(spell["targetgroup"]):
#		# illegal mouseover target, set target to selected target
#		spell_target = unit_selectedtarget
#		# check legality of selected target
#		if spell_target == null or not spell_target.is_in_group(spell["targetgroup"]):
#			# illegal selected target as well, cannot use spell, so return
#			return
#	# legal target found, either from mouseover or selected, so send combat event
#	Combat.combat_event(spell,self,spell_target)
