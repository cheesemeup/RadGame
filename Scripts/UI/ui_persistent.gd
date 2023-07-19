extends Control

func _ready():
#	playerframe_initialize()
#	actionbars_initialize()
	pass

func _process(_delta):
	# update player frame
	if $playerframe/playerframe_hpbar.visible:
		$playerframe/playerframe_hpbar.value = 100 * Autoload.player_reference.stats_curr["health_current"] / Autoload.player_reference.stats_curr["health_max"]
		$playerframe/playerframe_hpvalue.text = "%.f / %.f\n %.2f%s" % [Autoload.player_reference.stats_curr["health_current"],\
			Autoload.player_reference.stats_curr["health_max"],100.*Autoload.player_reference.stats_curr["health_current"]/\
			Autoload.player_reference.stats_curr["health_max"],"%"]
	if $playerframe/playerframe_resbar.visible:
		$playerframe/playerframe_resbar.value = 100 * Autoload.player_reference.stats_curr["resource_current"] /\
			 Autoload.player_reference.stats_curr["resource_max"]
		$playerframe/playerframe_resvalue.text = "%.2f%s" % [100.*Autoload.player_reference.stats_curr["resource_current"]/\
			Autoload.player_reference.stats_curr["resource_max"],"%"]

func partyframe_initialize():
	pass
 
func playerframe_initialize():
	# select orientation based on frame aspect ratio and align/center text
	# player hp bar
	$playerframe/playerframe_playername.text = Autoload.player_reference.stats_curr["name"]
	$playerframe/playerframe_hpvalue.text = "%.f / %.f\n %.2f%s" % [Autoload.player_reference.stats_curr["health_current"],\
		Autoload.player_reference.stats_curr["health_max"],\
		100.*Autoload.player_reference.stats_curr["health_current"]/Autoload.player_reference.stats_curr["health_max"],"%"]
	if $playerframe/playerframe_hpbar.size.x > $playerframe/playerframe_hpbar.size.y:
		$playerframe/playerframe_playername.size.x = $playerframe/playerframe_hpbar.size.x / 2
		$playerframe/playerframe_playername.position.x = $playerframe/playerframe_hpbar.position.x
		$playerframe/playerframe_playername.position.y = $playerframe/playerframe_hpbar.position.y + \
			($playerframe/playerframe_hpbar.size.y - $playerframe/playerframe_playername.size.y) / 2
		$playerframe/playerframe_playername.rotation = 0
		$playerframe/playerframe_hpvalue.size.x = $playerframe/playerframe_hpbar.size.x / 2
		$playerframe/playerframe_hpvalue.position.x = $playerframe/playerframe_hpbar.position.x + \
			$playerframe/playerframe_hpbar.size.x / 2
		$playerframe/playerframe_hpvalue.position.y = $playerframe/playerframe_hpbar.position.y + \
			($playerframe/playerframe_hpbar.size.y - $playerframe/playerframe_playername.size.y) / 2
		$playerframe/playerframe_hpvalue.rotation = 0
	else:
		$playerframe/playerframe_playername.size.x = $playerframe/playerframe_hpbar.size.y / 2
		$playerframe/playerframe_playername.position.y = $playerframe/playerframe_hpbar.position.y + \
			$playerframe/playerframe_hpbar.size.y
		$playerframe/playerframe_playername.position.x = $playerframe/playerframe_hpbar.position.x + \
			($playerframe/playerframe_hpbar.size.x - $playerframe/playerframe_playername.size.y) / 2
		$playerframe/playerframe_playername.rotation = - PI / 2
		$playerframe/playerframe_hpvalue.size.x = $playerframe/playerframe_hpbar.size.y / 2
		$playerframe/playerframe_hpvalue.position.y = $playerframe/playerframe_hpbar.position.y + \
			$playerframe/playerframe_hpbar.size.y / 2
		$playerframe/playerframe_hpvalue.position.x = $playerframe/playerframe_hpbar.position.x + \
			($playerframe/playerframe_hpbar.size.x - $playerframe/playerframe_playername.size.y) / 2
		$playerframe/playerframe_hpvalue.rotation = - PI / 2
	# player resource bar
	$playerframe/playerframe_resvalue.text = "%.2f%s" % [100.*Autoload.player_reference.stats_curr["resource_current"]/\
		Autoload.player_reference.stats_curr["resource_max"],"%"]
	if $playerframe/playerframe_resbar.size.x > $playerframe/playerframe_resbar.size.y:
		$playerframe/playerframe_resvalue.position.x = $playerframe/playerframe_resbar.position.x + $playerframe/playerframe_resbar.size.x - \
			$playerframe/playerframe_resvalue.size.x
		$playerframe/playerframe_resvalue.position.y = $playerframe/playerframe_resbar.position.y - \
			($playerframe/playerframe_resbar.size.y - $playerframe/playerframe_resvalue.size.y) / 2
		$playerframe/playerframe_resvalue.rotation = 0
	else:
		$playerframe/playerframe_resvalue.position.y = $playerframe/playerframe_resbar.position.y + $playerframe/playerframe_resvalue.size.x
		$playerframe/playerframe_resvalue.position.x = $playerframe/playerframe_resbar.position.x + \
			($playerframe/playerframe_resbar.size.x - $playerframe/playerframe_resvalue.size.y) / 2
		$playerframe/playerframe_resvalue.rotation = - PI / 2

func actionbars_initialize():
#	$actionbars.actionbars/actionbar1/actionbar1_1.shortcut = input_event()
	pass

# mouseover targeting of frame
func _on_playerframe_hpbar_mouse_entered():
	Autoload.player_reference.unit_mouseover_target = Autoload.player_reference
func _on_playerframe_hpbar_mouse_exited():
	Autoload.player_reference.unit_mouseover_target = null
func _on_playerframe_resbar_mouse_entered():
	Autoload.player_reference.unit_mouseover_target = Autoload.player_reference
func _on_playerframe_resbar_mouse_exited():
	Autoload.player_reference.unit_mouseover_target = null
