extends BaseUnit

func _ready():
	# initialize BaseUnit
	initialize_base_unit("npc","3")

#func _process(_delta):
#	if stats_curr["health_current"] == stats_curr["health_max"]:
#		Combat.event_damage(spells_curr["4"],self,self)
