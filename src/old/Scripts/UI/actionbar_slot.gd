extends Button

var linkedspell = self
var on_cd = false

func _ready():
	connect("pressed",_on_pressed.bind())

func assign_actionbar(spell_scene):
	linkedspell = spell_scene
	var imagepath = str("res://Assets/Spell_Icons/"+linkedspell.spell_curr["icon"]+".png")
	var image = Image.load_from_file(imagepath)
	var texture = ImageTexture.create_from_image(image)
	icon = texture

func _process(_delta):
	if on_cd:
		$cooldownswipe.value = linkedspell.cd_timer.time_left

func _on_pressed():
	# return if no spell bound
	if linkedspell == self:
		print("no spell bound")
		return
	# trigger spell scene
	linkedspell.trigger()

func start_cd(duration):
	$cooldownswipe.visible = true
	on_cd = true
	$cooldownswipe.max_value = duration

func end_cd():
	$cooldownswipe.visible = false
	on_cd = false
