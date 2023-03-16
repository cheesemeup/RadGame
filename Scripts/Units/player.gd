extends CharacterBody3D


@onready var player_cam = $camera_rotation/camera_arm/player_camera
@onready var synchronizer = %MultiplayerSynchronizer

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
		%MultiplayerSynchronizer.set_multiplayer_authority(id)

func _ready():
	print("player ready func")
	if not is_multiplayer_authority():
		return
	Autoload.player_reference = self
	player_cam.set_current(true)
	set_model("res://Scenes/Units/knight_scene.tscn")
	

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
		Autoload.playermodel_reference.look_at(position - direction, Vector3.UP)
	# animations
	if velocity == Vector3.ZERO:
		Autoload.playermodel_reference.get_node("AnimationPlayer").play("KayKit Animated Character|Idle")
	else:
		Autoload.playermodel_reference.get_node("AnimationPlayer").play("KayKit Animated Character|Run")
	
	move_and_slide()

# set player model
func set_model(model_name):
	if Autoload.playermodel_reference != null:
		Autoload.playermodel_reference.queue_free()
		Autoload.player_reference = null
	print(model_name)
	var model = load(model_name).instantiate()
	print(model)
	add_child(model)
	Autoload.playermodel_reference = model
	print(Autoload.playermodel_reference)
