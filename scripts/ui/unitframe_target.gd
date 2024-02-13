extends Control

var target_reference = null

func _process(delta):
	if target_reference == null:
		return
	# update health bar
	print(target_reference)
	print(target_reference.stats)
	print(target_reference.stats.stats_current)
	print(target_reference.stats.stats_current.health_current)
	$hpbar_value.value = 100 * target_reference.stats.stats_current.health_current / target_reference.stats.stats_current.health_max
	# update resource bar
	$resourcebar_value.value = 100 * target_reference.stats.stats_current.resource_current / target_reference.stats.stats_current.resource_max
