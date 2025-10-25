extends Control


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	var verticalscrollbar: VScrollBar = %ScrollContainer.get_v_scroll_bar()
	verticalscrollbar.value = verticalscrollbar.max_value


func _on_text_edit_text_submitted(new_text: String) -> void:
	if new_text.begins_with("/"):
		handle_chat_command(new_text)
		%chat_input.clear()
		return
	var sender = References.player_reference.stats_current.unit_name
	var messageFormatted: String = sender + ": " + new_text
	write_message.rpc(messageFormatted)
	%chat_input.clear()

@rpc("any_peer", "call_local", "reliable")
func write_message(message: String) -> void:
	var newmsg = Label.new()
	newmsg.text = message
	%MessageContainer.add_child(newmsg)



func handle_chat_command(command: String) -> void:
	print("HACKED ", command)
	References.player_reference.rpc_id(1, "request_unstuck")
