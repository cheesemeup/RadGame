extends MultiplayerSynchronizer

@export var direction:= Vector2()
@export var jumping:= false

# Called when the node enters the scene tree for the first time.
func _ready():
	set_process(get_multiplayer_authority() == multiplayer.get_unique_id())

@rpc("call_local")
func jump():
	jumping = true

func _process(_delta):
	if self.is_multiplayer_authority():
		print("process call authority")
	print("process call all")
	# unrotated direction from input
	var direction_ur = Input.get_vector("move_left","move_right","move_forward","move_back")
	# rotate input according to camera orientation
	direction = Vector2(cos(-$"../camera_rotation".rotation.y)*direction_ur.x - sin(-$"../camera_rotation".rotation.y)*direction_ur.y, \
						sin(-$"../camera_rotation".rotation.y)*direction_ur.x + cos(-$"../camera_rotation".rotation.y)*direction_ur.y)
	if Input.is_action_just_pressed("jump"):
		jump.rpc()
	print("direction input: ",direction)
