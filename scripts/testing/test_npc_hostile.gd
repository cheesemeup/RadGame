extends BaseUnit

func _ready():
	# initialize BaseUnit
	initialize_base_unit("npc","2")

func _process(_delta):
	if stats_current["health_current"] < stats_current["health_max"]/2:
		$"spell_container/spell_2".trigger()
