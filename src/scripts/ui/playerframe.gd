extends Control

func _process(_delta):
	pass
	# update player frame
#	if $playerframe_hpbar.visible:
#		$playerframe_hpbar.value = 100 * \
#			Autoload.player_reference.stats.stats_current.health_current / \
#			Autoload.player_reference.stats.stats_current.health_max
#		$playerframe_hpvalue.text = "%.f / %.f\n %.2f%s" % [
#			Autoload.player_reference.stats.stats_current.health_current, \
#			Autoload.player_reference.stats.stats_current.health_max,
#			100. *\
#			Autoload.player_reference.stats.stats_current.health_current/ \
#			Autoload.player_reference.stats.stats_current.health_max,"%"
#		]
#	if $playerframe_resbar.visible: 
#		$playerframe_resbar.value = 100 * \
#			Autoload.player_reference.stats.stats_current.resource_current / \
#			Autoload.player_reference.stats.stats_current.resource_max
#		$playerframe_resvalue.text = "%.2f%s" % [
#			100. * \
#			Autoload.player_reference.stats.stats_current.resource_current/ \
#			Autoload.player_reference.stats.stats_current.resource_max,"%"]
