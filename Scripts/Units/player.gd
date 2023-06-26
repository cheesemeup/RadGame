extends CharacterBody3D


@onready var player_cam = $camera_rotation/camera_arm/player_camera
@onready var synchronizer = $MultiplayerSynchronizer

var playermodel_reference = null

const speed = 10.0
const jump_velocity = 4.5

# stats
var stats_base : Dictionary
var stats_curr : Dictionary
var spells_base : Dictionary
var spells_curr : Dictionary
var aura_dict : Dictionary

# targeting vars
var space_state
var unit_selectedtarget = null
var unit_mouseover_target = null
var interactables_in_range = []
var current_interact_target = null

# other
var esc_level = 0

# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")

func _enter_tree() -> void:
	# We need to set the authority before entering the tree, because by then,
	# we already have started sending data.
	if str(name).is_valid_int():
		var id := str(name).to_int()
		# Before ready, the variable `multiplayer_synchronizer` is not set yet
		$MultiplayerSynchronizer.set_multiplayer_authority(id)

func _ready():
	if not synchronizer.is_multiplayer_authority():
		return
	Autoload.player_reference = self
	player_cam.set_current(true)
	if multiplayer.is_server():
		set_model("res://Scenes/Units/knight_scene.tscn",multiplayer.get_unique_id())
	else:
		rpc_id(1,"set_model","res://Scenes/Units/knight_scene.tscn",multiplayer.get_unique_id())
	# load stats and spells
	var file = "res://Data/db_stats_player.json"
	var json_dict = JSON.parse_string(FileAccess.get_file_as_string(file))
	stats_base = json_dict["0"]
	stats_curr = stats_base.duplicate(true) # can't just assign regularly, since that only creates a new pointer to same dict
	stats_curr.erase("stats_add") # remove modifiers, as they are only needed in base
	stats_curr.erase("stats_mult")
	file = "res://Data/db_spells.json"
	json_dict = JSON.parse_string(FileAccess.get_file_as_string(file))
	spells_base["3"] = json_dict["3"]
	spells_base["5"] = json_dict["5"]
	spells_base["6"] = json_dict["6"]
	spells_base["7"] = json_dict["7"]
	spells_base["8"] = json_dict["8"]
	spells_base["9"] = json_dict["9"]
	spells_curr = spells_base

func _input(event):
	if not synchronizer.is_multiplayer_authority():
		return
	if event.is_action_pressed("escape") and esc_level == 0:
		Autoload.player_ui_main_reference.esc_menu()
	if event.is_action_pressed("interact"):
		if current_interact_target != null:
			current_interact_target.interaction(self)
		


func _unhandled_input(event):
	#targeting
	if event is InputEventMouseButton and event.pressed and event.button_index == 1:
		# targeting ray
		var result = targetray(event.position)
		targeting(result)

func _process(_delta):
	# interaction target sorting
	if interactables_in_range.size() > 0:
		var distance = 10000.
		var distance_new = 0.
		var old_interactable = null
		if is_instance_valid(current_interact_target):
			old_interactable = current_interact_target
		for interactable_nearby in interactables_in_range:
			distance_new = self.global_position.distance_to(interactable_nearby.global_position)
			if distance_new < distance:
				distance = distance_new
				current_interact_target = interactable_nearby
		if not old_interactable == current_interact_target:
			if is_instance_valid(old_interactable):
				old_interactable.hide_interact_popup()
		current_interact_target.show_interact_popup()

