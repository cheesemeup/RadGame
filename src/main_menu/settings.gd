class_name GameSettings extends Resource

signal saved(settings: GameSettings)

const SAVE_FILE_PATH = "user://game_settings.tres"

@export var resolution: Vector2i = Vector2i(1920, 1080):
	set(new_value):
		if resolution != new_value:
			resolution = new_value
			emit_changed()

@export var vsync: bool = false:
	set(new_value):
		if vsync != new_value:
			vsync = new_value
			emit_changed()

@export var fullscreen: bool = false:
	set(new_value):
		if fullscreen != new_value:
			fullscreen = new_value
			emit_changed()

static func load_or_get_defaults() -> GameSettings:
	var settings: GameSettings
	if ResourceLoader.exists(SAVE_FILE_PATH):
		settings = ResourceLoader.load(SAVE_FILE_PATH, "GameSettings", ResourceLoader.CACHE_MODE_IGNORE)
	else:
		settings = GameSettings.new()
	printt("settings loaded", settings)
	return settings

func save() -> void:
	printt("settings saved", self)
	ResourceSaver.save(self, SAVE_FILE_PATH)
	saved.emit(self)

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
		"GameSettings:\n" +
		"\tResolution: " + str(resolution) +
		"\tVSync: " + str(vsync) +
		"\tFullscreen: " + str(fullscreen)
	)
