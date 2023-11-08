extends MultiplayerSynchronizer

@export var direction:= Vector2()
@export var jumping:= false

func _enter_tree():
	set_multiplayer_authority(get_parent().name.to_int())
	set_process(false)

#func _ready():
#	set_process(false)

@rpc("call_local")
func jump():
	jumping = true

func _process(_delta):
	# unrotated direction from input
	var direction_ur = Input.get_vector("move_left","move_right","move_forward","move_back")
	# rotate input according to camera orientation
	direction = Vector2(cos(-$"../camera_rotation".rotation.y)*direction_ur.x - sin(-$"../camera_rotation".rotation.y)*direction_ur.y, \
						sin(-$"../camera_rotation".rotation.y)*direction_ur.x + cos(-$"../camera_rotation".rotation.y)*direction_ur.y)
	if Input.is_action_just_pressed("jump"):
		jump.rpc()
