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
		print("call to targetray in playerscript")
		get_parent().targeting(event.position)

####################################################################################################
# MOVEMENT
@rpc("call_local")
func jump():
	jumping = true
func movement_direction():
	# unrotated direction from input
	var direction_ur = Input.get_vector("move_left","move_right","move_forward","move_back")
	# rotate input according to camera orientation
	direction = Vector2(cos(-$"../camera_rotation".rotation.y)*direction_ur.x - sin(-$"../camera_rotation".rotation.y)*direction_ur.y, \
						sin(-$"../camera_rotation".rotation.y)*direction_ur.x + cos(-$"../camera_rotation".rotation.y)*direction_ur.y)
	if Input.is_action_just_pressed("jump"):
		jump.rpc()
