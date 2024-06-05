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
func request_map_swap(map_name: String):
	# ask player readiness, to be implemented with UI elements
	# perform map swap if all players are ready
	map_swap(map_name)


func map_swap(map_name: String):
	# disable physics and control for players
	for player in $/root/main/players.get_children():
		print(player)
		if not player.is_in_group("player"):
			continue
		rpc("disable_player",player)
	
	# unload current active map
	if get_node_or_null(^"/root/main/maps/active_map"):
		# remove npcs
		#for npc in $/root/main/maps.get_node("active_map").get_node("npcs")\
			#.get_children():
				#if not npc.is_in_group("npc"):
					#continue
				#npc.queue_free()
		## remove interactables
		#for interactable in $/root/main/maps.get_node("active_map")\
			#.get_node("interactables").get_children():
				#if not interactable.is_in_group("interactable"):
					#continue
				#interactable.queue_free()
		# remove map
		$/root/main/maps.get_node("active_map").queue_free()
	# load, instantiate, add and initialize new map
	References.current_map_path = "res://scenes/maps/%s" % map_name
	var map_instance = load(References.current_map_path).instantiate()
	map_instance.name = "active_map"
	$/root/main/maps.add_child(map_instance,true)
	map_instance.initialize()
	
	# enable physics for players
	for player in $/root/main/players.get_children():
		if not player.is_in_group("player"):
			continue
		rpc("enable_player",player)


@rpc("authority","call_local")
func disable_player(player: CharacterBody3D):
	pass
	#player.set_physics_process(false)
	# process only to be handles locally for the player
	#if not player.get_node("player_input").is_multiplayer_authority():
		#return
	#player.get_node("player_input").set_process(false)
@rpc("authority","call_local")
func enable_player(player: CharacterBody3D):
	pass
	#player.set_physics_process(true)
	# process only to be handles locally for the player
	#if not player.get_node("player_input").is_multiplayer_authority():
		#return
	#player.get_node("player_input").set_process(true)
