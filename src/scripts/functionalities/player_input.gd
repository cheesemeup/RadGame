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
	#if event is InputEventKey and event.is_action_pressed("actionbar1_1"):
		#rpc_id(1,"enter_spell_container","11")
	if event is InputEventKey and event.is_action_pressed("interact"):
		rpc_id(1,"request_interaction")

####################################################################################################
# MOVEMENT
@rpc("call_local")
func jump():
	jumping = true
func movement_direction():
	# unrotated direction from input
	var direction_ur = Input.get_vector("move_left","move_right","move_forward","move_back")
	# rotate input according to camera orientation
	direction = Vector2(cos(-$"../camera_rotation".rotation.y)*direction_ur.x -\
						sin(-$"../camera_rotation".rotation.y)*direction_ur.y, \
						sin(-$"../camera_rotation".rotation.y)*direction_ur.x +\
						cos(-$"../camera_rotation".rotation.y)*direction_ur.y)
	if Input.is_action_just_pressed("jump"):
		jump.rpc()

####################################################################################################
# SPELLS
@rpc("authority")
func enter_spell_container(spell_id: String):
	$"../spell_container".spell_entrypoint(spell_id)

@rpc("authority")
func request_interaction():
	get_parent().current_interactable.trigger(get_parent())
