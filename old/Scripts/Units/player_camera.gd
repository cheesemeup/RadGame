extends Node3D

var camrot_h = 0
var camrot_v = 0
var cam_v_min = -75
var cam_v_max = 55
var h_sensitivity = 0.3
var v_sensitivity = 0.3
var h_acceleration = 10
var v_acceleration = 10
var mouse_position


func _input(event):
		# get mouse position when click is initiated and hide cursor
	if event is InputEventMouseButton and Input.is_action_just_pressed("rightclick"):
		mouse_position = event.position
		print(mouse_position)
		Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)

	# move camera if rightlick is pressed
	if event is InputEventMouseMotion and Input.is_action_pressed("rightclick"):
		self.rotation_degrees.y -= event.relative.x * h_sensitivity
		camrot_v = clamp(camrot_v - event.relative.y * v_sensitivity, cam_v_min, cam_v_max)
		self.rotation_degrees.x = camrot_v

	# move mouse to last visible position and show cursor
	if Input.is_action_just_released("rightclick"):
		get_viewport().warp_mouse(mouse_position)
		Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
