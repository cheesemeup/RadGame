extends PanelContainer

@onready var resolution_options: OptionButton = %resolution_options
@onready var vsync_checkbox: CheckBox = %vsync_checkbox
@onready var fullscreen_checkbox: CheckBox = %fullscreen_checkbox
@onready var controls_grid_container: GridContainer = %ControlsGridContainer

@onready var apply_settings_button: Button = %apply_settings_button
@onready var apply_settings_dialog: MarginContainer = %ApplySettingsDialog
@onready var apply_settings_timer_remaining: Label = %ApplySettingsTimerRemaining
@onready var apply_cancel_button: Button = %ApplyCancelButton
@onready var apply_confirm_button: Button = %ApplyConfirmButton
@onready var apply_settings_timer: Timer = %ApplySettingsTimer

const INPUT_REMAP_BUTTON = preload("res://main_menu/InputRemapButton.tscn")

func _ready() -> void:
	SettingsManager.settings_changed.connect(_on_settings_changed)
	SettingsManager.settings_saved.connect(_on_settings_saved)
	SettingsManager.settings_loaded.connect(_on_settings_loaded)
	init_ui()

func _process(_delta: float) -> void:
	apply_settings_timer_remaining.text = str(int(apply_settings_timer.time_left)) + "s"

func _on_resolution_options_item_selected(index: int) -> void:
	if index != -1:
		SettingsManager.get_video_settings().resolution = resolution_options.get_selected_metadata()

func _on_vsync_checkbox_toggled(toggled_on: bool) -> void:
	SettingsManager.get_video_settings().vsync = toggled_on

func _on_fullscreen_checkbox_toggled(toggled_on: bool) -> void:
	SettingsManager.get_video_settings().fullscreen = toggled_on

func _on_apply_settings_button_pressed() -> void:
	SettingsManager.apply_settings(get_tree().root)
	update_ui_pre_apply()

func _on_apply_cancel_button_pressed() -> void:
	SettingsManager.reset_and_apply_settings(get_tree().root)

func _on_apply_confirm_button_pressed() -> void:
	SettingsManager.save_settings()

func _on_apply_settings_timer_timeout() -> void:
	SettingsManager.save_settings()

func _on_settings_loaded() -> void:
	update_ui_post_apply()
	
func _on_settings_saved() -> void:
	update_ui_post_apply()

func _on_settings_changed() -> void:
	apply_settings_button.disabled = false

func _on_remap_action(action: StringName, input_event: InputEvent) -> void:
	print("[settings_menu] setting new key %s for action %s" % [input_event.as_text(), action])
	SettingsManager.get_input_settings().set_action_input_event(action, input_event)

func init_ui() -> void:
	update_video_settings()
	update_input_settings()

func disable_all_settings(disabled: bool = false) -> void:
	resolution_options.disabled = disabled
	vsync_checkbox.disabled = disabled
	fullscreen_checkbox.disabled = disabled
	
	for child in controls_grid_container.get_children():
		if child is Button:
			child.disabled = disabled

func update_ui_pre_apply() -> void:
	apply_settings_button.disabled = true
	if apply_settings_timer.is_stopped():
		apply_settings_timer.start()
	apply_settings_button.hide()
	apply_settings_dialog.show()
	disable_all_settings(true)
	
func update_ui_post_apply() -> void:
	apply_settings_button.disabled = true
	if not apply_settings_timer.is_stopped():
		apply_settings_timer.stop()
	apply_settings_dialog.hide()
	apply_settings_button.show()
	disable_all_settings(false)
	update_video_settings()
	update_input_settings()

func update_video_settings() -> void:
	resolution_options.clear()
	for i in VideoSettings.AVAILABLE_RESOLUTIONS.size():
		var resolution = VideoSettings.AVAILABLE_RESOLUTIONS[i]
		resolution_options.add_item(str(resolution.x) + "x" + str(resolution.y), i)
		resolution_options.set_item_metadata(i, resolution)
	
	resolution_options.select(VideoSettings.AVAILABLE_RESOLUTIONS.find(SettingsManager.get_video_settings().resolution))
	vsync_checkbox.set_pressed_no_signal(SettingsManager.get_video_settings().vsync)
	fullscreen_checkbox.set_pressed_no_signal(SettingsManager.get_video_settings().fullscreen)

func update_input_settings() -> void:
	for child in controls_grid_container.get_children():
		child.queue_free()
	
	for action in SettingsManager.get_input_settings().get_game_actions():
		var label = Label.new()
		label.text = action
		label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		var button = INPUT_REMAP_BUTTON.instantiate()
		button.action = action
		button.input_event = SettingsManager.get_input_settings().get_input_event(action)
		button.remap_action.connect(_on_remap_action)
		controls_grid_container.add_child(label)
		controls_grid_container.add_child(button)
