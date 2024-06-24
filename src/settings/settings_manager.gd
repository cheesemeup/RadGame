extends Node

signal settings_loaded()
signal settings_changed
signal settings_saved

@onready var settings:
	set(new_settings):
		settings = new_settings
		settings.changed.connect(func (): settings_changed.emit())
		settings.saved.connect(func (_settings): settings_saved.emit())
		settings_loaded.emit()

func _ready() -> void:
	print("[SettingsManager] load")
	settings = Settings.load_or_get_defaults()
	print(settings)

func apply_settings(window: Window):
	print("[SettingsManager] apply")
	settings.apply(window)

func save_settings() -> void:
	print("[SettingsManager] save")
	settings.save()

func reset_and_apply_settings(window: Window) -> void:
	print("[SettingsManager] reset and apply")
	settings = Settings.load_or_get_defaults()
	settings.apply(window)

func get_video_settings() -> VideoSettings:
	return settings.video_settings

func get_input_settings() -> InputSettings:
	return settings.input_settings

func get_gameplay_settings() -> GameplaySettings:
	return settings.gameplay_settings
