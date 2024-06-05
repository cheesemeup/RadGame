extends Node

var SERVER_PORT_ENV = OS.get_environment("SERVER_PORT")
var PORT = SERVER_PORT_ENV.to_int() if SERVER_PORT_ENV.is_valid_int() and not SERVER_PORT_ENV.is_empty() else 4545


# run this script if server
func start_serverscript():
	print("serverscript started")
	
	# start server
	multiplayer.multiplayer_peer = null
	var peer = ENetMultiplayerPeer.new()
	peer.create_server(PORT)
	multiplayer.multiplayer_peer = peer
	var server_uid: int = multiplayer.get_unique_id()
	if server_uid != 1:
		print("ERROR: SERVER_UID NOT 1")
	print("server started on port %d" % PORT)
	
	# load hub map scene
	map_swap("hub.tscn")
	print("hub map ready")
	
	# connect join and leave signals
	References.main_reference.server_join_connect()

###############################################################
### MAP SWAPPING
###############################################################
func map_swap(map_name: String):
	# disable physics and control for players
	for player in $/root/players.get_children():
		if not player.is_in_group("player"):
			continue
		rpc("disable_player",player)
	
	# unload current active map
	if get_node_or_null(^"/root/main/maps/active_map"):
		$/root/main/maps.get_node("active_map").queue_free()
	# load, instantiate, add and initialize new map
	References.current_map_path = "res://scenes/maps/%s" % map_name
	var map_instance = load(References.current_map_path).instantiate()
	$/root/main/maps.add_child(map_instance)
	map_instance.initialize()
	
	# enable physics for players
	for player in $/root/players.get_children():
		if not player.is_in_group("player"):
			continue
		rpc("enable_player",player)


@rpc("authority","call_local")
func disable_player(player: CharacterBody3D):
	player.set_physics_process(false)
	# process only to be handles locally for the player
	if not player.get_node("player_input").is_multiplayer_authority():
		return
	player.get_node("player_input").set_process(false)
@rpc("authority","call_local")
func enable_player(player: CharacterBody3D):
	player.set_physics_process(true)
	# process only to be handles locally for the player
	if not player.get_node("player_input").is_multiplayer_authority():
		return
	player.get_node("player_input").set_process(true)
