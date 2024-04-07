extends PanelContainer

const RESOLUTIONS = ["2560x1440", "1920x1080", "1280x1024"]

@onready var resolution_options: OptionButton = %resolution_options
@onready var vsync_checkbox: CheckBox = %vsync_checkbox
@onready var fullscreen_checkbox: CheckBox = %fullscreen_checkbox

var userSettings: Settings

func _ready():
	userSettings = Settings.load_or_get_defaults()
	if resolution_options:
		for i in RESOLUTIONS.size():
			resolution_options.add_item(RESOLUTIONS[i], i)
			resolution_options.set_item_metadata(i, RESOLUTIONS[i])
		resolution_options.select(RESOLUTIONS.find(userSettings.video_settings.resolution))
	if vsync_checkbox:
		vsync_checkbox.set_pressed_no_signal(userSettings.video_settings.vsync)
	if fullscreen_checkbox:
		fullscreen_checkbox.set_pressed_no_signal(userSettings.video_settings.fullscreen)

func _on_resolution_options_item_selected(index):
	if index != -1:
		userSettings.video_settings.resolution = resolution_options.get_item_metadata(index)

func _on_vsync_checkbox_toggled(toggled_on):
	userSettings.video_settings.vsync = toggled_on

func _on_fullscreen_checkbox_toggled(toggled_on):
	userSettings.video_settings.fullscreen = toggled_on

func _on_apply_settings_button_pressed():
	userSettings.save()
