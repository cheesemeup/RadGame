class_name VideoSettings extends Resource

@export var resolution: String
@export var vsync: bool
@export var fullscreen: bool

func _init(
	p_resolution: String = "1920x1080",
	p_vsync = false,
	p_fullscreen: = false,
):
	resolution = p_resolution
	vsync = p_vsync
	fullscreen = p_fullscreen
