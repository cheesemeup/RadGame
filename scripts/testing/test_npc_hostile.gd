extends BaseUnit

@export var stats_curr: Dictionary
var spells_base: Dictionary
@export var spells_curr: Dictionary

func _ready():
	# initialize BaseUnit
	initialize_base_unit("npc","2")
	var file = "res://data/db_stats_npc.json"
	var json_dict = JSON.parse_string(FileAccess.get_file_as_string(file))
	stats_base = json_dict["2"]
	stats_curr = stats_base.duplicate(true)
	file = "res://data/db_spells.json"
	json_dict = JSON.parse_string(FileAccess.get_file_as_string(file))
	spells_base["2"] = json_dict["2"]
	spells_curr = spells_base.duplicate(true)

#func _process(_delta):
#	if stats_curr["health_current"] < stats_curr["health_max"]/2:
#		Combat.event_heal(spells_curr["2"],self,self)
