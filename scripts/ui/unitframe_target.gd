extends Control

var target_reference

func _process(delta):
	# update health bar
	$hpbar_value.value = 25
	# update mana bar
	$resourcebar_value.value = 35
