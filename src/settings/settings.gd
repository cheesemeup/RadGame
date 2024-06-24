class_name Settings extends Resource

@export var video_settings: VideoSettings
@export var input_settings: InputSettings
@export var gameplay_settings: GameplaySettings

signal saved()

const SAVE_FILE_PATH = "user://user_settings.tres"

static func load_or_get_defaults() -> Settings:
	var settings
	if ResourceLoader.exists(SAVE_FILE_PATH):
		settings = ResourceLoader.load(SAVE_FILE_PATH, "Settings", ResourceLoader.CACHE_MODE_IGNORE)
	else:
		settings = load("res://settings/default_settings.tres")
	
	settings.input_settings.initialize_with_defaults()
	
	if not settings.video_settings.changed.is_connected(settings.emit_changed):
		settings.video_settings.changed.connect(settings.emit_changed)
	if not settings.input_settings.changed.is_connected(settings.emit_changed):
		settings.input_settings.changed.connect(settings.emit_changed)
	if not settings.gameplay_settings.changed.is_connected(settings.emit_changed):
		settings.gameplay_settings.changed.connect(settings.emit_changed)
	
	return settings

func save() -> void:
	ResourceSaver.save(self, SAVE_FILE_PATH)
	saved.emit(self)

func apply(window: Window) -> void:
	video_settings.apply(window)
	input_settings.apply()
	gameplay_settings.apply()

func _to_string() -> String:
	return "%s\n%s\n%s" % [video_settings, input_settings, gameplay_settings]
