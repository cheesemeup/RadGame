extends Control

var exit_timer = Timer.new()
var update_timer = Timer.new()
var time_remaining = 10

func _ready():
	Autoload.player_ui_main_reference.get_node("escape_menu_root").queue_free()
	exit_timer.one_shot = true
	exit_timer.wait_time = float(time_remaining)
	exit_timer.connect("timeout",Autoload.main_reference.exit_game)
	update_timer.one_shot = false
	update_timer.wait_time = 1
	update_timer.connect("timeout",update_countdown)
	add_child(exit_timer)
	add_child(update_timer)
	exit_timer.start()
	update_timer.start()

func update_countdown():
	time_remaining -= 1
	$exit_countdown.text = str(time_remaining)

func _on_exit_now_pressed():
	Autoload.main_reference.exit_game()

func _on_cancel_pressed():
	exit_timer.stop()
	update_timer.stop()
	queue_free()
