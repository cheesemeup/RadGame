class_name Settings extends Resource

@export var video_settings: VideoSettings

const SETTINGS_PATH = "user://settings.tres"

func save():
	ResourceSaver.save(self, SETTINGS_PATH)

static func load_or_get_defaults() -> Settings:
	var settings: Settings = ResourceLoader.load(SETTINGS_PATH, "Settings") as Settings
	if !settings:
		settings = Settings.new()
		settings.video_settings = VideoSettings.new()
		settings.video_settings.resolution = "1920x1080"
		settings.video_settings.vsync = false
		settings.video_settings.fullscreen = true
	return settings
