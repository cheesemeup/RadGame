extends PanelContainer

signal start_join
signal start_host

@onready var address_entry: LineEdit = %address_entry
@onready var port_entry: LineEdit = %port_entry

func _on_host_button_pressed():
	print("starting host")
	References.main_reference.start_hosting(
		port_entry.text.to_int()
	)

func _on_join_button_pressed():
	References.main_reference.start_joining(
		address_entry.text,
		port_entry.text.to_int()
	)
