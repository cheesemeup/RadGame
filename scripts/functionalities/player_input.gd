extends MultiplayerSynchronizer

@export var direction:= Vector2()
@export var jumping:= false

func _ready():
	set_process(false)

func _process(_delta):
	movement_direction()
	
func _unhandled_input(event):
	# if event is leftclick, send target ray
	if event is InputEventMouseButton and event.pressed and event.button_index == 1:
		print("call to targeting")
		targeting()

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


####################################################################################################
# TARGETING
func targeting():
	# When an unhandled leftclick occurs, send targeting ray to detect collision with unit
	print("call to targetray")
	var collision_object = targetray()
	# check if there is collision with an object, and if that object is a legal target
	# set target if legal, show target frame if not already visible
	var target = collision_object
	# set target to null if not legal, hide target frame if not already hidden
	# rpc call to player script to set target
func targetray():
	pass
