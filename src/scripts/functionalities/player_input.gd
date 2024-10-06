extends MultiplayerSynchronizer

@export var direction:= Vector2()
@export var jumping:= false
var space_state


func _ready():
	set_process(false)
	set_process_unhandled_input(false)


func _process(_delta):
	movement_direction()


func _unhandled_input(event):
	# if event is leftclick pressed, send target ray
	if event is InputEventMouseButton and event.pressed and event.button_index == 1:
		get_parent().targeting(event.position)
	## this is a dumbcunt workaround for triggering spells from the actionbar for testing only
	if event is InputEventKey and event.is_action_pressed("interact"):
		rpc_id(1,"request_interaction")


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
func request_interaction():
	if get_parent().current_interactable == null:
		return
	get_parent().current_interactable.trigger(get_parent())
