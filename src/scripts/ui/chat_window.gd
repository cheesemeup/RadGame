extends Control

var scroll_container: ScrollContainer
var scroll_bar: VScrollBar

func _ready() -> void:
	scroll_bar = $FoldableContainer/VBoxContainer/hbox_messages/ScrollContainer.get_v_scroll_bar()
	scroll_container = $FoldableContainer/VBoxContainer/hbox_messages/ScrollContainer
	scroll_bar.value = scroll_bar.max_value
	

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
	var should_auto_scroll = ((scroll_bar.max_value - scroll_container.size.y) - scroll_bar.value) <= 0
	if should_auto_scroll:
		call_deferred("scroll_to_bottom")


func handle_chat_command(_command: String) -> void:
	References.player_reference.request_unstuck.rpc()


func scroll_to_bottom() -> void:
	scroll_bar.set_deferred("value", scroll_bar.max_value)
