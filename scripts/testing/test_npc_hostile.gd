extends BaseUnit

func _enter_tree():
	# only have server process
	$mpsynchronizer.set_multiplayer_authority(1)

func _ready():
	# initialize BaseUnit
	initialize_base_unit("npc","2")
	set_process(false)
	if $mpsynchronizer.is_multiplayer_authority():
		set_process(true)

func _process(_delta):
	if stats_current["health_current"] < stats_current["health_max"]/2:
		$"spell_container/spell_2".trigger()
