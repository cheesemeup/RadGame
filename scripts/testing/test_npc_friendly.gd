extends BaseUnit

# prepare test np hostile for testing combat spells

@export var stats_curr: Dictionary
var spells_base: Dictionary
@export var spells_curr: Dictionary

func _ready():
	# load stats and spells
	var file = "res://data/db_stats_npc.json"
	var json_dict = JSON.parse_string(FileAccess.get_file_as_string(file))
	stats_base = json_dict["3"]
	stats_curr = stats_base.duplicate(true)
	file = "res://data/db_spells.json"
	json_dict = JSON.parse_string(FileAccess.get_file_as_string(file))
	spells_base["4"] = json_dict["4"]
	spells_curr = spells_base.duplicate(true)

#func _process(_delta):
#	if stats_curr["health_current"] == stats_curr["health_max"]:
#		Combat.event_damage(spells_curr["4"],self,self)
