extends Control

func _on_button_exit_game_pressed():
	var timer = Timer.new()
	timer.one_shot = true
	timer.wait_time = 5.0
	timer.timeout.connect(call_main_exit)
	add_child(timer)
	timer.start()
	

func call_main_exit():
	Autoload.main_reference.exit_game()
	
