extends BaseHostile

var active_name = "active_boss"
var inactive_name = "map01_boss01"


var resource_overflow = 0 # to increment resource by integers, but retain accuracy of float
var bridge_casts = 0


func custom_pre_ready():
	stats_base = preload("res://resources/unit_stats/map01_boss01_stats.tres")
	name = inactive_name

func process_combat(delta) -> void:
	resource_overflow += stats_current["resource_regen"] * delta
	if resource_overflow > 1:
		stats_current["resource_current"] = min(
			stats_current["resource_current"] + floor(resource_overflow),
			stats_current["resource_max"]
			)
		resource_overflow -= floor(resource_overflow)
	if stats_current["resource_current"] >= stats_current["resource_max"]:
		bridge_casts += 1
		print("bridge casts: %s"%bridge_casts)
		stats_current["resource_current"] = stats_base.resource_init
