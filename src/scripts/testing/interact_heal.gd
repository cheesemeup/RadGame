extends BaseUnit

#var stats_base: Dictionary
#@export var stats_curr: Dictionary
#var spells_base: Dictionary
#@export var spells_curr: Dictionary
#
#func _ready():
	## load stats and spells
	#var file = "res://data/db_stats_npc.json"
	#var json_dict = JSON.parse_string(FileAccess.get_file_as_string(file))
	#stats_base = json_dict["1"]
	#stats_curr = stats_base
	#file = "res://data/db_spells.json"
	#json_dict = JSON.parse_string(FileAccess.get_file_as_string(file))
	#spells_base["0"] = json_dict["1"]
	#spells_curr = spells_base
#
#func interaction(body):
	#Combat.event_heal(spells_curr["0"],self,body)
