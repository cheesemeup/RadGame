extends Control

# target frame vars
var targetframe_hp_size_x = 250
var targetframe_hp_size_y = 80
var targetframe_hp_position_x = 0
var targetframe_hp_position_y = 0
var targetframe_updateflag = false

var esc_menu_preload = preload("res://Scenes/UI/escape_menu.tscn")
var targetframe_preload = preload("res://Scenes/UI/targetframe.tscn")

##############################################################################################################################

func _ready():
	Autoload.player_ui_main_reference = self

func _process(_delta):
	if targetframe_updateflag:
		targetframe_update()

func esc_menu():
	if get_node_or_null("escape_menu_root"):
		$escape_menu_root.queue_free()
	elif get_node_or_null("exit_game_countdown"):
		$exit_game_countdown._on_cancel_pressed()
	elif get_node_or_null("progress_menu"):
		$progress_menu.queue_free()
	elif get_node_or_null("interface_menu"):
		$interface_menu.queue_free()
	else:
		var escape_menu = esc_menu_preload.instantiate()
		Autoload.esc_menu_reference = escape_menu
		add_child(escape_menu)

func load_persistent():
	var ui_persistent_load = load("res://Scenes/UI/ui_persistent.tscn")
	var ui_persistent = ui_persistent_load.instantiate()
	$/root/main/ui.add_child(ui_persistent)

func targetframe_initialize():
	# create new targetframe if there is no targetframe
	if not get_node_or_null("targetframe"):
		var targetframe = targetframe_preload
		targetframe = targetframe.instantiate()
		add_child(targetframe)
		targetframe_updateflag = true
	# apply targetframe settings
	targetframe_setup()

func targetframe_remove():
	if not get_node_or_null("targetframe"):
		return
	targetframe_updateflag = false
	get_node("targetframe").queue_free()

func targetframe_setup():
	# select orientation based on frame aspect ratio and align/center text
	# player hp bar
	$targetframe/targetframe_targetname.text = Autoload.player_reference.unit_target.stats_curr["name"]
	$targetframe/targetframe_hpvalue.text = "%.f / %.f\n %.2f%s" % [Autoload.player_reference.unit_target.stats_curr["health_current"],\
		Autoload.player_reference.unit_target.stats_curr["health_max"],100.*Autoload.player_reference.unit_target.stats_curr["health_current"]/\
		Autoload.player_reference.unit_target.stats_curr["health_max"],"%"]
	if $targetframe/targetframe_hpbar.size.x > $targetframe/targetframe_hpbar.size.y:
		$targetframe/targetframe_targetname.size.x = $targetframe/targetframe_hpbar.size.x / 2
		$targetframe/targetframe_targetname.position.x = $targetframe/targetframe_hpbar.position.x
		$targetframe/targetframe_targetname.position.y = $targetframe/targetframe_hpbar.position.y + \
			($targetframe/targetframe_hpbar.size.y - $targetframe/targetframe_targetname.size.y) / 2
		$targetframe/targetframe_targetname.rotation = 0
		$targetframe/targetframe_hpvalue.size.x = $targetframe/targetframe_hpbar.size.x / 2
		$targetframe/targetframe_hpvalue.position.x = $targetframe/targetframe_hpbar.position.x + \
			$targetframe/targetframe_hpbar.size.x / 2
		$targetframe/targetframe_hpvalue.position.y = $targetframe/targetframe_hpbar.position.y + \
			($targetframe/targetframe_hpbar.size.y - $targetframe/targetframe_targetname.size.y) / 2
		$targetframe/targetframe_hpvalue.rotation = 0
	else:
		$targetframe/targetframe_targetname.size.x = $targetframe/targetframe_hpbar.size.y / 2
		$targetframe/targetframe_targetname.position.y = $targetframe/targetframe_hpbar.position.y + \
			$targetframe/targetframe_hpbar.size.y
		$targetframe/targetframe_targetname.position.x = $targetframe/targetframe_hpbar.position.x + \
			($targetframe/targetframe_hpbar.size.x - $targetframe/targetframe_targetname.size.y) / 2
		$targetframe/targetframe_targetname.rotation = - PI / 2
		$targetframe/targetframe_hpvalue.size.x = $targetframe/targetframe_hpbar.size.y / 2
		$targetframe/targetframe_hpvalue.position.y = $targetframe/targetframe_hpbar.position.y + \
			$targetframe/targetframe_hpbar.size.y / 2
		$targetframe/targetframe_hpvalue.position.x = $targetframe/targetframe_hpbar.position.x + \
			($targetframe/targetframe_hpbar.size.x - $targetframe/targetframe_targetname.size.y) / 2
		$targetframe/targetframe_hpvalue.rotation = - PI / 2
#	# player resource bar
	$targetframe/targetframe_resvalue.text = "%.2f%s" % [100.*Autoload.player_reference.unit_target.stats_curr["resource_current"]/\
		Autoload.player_reference.unit_target.stats_curr["resource_max"],"%"]
	if $targetframe/targetframe_resbar.size.x > $targetframe/targetframe_resbar.size.y:
		$targetframe/targetframe_resvalue.position.x = $targetframe/targetframe_resbar.position.x + $targetframe/targetframe_resbar.size.x - \
			$targetframe/targetframe_resvalue.size.x
		$targetframe/targetframe_resvalue.position.y = $targetframe/targetframe_resbar.position.y - \
			($targetframe/targetframe_resbar.size.y - $targetframe/targetframe_resvalue.size.y) / 2
		$targetframe/targetframe_resvalue.rotation = 0
	else:
		$targetframe/targetframe_resvalue.position.y = $targetframe/targetframe_resbar.position.y + $playerframe/playerframe_resvalue.size.x
		$targetframe/targetframe_resvalue.position.x = $targetframe/targetframe_resbar.position.x + \
			($targetframe/rargetframe_resbar.size.x - $targetframe/targetframe_resvalue.size.y) / 2
		$targetframe/targetframe_resvalue.rotation = - PI / 2

func targetframe_update():
	$targetframe/targetframe_hpbar.value = 100.*Autoload.player_reference.unit_target.stats_curr["health_current"]/Autoload.player_reference.unit_target.stats_curr["health_max"]
	$targetframe/targetframe_hpvalue.text = "%.f / %.f\n %.2f%s" % [Autoload.player_reference.unit_target.stats_curr["health_current"],\
		Autoload.player_reference.unit_target.stats_curr["health_max"],100.*Autoload.player_reference.unit_target.stats_curr["health_current"]/\
		Autoload.player_reference.unit_target.stats_curr["health_max"],"%"]
	$targetframe/targetframe_resbar.value = 100.*Autoload.player_reference.unit_target.stats_curr["resource_current"]/\
		Autoload.player_reference.unit_target.stats_curr["resource_max"]
	$targetframe/targetframe_resvalue.text = "%.2f%s" % [100.*Autoload.player_reference.unit_target.stats_curr["resource_current"]/\
		Autoload.player_reference.unit_target.stats_curr["resource_max"],"%"]
