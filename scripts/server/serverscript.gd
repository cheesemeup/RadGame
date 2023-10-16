extends Node

var PORT = 4545

# run this script if server
func _ready():
	if not OS.has_feature("dedicated_server"):
		return
	print("serverscript started")
	# load hub map scene
	# MOVE THIS TO MAIN
	# such that main script handles actual loading of maps
	Autoload.current_map_path = "res://scenes/maps/hub.tscn"
	var new_map_load = load(Autoload.current_map_path)
	var map_instance = new_map_load.instantiate()
	add_child(map_instance)
	print("hub map loaded")
	# start server
	multiplayer.multiplayer_peer = null
	var peer = ENetMultiplayerPeer.new()
	peer.create_server(PORT)
	multiplayer.multiplayer_peer = peer
	var server_uid = multiplayer.get_unique_id()
	if server_uid != 1:
		print("ERROR: SERVER_UID NOT 1")
	print("multiplayer started")

###############################################################
### MAP SWAPPING
###############################################################
func request_map_change():
	pass
func map_swap(new_map):
	# remove old map
	var map_container = $root/main/maps.get_child(0)
	for c in map_container.get_children():
		map_container.remove_child(c)
		c.queue_free()
	# add new map
	map_container.add_child(new_map.instantiate())
###############################################################
### INTERACTION
###############################################################
func request_interaction(sourcename,targetname):
	# convert names to references
	var source = $root/players.get_child(sourcename)
	var target = $root/maps.get_child(0).get_node("interactable_container").get_node(targetname)
	# check distance
	if source.global_transform.origin.distance_to(target.global_transform.origin) > \
		target.interactable.collision_shape.shape.radius:
		return 4
	# interact
	target.interaction(target)
###############################################################
### COMBAT
###############################################################
func request_combat_event_targeted(source,target,spell):
	# check resource
	if source.stats.stats_current.resource_current < spell.resource_cost:
		return 2
	# check target legality
	if target == null:
		return 3
	var valid_group = false
	for group in spell.targetgroup:
		if target.is_in_group(group):
			valid_group = true
	if not valid_group:
		return 3
	# check range
	if source.global_transform.origin.distance_to(target.global_transform.origin) > \
		spell.range:
		return 4
	# on success, trigger cd on source
	var result = Combat.combat_event_unprescribed(source,target,spell)
	return result

func request_combat_event_aoe():
	# check resource
	
	# create target area
	
	# check target legality
	
	# on success, trigger cd on source
	
	# fire spell on all targets
	pass

func request_combat_tick_event():
	pass
