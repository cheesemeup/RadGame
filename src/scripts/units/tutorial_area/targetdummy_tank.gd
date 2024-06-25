extends BaseUnit

func _enter_tree():
	# only have server process
	$mpsynchronizer.set_multiplayer_authority(1)

func _ready() -> void:
	# initialize BaseUnit
	initialize_base_unit("npc","6")
	set_process(false)
	if $mpsynchronizer.is_multiplayer_authority():
		set_process(true)

func _process(_delta: float) -> void:
	if stats_current["health_current"] <= stats_current["health_max"] * 0.25:
		$"spell_container/spell_2".trigger()
