extends Node

# run this script if server
func _ready():
	if not "--server" in OS.get_cmdline_args():
		return
	print("start server _ready")
	# initializations
	Autoload.current_map_path = "res://scenes/maps/hub.tscn"
	# run main function
	server_main()

func server_main():
	print("start server main script")


###############################################################
### MAP SWAPPING
###############################################################
@rpc("any_peer")
func _query_map():
	# reply with the currently active map
	return Autoload.current_map_path
func map_swap():
	# swap map according to player input
	pass

###############################################################
### INTERACTION
###############################################################
@rpc("any_peer","call_remote")
func request_interaction(sourcename,targetname):
	# convert names to references
	var source = $root/players.get_child(sourcename)
	var target = $root/interactables.get_child(targetname)
	# check distance (as previous "check" comes from client, not server)
	if source.global_transform.origin.distance_to(target.global_transform.origin) > \
		target.interactable.collision_shape.shape.radius:
		return
	# interact
	target.interaction(source)

###############################################################
### COMBAT
###############################################################
@rpc("any_peer")
func request_combat_event_targeted(source,target,spell):
	# check resource
	if source.stats.stats_current.resource_current < spell.resource_cost:
		return "insufficient resources"
	# check target legality
	var valid_group = false
	for group in spell.targetgroup:
		if target.is_in_group(group):
			valid_group = true
	if not valid_group:
		return "invalid target"
	# check range
	if source.global_transform.origin.distance_to(target.global_transform.origin) > \
		spell.range:
		return
	# on success, trigger cd on source
	
	# fire spell
	pass

func request_combat_event_aoe():
	# check resource
	
	# create target area
	
	# check target legality
	
	# on success, trigger cd on source
	
	# fire spell on all targets
	pass

func request_combat_tick_event():
	pass
