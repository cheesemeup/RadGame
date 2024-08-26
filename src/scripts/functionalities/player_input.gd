extends MultiplayerSynchronizer

@export var direction:= Vector2()
@export var jumping:= false
var space_state
var ground_target_circle_reference = null

func _ready():
	set_process(false)
	set_process_unhandled_input(false)


func _process(_delta):
	movement_direction()
	if get_parent().is_ground_targeting["state"]:
		ground_target_func(get_viewport().get_mouse_position())


func _unhandled_input(event):
	# if event is leftclick pressed, send target ray
	if event is InputEventMouseButton and event.pressed and event.button_index == 1:
		if get_parent().is_ground_targeting["state"]:
			print("clicked for ground effect")
			rpc_id(1,"enter_spell_ground_effect", get_parent().is_ground_targeting["spell_id"],\
					 get_parent().targetray(get_viewport().get_mouse_position()).position )
		else:
			get_parent().targeting(event.position)
	## this is a dumbcunt workaround for triggering spells from the actionbar for testing only
	if event is InputEventKey and event.is_action_pressed("actionbar1_1"):
		rpc_id(1,"enter_spell_container","16")


####################################################################################################
# MOVEMENT
@rpc("any_peer","call_local")
func set_strafing(strafing_left: bool, strafing_right: bool) -> void:
	# do not allow strafing if player is dead
	if get_parent().is_dead:
		return
	if not get_parent().is_strafing_left == strafing_left:
		get_parent().is_strafing_left = strafing_left
	if not get_parent().is_strafing_right == strafing_right:
		get_parent().is_strafing_right = strafing_right


@rpc("any_peer","call_local")
func set_backpedaling(backwards: bool) -> void:
	# do not allow backpedaling if player is dead
	if get_parent().is_dead:
		return
	if not get_parent().is_backpedaling == backwards:
		get_parent().is_backpedaling = backwards


@rpc("call_local")
func jump():
	jumping = true


func movement_direction():
	# unrotated direction from input
	var direction_ur = Input.get_vector("move_left","move_right","move_forward","move_back")
	# set strafing
	var strafing_left = false
	var strafing_right = false
	if direction_ur.x < 0:
		strafing_left = true
	if direction_ur.x > 0:
		strafing_right = true
	rpc_id(1,"set_strafing",strafing_left,strafing_right)
	# set backpedaling
	var backwards = false
	if direction_ur.y > 0:
		backwards = true
	rpc_id(1,"set_backpedaling",backwards)
	# rotate input according to camera orientation
	direction = Vector2(cos(-$"../camera_rotation".rotation.y)*direction_ur.x -\
						sin(-$"../camera_rotation".rotation.y)*direction_ur.y, \
						sin(-$"../camera_rotation".rotation.y)*direction_ur.x +\
						cos(-$"../camera_rotation".rotation.y)*direction_ur.y)
	if Input.is_action_just_pressed("jump"):
		jump.rpc()


####################################################################################################
# SPELLS
func request_enter_spell_container(spell_id: String):
	rpc_id(1,"enter_spell_container",spell_id)


@rpc("authority","call_local")
func enter_spell_container(spell_id: String):
	$"../spell_container".spell_entrypoint(spell_id)

@rpc("authority","call_local")
func enter_spell_ground_effect(spell_id: String, position: Vector3):
	print("rpc with id: " + spell_id + " and pos " + str(position))
	get_parent().is_ground_targeting["state"] = false
	$"../spell_container".ground_effect_entrypoint(spell_id, position)


@rpc("authority","call_local")
func request_interaction():
	get_parent().current_interactable.trigger(get_parent())

### 
# TARGETING CIRCLE

func ground_target_func(mouse_position: Vector2):
	# create the targeting circle if needed
	if ground_target_circle_reference == null:
		var circle = preload("res://scenes/functionalities/visual_ground_target_circle.tscn")
		var instance = circle.instantiate()
		add_child(instance)
		ground_target_circle_reference = instance
	var hits = get_parent().targetray(mouse_position)
	# todo: remove circle if no hit/invalid hit
	if hits != {}:
		ground_target_circle_reference.global_position = hits.position
	
