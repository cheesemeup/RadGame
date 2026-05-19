extends BaseHostile

var active_name = "active_boss"
var inactive_name = "map01_boss01"


func custom_pre_ready():
	stats_base = preload("res://resources/hostile_stats/map01_boss01_stats.tres")
	name = inactive_name

func process_combat() -> void:
	pass
