extends Control

func _process(delta):
	$playerframe/playerframe_hpbar.value = 100 * Autoload.player_reference.player_hp_current / Autoload.player_reference.player_hp_max
