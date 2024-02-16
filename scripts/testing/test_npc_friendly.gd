extends BaseUnit

func _enter_tree():
	# only have server process
	$mpsynchronizer.set_multiplayer_authority(1)

func _ready():
	# initialize BaseUnit
	initialize_base_unit("npc","3")
	if $mpsynchronizer.is_multiplayer_authority():
		set_process(true)

#func _process(_delta):
#	if stats_curr["health_current"] == stats_curr["health_max"]:
#		Combat.event_damage(spells_curr["4"],self,self)
