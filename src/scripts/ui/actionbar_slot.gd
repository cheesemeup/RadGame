extends Button

var slot_spell_id: String = ""
var spell_cd_timer: Timer
var swipe_enabled = false


func _process(_delta: float) -> void:
	if slot_spell_id == "":
		return
	cooldown_swipe()


func init(spell_info: Array) -> void:
	slot_spell_id = spell_info[0]
	set_icon(spell_info[1])
	set_hotkey()
	pressed.connect(_on_pressed)
	spell_cd_timer = References.player_reference.get_node("cd_timer_container").\
		get_node("cd_timer_spell_%s"%slot_spell_id)


func set_icon(spell_icon) -> void:
	var imagepath = "res://assets/spell_icons/%s.png"%spell_icon
	var image = Image.load_from_file(imagepath)
	var texture = ImageTexture.create_from_image(image)
	icon = texture


func set_hotkey() -> void:
	shortcut = Shortcut.new()
	shortcut.events = InputMap.action_get_events(name)


func _on_pressed() -> void:
	# the rpc call to fire the spell is sent from player_input, as the server does not load
	# the actionbar ui elements of players, and using player_input is somewhat intuitive
	References.player_reference.get_node("player_input").\
		request_enter_spell_container(slot_spell_id)


func cooldown_swipe() -> void:
	# only continue if the cooldown swipe is enabled. It can be disabled 
	# and re-enabled when the slot_spell_id is changed
	if not swipe_enabled:
		return
	if spell_cd_timer.is_stopped():
		return
	$cooldown_swipe.value = spell_cd_timer.time_left / spell_cd_timer.cd_full_duration
