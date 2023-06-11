extends CharacterBody3D


@onready var player_cam = $camera_rotation/camera_arm/player_camera
@onready var synchronizer = $MultiplayerSynchronizer

var playermodel_reference = null

const speed = 10.0
const jump_velocity = 4.5

# stats
var stats_base : Dictionary
@export var stats_curr : Dictionary
var spells_base : Dictionary
@export var spells_curr : Dictionary

# targeting vars
var space_state
var unit_target = null
var unit_mouseover = null
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
	stats_curr = stats_base
	file = "res://Data/db_spells.json"
	json_dict = JSON.parse_string(FileAccess.get_file_as_string(file))
	spells_base["3"] = json_dict["3"]
	spells_curr = spells_base

func _input(event):
	if not synchronizer.is_multiplayer_authority():
		return
	if event.is_action_pressed("escape") and esc_level == 0:
		Autoload.player_ui_main_reference.esc_menu()
	if event.is_action_pressed("interact"):
		if current_interact_target != null:
			current_interact_target.interaction(self)
	if event.is_action_pressed("actionbar1_1"):
		Combat.combat_event(spells_curr["3"],self,unit_target)
		


func _unhandled_input(event):
	#targeting
	if event is InputEventMouseButton and event.pressed and event.button_index == 1:
		# targeting ray
		targetray(event.position)

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
	# unset target and return if no collider is hit (like when clicking the sky)
	if not result.has("collider"):
		unit_target = null
		Autoload.player_ui_main_reference.targetframe_remove()
		return
	# set target if player, npc or hostile is hit by ray
	if result.collider.is_in_group("playergroup") or result.collider.is_in_group("npcgroup") or\
	result.collider.is_in_group("hostilegroup"):
		unit_target = result.collider
		Autoload.player_ui_main_reference.targetframe_initialize()
	# unset target if no valid target is hit by ray
	else:
		unit_target = null
		Autoload.player_ui_main_reference.targetframe_remove()
