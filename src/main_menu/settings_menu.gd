extends PanelContainer

const AVAILABLE_RESOLUTIONS: Array[Vector2i] = [
	Vector2i(2560, 1440),
	Vector2i(1920, 1080),
	Vector2i(1280, 1024),
]

@onready var resolution_options: OptionButton = $VBoxContainer/MarginContainer/VBoxContainer/GridContainer/resolution_options
@onready var vsync_checkbox: CheckBox = $VBoxContainer/MarginContainer/VBoxContainer/GridContainer/vsync_checkbox
@onready var fullscreen_checkbox: CheckBox = $VBoxContainer/MarginContainer/VBoxContainer/GridContainer/fullscreen_checkbox
@onready var apply_settings_button: Button = $VBoxContainer/apply_settings_button
@onready var apply_settings_dialog: MarginContainer = $VBoxContainer/ApplySettingsDialog
@onready var apply_settings_timer_remaining: Label = $VBoxContainer/ApplySettingsDialog/HBoxContainer/ApplySettingsTimerRemaining
@onready var apply_cancel_button: Button = $VBoxContainer/ApplySettingsDialog/HBoxContainer/ApplyCancelButton
@onready var apply_confirm_button: Button = $VBoxContainer/ApplySettingsDialog/HBoxContainer/ApplyConfirmButton
@onready var apply_settings_timer: Timer = $VBoxContainer/ApplySettingsDialog/HBoxContainer/ApplySettingsTimer

var settings: GameSettings

func _ready() -> void:
	for i in AVAILABLE_RESOLUTIONS.size():
		var resolution = AVAILABLE_RESOLUTIONS[i]
		resolution_options.add_item(str(resolution.x) + "x" + str(resolution.y), i)
		resolution_options.set_item_metadata(i, resolution)
	
	load_settings_from_file()
	update_ui()

func _process(_delta: float) -> void:
	apply_settings_timer_remaining.text = str(int(apply_settings_timer.time_left)) + "s"

func _on_resolution_options_item_selected(index: int) -> void:
	if index != -1:
		settings.resolution = resolution_options.get_selected_metadata()

func _on_vsync_checkbox_toggled(toggled_on: bool) -> void:
	settings.vsync = toggled_on

func _on_fullscreen_checkbox_toggled(toggled_on: bool) -> void:
	settings.fullscreen = toggled_on

func _on_apply_settings_button_pressed() -> void:
	settings.apply(get_tree().root)
	update_ui(true)

func _on_apply_cancel_button_pressed() -> void:
	load_settings_from_file()
	settings.apply(get_tree().root)
	update_ui()

func _on_apply_confirm_button_pressed() -> void:
	settings.save()

func _on_apply_settings_timer_timeout() -> void:
	settings.save()

func _on_settings_changed() -> void:
	apply_settings_button.disabled = false
	
func _on_settings_saved(_new_settings: GameSettings) -> void:
	update_ui()

func load_settings_from_file() -> void:
	settings = GameSettings.load_or_get_defaults()
	settings.changed.connect(_on_settings_changed)
	settings.saved.connect(_on_settings_saved)

func update_ui(show_apply_dialog: bool = false) -> void:
	apply_settings_button.disabled = true
	if show_apply_dialog:
		if apply_settings_timer.is_stopped():
			apply_settings_timer.start()
		apply_settings_button.hide()
		apply_settings_dialog.show()
	else:
		if not apply_settings_timer.is_stopped():
			apply_settings_timer.stop()
		apply_settings_dialog.hide()
		apply_settings_button.show()
	
	resolution_options.select(AVAILABLE_RESOLUTIONS.find(settings.resolution))
	resolution_options.disabled = apply_settings_dialog.visible
	vsync_checkbox.set_pressed_no_signal(settings.vsync)
	vsync_checkbox.disabled = apply_settings_dialog.visible
	fullscreen_checkbox.set_pressed_no_signal(settings.fullscreen)
	fullscreen_checkbox.disabled = apply_settings_dialog.visible
