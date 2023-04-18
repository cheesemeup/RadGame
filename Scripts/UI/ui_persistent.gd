extends Control

func _ready():
	playerframe_initialize()

func _process(delta):
	$playerframe/playerframe_hpbar.value = 100 * Autoload.player_reference.player_hp_current / Autoload.player_reference.player_hp_max

func partyframe_initialize():
	pass
 
func playerframe_initialize():
	# select orientation based on frame aspect ratio and align/center text
	if $playerframe/playerframe_hpbar.size.x > $playerframe/playerframe_hpbar.size.y:
		$playerframe/playerframe_playername.size.x = $playerframe/playerframe_hpbar.size.x / 2
		$playerframe/playerframe_playername.position.x = $playerframe/playerframe_hpbar.position.x
		$playerframe/playerframe_playername.position.y = $playerframe/playerframe_hpbar.position.y + \
			($playerframe/playerframe_hpbar.size.y - $playerframe/playerframe_playername.size.y) / 2
		$playerframe/playerframe_playername.rotation = 0
		$playerframe/playerframe_playername.text = Autoload.player_reference.playername
		$playerframe/playerframe_hpvalue.size.x = $playerframe/playerframe_hpbar.size.x / 2
		$playerframe/playerframe_hpvalue.position.x = $playerframe/playerframe_hpbar.position.x + \
			$playerframe/playerframe_hpbar.size.x / 2
		$playerframe/playerframe_hpvalue.position.y = $playerframe/playerframe_hpbar.position.y + \
			($playerframe/playerframe_hpbar.size.y - $playerframe/playerframe_playername.size.y) / 2
		$playerframe/playerframe_hpvalue.rotation = 0
		$playerframe/playerframe_hpvalue.text = "%.f / %.f\n %.2f%s" % [Autoload.player_reference.player_hp_current,Autoload.player_reference.player_hp_max,\
			100.*Autoload.player_reference.player_hp_current/Autoload.player_reference.player_hp_max,"%"]
#		str(Autoload.player_reference.player_hp_current) + "/" + \
#			str(Autoload.player_reference.player_hp_max) + "\n" + \
#			str(100*Autoload.player_reference.player_hp_current/Autoload.player_reference.player_hp_max) + "%"
	else:
		$playerframe/playerframe_playername.size.x = $playerframe/playerframe_hpbar.size.y / 2
		$playerframe/playerframe_playername.position.y = $playerframe/playerframe_hpbar.position.y + \
			$playerframe/playerframe_hpbar.size.y
		$playerframe/playerframe_playername.position.x = $playerframe/playerframe_hpbar.position.x + \
			($playerframe/playerframe_hpbar.size.x - $playerframe/playerframe_playername.size.y) / 2
		$playerframe/playerframe_playername.rotation = - PI / 2
		$playerframe/playerframe_playername.text = Autoload.player_reference.playername
		$playerframe/playerframe_hpvalue.size.x = $playerframe/playerframe_hpbar.size.y / 2
		$playerframe/playerframe_hpvalue.position.y = $playerframe/playerframe_hpbar.position.y + \
			$playerframe/playerframe_hpbar.size.y / 2
		$playerframe/playerframe_hpvalue.position.x = $playerframe/playerframe_hpbar.position.x + \
			($playerframe/playerframe_hpbar.size.x - $playerframe/playerframe_playername.size.y) / 2
		$playerframe/playerframe_hpvalue.rotation = - PI / 2
		$playerframe/playerframe_hpvalue.text = "%.f / %.f\n %.2f%s" % [Autoload.player_reference.player_hp_current,Autoload.player_reference.player_hp_max,\
			100.*Autoload.player_reference.player_hp_current/Autoload.player_reference.player_hp_max,"%"]
