extends Button

var slot_spell_id: String
var slot_spell_reference: Node


func _process(_delta: float) -> void:
	cooldown_swipe()


func init(spell_id: String) -> void:
	slot_spell_id = spell_id
	slot_spell_reference = References.player_reference.get_node("spell_container").\
		get_node("spell_%s"%slot_spell_id)
	print("spell reference: %s"%"spell_%s"%slot_spell_id)
	print(slot_spell_reference)
	set_icon()
	set_hotkey()
	pressed.connect(_on_pressed)
	set_process(true)


func set_icon() -> void:
	var spell_icon = References.player_reference.get_node("spell_container").\
		get_node("spell_%s"%slot_spell_id).spell_current["icon"]
	var imagepath = "res://assets/spell_icons/%s.png"%spell_icon
	var image = Image.load_from_file(imagepath)
	var texture = ImageTexture.create_from_image(image)
	icon = texture


func set_hotkey() -> void:
	print("setting hotkey for %s to %s"%[name,InputMap.action_get_events(name)])
	shortcut = Shortcut.new()
	shortcut.events = InputMap.action_get_events(name)
	print("hotkey for %s is set as %s"%[name,shortcut.events])


func _on_pressed() -> void:
	# the rpc call to fire the spell is sent from player_input, as the server does not load
	# the actionbar ui elements of players, and using player_input is somewhat intuitive
	References.player_reference.get_node("player_input").\
		request_enter_spell_container(slot_spell_id)


func cooldown_swipe() -> void:
	# set swipe position if on cd
	# return if no spell is set to this slot
	if slot_spell_reference == null:
		return
	if slot_spell_reference.is_on_cd():
		# cooldown swipe is inverse, i.e. goes from 1 to 0
			$cooldown_swipe.value = slot_spell_reference.cd_timer.time_left / \
				slot_spell_reference.cd_timer.wait_time
