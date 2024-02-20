extends Node

var PORT = 4545

# run this script if server
func _ready():
	if not OS.has_feature("dedicated_server"):
		return
	print("serverscript started")
	# start server
	multiplayer.multiplayer_peer = null
	var peer = ENetMultiplayerPeer.new()
	peer.create_server(PORT)
	multiplayer.multiplayer_peer = peer
	var server_uid = multiplayer.get_unique_id()
	if server_uid != 1:
		print("ERROR: SERVER_UID NOT 1")
	print("server started on port %d" % PORT)
	# such that main script handles actual loading of maps
	# load hub map scene
	#Autoload.current_map_path = "res://scenes/maps/hub.tscn"
	#var hub_map_instance = preload("res://scenes/maps/hub.tscn").instantiate
	#$/root/main/maps.add_child(hub_map_instance)
	print("hub map loaded")

###############################################################
### MAP SWAPPING
###############################################################
#func request_map_change():
#	pass
#func map_swap(new_map):
#	# remove old map
#	var map_container = $root/main/maps.get_child(0)
#	for c in map_container.get_children():
#		map_container.remove_child(c)
#		c.queue_free()
#	# add new map
#	map_container.add_child(new_map.instantiate())
###############################################################
### INTERACTION
################################################################
#func request_interaction(sourcename,targetname):
#	# convert names to references
#	var source = $root/players.get_child(sourcename)
#	var target = $root/maps.get_child(0).get_node("interactable_container").get_node(targetname)
#	# check distance
#	if source.global_transform.origin.distance_to(target.global_transform.origin) > \
#		target.interactable.collision_shape.shape.radius:
#		return 4
#	# interact
#	target.interaction(target)
