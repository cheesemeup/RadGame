extends CanvasLayer

#func _on_host_button_pressed():
	#print("starting host")
	#Autoload.main_reference.start_hosting()
	#self.queue_free()
	

func _on_join_button_pressed():
	References.main_reference.start_joining($address_entry.text, $port_entry.text.to_int())
	self.queue_free()
	
