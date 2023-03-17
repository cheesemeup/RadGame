extends CharacterBody3D


@onready var player_cam = $camera_rotation/camera_arm/player_camera
@onready var synchronizer = $MultiplayerSynchronizer

var playermodel_reference = null

const speed = 14.0
const jump_velocity = 4.5

# targeting vars
var space_state

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
	

func _physics_process(delta):
	# targeting ray
	space_state = get_world_3d().direct_space_state
	if not synchronizer.is_multiplayer_authority(): 
		return
	# MOVEMENT
	# apply gravity
	if not is_on_floor():
		velocity.y -= gravity * delta
	# jump, from default with added animation
	if Input.is_action_just_pressed("jump") and is_on_floor():
		Autoload.playermodel_reference.get_node("AnimationPlayer").play("KayKit Animated Character|Jump")
		velocity.y = jump_velocity
	# movement, based on default
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
	
