extends CanvasLayer

func _on_host_button_pressed():
	# initialize as a server. docs were outdated so used blog post info
	print("starting host")
	Autoload.main_reference.start_hosting()
	self.queue_free()
	

func _on_join_button_pressed():
	print("starting join")
	Autoload.main_reference.start_joining($address_entry.text)
	# initialize as a client. docs were outdated so used blog post info
	self.queue_free()
	
