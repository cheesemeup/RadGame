extends Control

var target_reference = null

func _process(delta):
	if target_reference == null:
		return
	# update health bar
	$hpbar_value.value = 100 * target_reference.stats.stats_current.health_current / target_reference.stats.stats_current.health_max
	# update resource bar
	$resourcebar_value.value = 100 * target_reference.stats.stats_current.resource_current / target_reference.stats.stats_current.resource_max
