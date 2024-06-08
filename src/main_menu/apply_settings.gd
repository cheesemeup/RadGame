class_name ApplySettingsHelper extends VBoxContainer

@onready var apply_settings_button: Button = $apply_settings_button
@onready var apply_settings_dialog: HBoxContainer = $ApplySettingsDialog
@onready var apply_settings_timer_remaining: Label = $ApplySettingsDialog/ApplySettingsTimerRemaining
@onready var apply_cancel_button: Button = $ApplySettingsDialog/ApplyCancelButton
@onready var apply_confirm_button: Button = $ApplySettingsDialog/ApplyConfirmButton
@onready var apply_settings_timer: Timer = $ApplySettingsDialog/ApplySettingsTimer

var settings: GameSettings

func _init(settings_to_apply: GameSettings) -> void:
	settings = settings_to_apply

func _ready() -> void:
	settings.saved.connect(update_settings)

func _process(_delta: float) -> void:
	apply_settings_timer_remaining.text = str(int(apply_settings_timer.time_left)) + "s"

func _on_apply_settings_button_pressed() -> void:
	apply_settings_button.disabled = true
	apply_settings_dialog.show()
	if apply_settings_timer.is_stopped():
		apply_settings_timer.start()

func _on_apply_cancel_button_pressed() -> void:
	apply_settings_dialog.hide()
	apply_settings_timer.stop()
	apply_settings_button.disabled = false

func _on_apply_confirm_button_pressed() -> void:
	apply_settings()

func _on_apply_settings_timer_timeout() -> void:
	apply_settings()

func apply_settings() -> void:
	if not apply_settings_timer.is_stopped():
		apply_settings_timer.stop()
	apply_settings_dialog.hide()
	apply_settings_button.disabled = true
	settings.save()

func update_settings(new_settings: GameSettings) -> void:
	apply_settings_button.disabled = false
	settings = new_settings
