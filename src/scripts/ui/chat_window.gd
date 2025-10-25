extends Control


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	var verticalscrollbar: VScrollBar = $FoldableContainer/VBoxContainer/hbox_messages/ScrollContainer.get_v_scroll_bar()
	verticalscrollbar.value = verticalscrollbar.max_value


func _on_text_edit_text_submitted(new_text: String) -> void:
	if new_text.begins_with("/"):
		handle_chat_command(new_text)
		$FoldableContainer/VBoxContainer/hbox_chatbar/chat_input.clear()
		return
	var sender = References.player_reference.stats_current.unit_name
	var messageFormatted: String = sender + ": " + new_text
	write_message.rpc(messageFormatted)
	$FoldableContainer/VBoxContainer/hbox_chatbar/chat_input.clear()

@rpc("any_peer", "call_local")
func write_message(message: String) -> void:
	var newmsg = Label.new()
	newmsg.text = message
	$FoldableContainer/VBoxContainer/hbox_messages/ScrollContainer/MessageContainer.add_child(newmsg)


func handle_chat_command(command: String) -> void:
	print("HACKED ", command)
	References.player_reference.request_unstuck.rpc()
