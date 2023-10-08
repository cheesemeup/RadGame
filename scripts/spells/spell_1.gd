# Signpost Heal
extends BaseSpell

var cd_timer = Timer.new()
var on_cd = false

func _ready():
	initialize_base_spell("1")
	cd_timer.one_shot = true
	cd_timer.connect("timeout",set_ready.bind())
	add_child(cd_timer)

func trigger(source,target):
	if on_cd:
		print("spell on cooldown")
		return
	# request combat event from server
	var result = Serverscript.request_combat_event_targeted(source,target,spell_current)
	if result < 2:
		if spell_base.on_gcd == 1:
			get_parent().send_gcd
	else:
		print(result_strings[result-2])

func trigger_cd(duration):
	# check if current cooldown exceeds requested cooldown
	if cd_timer.time_left > duration:
		return
	# start timer
	cd_timer.wait_time = duration
	cd_timer.start()
	on_cd = true

func set_ready():
	on_cd = false
