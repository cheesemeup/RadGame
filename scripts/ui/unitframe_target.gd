extends Control

var target_reference = null

func _process(delta):
	# return if there is no target set
	if target_reference == null:
		return
	# update health bar
	$hpbar_value.value = 100 * target_reference.stats_current.health_current / target_reference.stats_current.health_max
	$"hpbar_value/health".text = "%s/%s | %.2f%" % \
		[target_reference.stats_current.health_current, target_reference.stats_current.health_max,\
		target_reference.stats_current.health_current/target_reference.stats_current.health_max]
	# update resource bar
	$resourcebar_value.value = 100 * target_reference.stats_current.resource_current / target_reference.stats_current.resource_max
