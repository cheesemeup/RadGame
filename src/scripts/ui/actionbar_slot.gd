extends Button

var spell_id: String
var spell_icon: String


func init(spell_info: Array):
	spell_id = spell_info[0]
	spell_icon = spell_info[1]
	var imagepath = "res://assets/spell_icons/%s.png"%spell_icon
	var image = Image.load_from_file(imagepath)
	var texture = ImageTexture.create_from_image(image)
	icon = texture
	shortcut.events = InputMap.action_get_events(name)


func _on_pressed():
	rpc_id(1,"send_spell_request")


@rpc("any_peer","call_local")
func send_spell_request():
	References.player_reference.get_node("player_input").enter_spell_container(spell_id)
