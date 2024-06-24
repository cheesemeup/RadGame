class_name VideoSettings extends Resource

const AVAILABLE_RESOLUTIONS: Array[Vector2i] = [
	Vector2i(2560, 1440),
	Vector2i(1920, 1080),
	Vector2i(1280, 1024),
]

@export var resolution: Vector2i:
	set(new_value):
		if resolution != new_value:
			resolution = new_value
			emit_changed()

@export var vsync: bool:
	set(new_value):
		if vsync != new_value:
			vsync = new_value
			emit_changed()

@export var fullscreen: bool:
	set(new_value):
		if fullscreen != new_value:
			fullscreen = new_value
			emit_changed()

func apply(window: Window) -> void:
	if DisplayServer.window_get_mode() == DisplayServer.WINDOW_MODE_WINDOWED:
		window.size = resolution
	
	DisplayServer.window_set_vsync_mode(
		DisplayServer.VSYNC_ENABLED if vsync
		else DisplayServer.VSYNC_DISABLED
	)
	
	if fullscreen:
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_EXCLUSIVE_FULLSCREEN)
	else:
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)
		window.size = resolution

func _to_string() -> String:
	return (
		"Video Settings:" +
		"\n\tResolution: " + str(resolution) +
		"\n\tVSync: " + str(vsync) +
		"\n\tFullscreen: " + str(fullscreen)
	)
