extends Control

var player_reference = null

func _process(delta):
	# update health bar
	$hpbar_value.value = 100 * player_reference.stats_current.health_current / player_reference.stats_current.health_max
	$"hpbar_value/health".text = "%s/%s" % \
		[player_reference.stats_current.health_current, player_reference.stats_current.health_max]
	$"hpbar_value/healthpercent".text = "%.2f%s" % \
		[float(100*player_reference.stats_current.health_current/player_reference.stats_current.health_max), "%"]
	# update resource bar
	$resourcebar_value.value = 100 * player_reference.stats_current.resource_current / player_reference.stats_current.resource_max
	$"resourcebar_value/resource".text = "%s/%s" % \
		[player_reference.stats_current.resource_current, player_reference.stats_current.resource_max]
	$"resourcebar_value/resourcepercent".text = "%.2f%s" % \
		[float(100*player_reference.stats_current.resource_current/player_reference.stats_current.resource_max), "%"]
