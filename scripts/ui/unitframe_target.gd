extends Control

var target_reference = null

func _process(_delta):
	# return if there is no target set
	if target_reference == null:
		return
	# update health bar
	$hpbar_value.value = 100 * target_reference.stats_current.health_current / target_reference.stats_current.health_max
	$"hpbar_value/health".text = "%s/%s" % \
		[target_reference.stats_current.health_current, target_reference.stats_current.health_max]
	$"hpbar_value/healthpercent".text = "%.2f%s" % \
		[float(100*target_reference.stats_current.health_current/target_reference.stats_current.health_max), "%"]
	# update resource bar
	$resourcebar_value.value = 100 * target_reference.stats_current.resource_current / target_reference.stats_current.resource_max
	$"resourcebar_value/resource".text = "%s/%s" % \
		[target_reference.stats_current.resource_current, target_reference.stats_current.resource_max]
	$"resourcebar_value/resourcepercent".text = "%.2f%s" % \
		[float(100*target_reference.stats_current.resource_current/target_reference.stats_current.resource_max), "%"]
