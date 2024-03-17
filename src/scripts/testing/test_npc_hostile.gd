extends BaseUnit

func _ready():
	# initialize BaseUnit
	initialize_base_unit("npc","2")

#func _process(_delta):
#	if stats_curr["health_current"] < stats_curr["health_max"]/2:
#		Combat.event_heal(spells_curr["2"],self,self)