func _physics_process(delta):
	# targeting ray
	space_state = get_world_3d().direct_space_state
	if not synchronizer.is_multiplayer_authority(): 
		return
	# jumping
	if Input.is_action_just_pressed("jump") and is_on_floor():
		Autoload.playermodel_reference.get_node("AnimationPlayer").play("KayKit Animated Character|Jump")
		velocity.y = jump_velocity
	# apply gravity if in air
	if not is_on_floor():
		velocity.y -= gravity * delta
	# movement
	var input_dir = Input.get_vector("move_left", "move_right", "move_forward", "move_back")
	# unrotated direction vector
	var direction_ur = (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	# rotate direction vector using camera angle
	var direction = Vector3(cos(2*PI-$camera_rotation.rotation.y)*direction_ur.x - sin(2*PI-$camera_rotation.rotation.y)*direction_ur.z, 0, \
							sin(2*PI-$camera_rotation.rotation.y)*direction_ur.x + cos(2*PI-$camera_rotation.rotation.y)*direction_ur.z)
							
	if direction:
		velocity.x = direction.x * speed
		velocity.z = direction.z * speed
	else:
		velocity.x = move_toward(velocity.x, 0, speed)
		velocity.z = move_toward(velocity.z, 0, speed)
	# turn character to match movement direction
	if direction != Vector3.ZERO:
		$pivot.look_at(position + direction, Vector3.UP)
	# animations
	if Autoload.playermodel_reference != null:
		if velocity == Vector3.ZERO:
			Autoload.playermodel_reference.get_node("AnimationPlayer").play("KayKit Animated Character|Idle")
		else:
			Autoload.playermodel_reference.get_node("AnimationPlayer").play("KayKit Animated Character|Run")
	move_and_slide()

# set player model
@rpc("any_peer")
func set_model(model_name,peer_id):
	var playernode = $/root/main/players.find_child(str(peer_id),true,false)
	if playernode.get_child(0).get_child_count() > 0:
		for node in playernode.get_child(0).get_children():
			node.queue_free()
	var model = load(model_name).instantiate()
	playernode.get_child(0).add_child(model,true)
	
###################################################################################################
# target ray
func targetray(eventposition):
	var origin = player_cam
	var from = origin.project_ray_origin(eventposition)
	var to = from + origin.project_ray_normal(eventposition) * 1000
	var query = PhysicsRayQueryParameters3D.create(from,to)
	var result = space_state.intersect_ray(query)
	return result
	
func targeting(result):
	# unset target and return if no collider is hit (like when clicking the sky)
	if not result.has("collider"):
		unit_selectedtarget = null
		Autoload.player_ui_main_reference.targetframe_remove()
		return
	# set target if player, npc or hostile is hit by ray
	if result.collider.is_in_group("playergroup") or result.collider.is_in_group("npcgroup_targetable") or\
	result.collider.is_in_group("hostilegroup_targetable"):
		unit_selectedtarget = result.collider
		Autoload.player_ui_main_reference.targetframe_initialize()
	# unset target if no valid target is hit by ray
	else:
		unit_selectedtarget = null
		Autoload.player_ui_main_reference.targetframe_remove()

###################################################################################################
# start spell use from action bar
func start_spell_use(spellID):
	# check if spell can be sent directly to combat script, or if it needs to load a scene
	if spells_curr[spellID]["complexity"] == 0:
		send_combat_event(spellID)
	pass

# send combat event from action bar
func send_combat_event(spellID):
	var spell_target = null
	var ray_result = null
	# set target to either mouseovered unit frame or ray collider
	if unit_mouseover_target != null:
		spell_target = unit_mouseover_target
	else:
		ray_result = targetray(get_viewport().get_mouse_position())
		# check if target ray result has a collider, and check if collider is a valid result
		if ray_result.has("collider") and (ray_result.collider.is_in_group("playergroup") or \
			ray_result.collider.is_in_group("npcgroup_targetable") or\
			ray_result.collider.is_in_group("hostilegroup_targetable")):
				spell_target = ray_result.collider
	# check legality of mouseover target
	if spell_target == null or not spell_target.is_in_group(spells_curr[spellID]["targetgroup"]):
		# illegal mouseover target, set target to selected target
		spell_target = unit_selectedtarget
		# check legality of selected target
		if spell_target == null or not spell_target.is_in_group(spells_curr[spellID]["targetgroup"]):
			# illegal selected target as well, cannot use spell, so return
			return
	# legal target found, either from mouseover or selected, so send combat event
	Combat.combat_event(spells_curr[spellID],self,spell_target)
