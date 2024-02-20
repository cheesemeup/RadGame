extends Node


var PORT = 4545
	
func _ready():
	print("start main")
	if OS.has_feature("dedicated_server"):
		multiplayer.peer_connected.connect(spawn_player)
		multiplayer.peer_disconnected.connect(remove_player)
		# spawn test npcs, replace this with actual map init later on
		var test_npc = preload("res://scenes/testing/test_npc_hostile.tscn").instantiate()
		test_npc.set_process(false)
		test_npc.position = Vector3(-6,0,-6)
		$/root/main/npcs.add_child(test_npc,true)
		test_npc = preload("res://scenes/testing/test_npc_friendly.tscn").instantiate()
		test_npc.set_process(false)
		test_npc.position = Vector3(-3,0,-6)
		$/root/main/npcs.add_child(test_npc,true)
		return
	Autoload.main_reference = self
	# load main menu for players
	UIHandler.load_mainmenu()

#func start_server():
#	# start server
#	multiplayer.multiplayer_peer = null
#	var peer = ENetMultiplayerPeer.new()
#	peer.create_server(PORT)
#	multiplayer.multiplayer_peer = peer
#	var server_uid = multiplayer.get_unique_id()
#	if server_uid != 1:
#		print("ERROR: SERVER_UID NOT 1")
	# load hub map scene

#func start_hosting():
#	# delete any multiplayer peer that might exist:
#	multiplayer.multiplayer_peer = null
#	# create new peer and set its host, then tell our multiplayer API to use it:
#	var peer = ENetMultiplayerPeer.new()
#	peer.create_server(PORT)
#	multiplayer.multiplayer_peer = peer
#	# get our multiplayer UID (as server this should always be "1" in Godot 4)
#	var player_uid = multiplayer.get_unique_id()
#	spawn_player(player_uid)
#	current_map_reply("hub.tscn")
#	initialize_persistent_ui()

func start_joining(server):
	print("starting join on port %d" % PORT)
	multiplayer.multiplayer_peer = null
	var peer = ENetMultiplayerPeer.new()
	peer.create_client(server, PORT)
	multiplayer.multiplayer_peer = peer
 
func spawn_player(peer_id: int):
	if not multiplayer.is_server():
		return
	var new_player = preload("res://scenes/units/player.tscn").instantiate()
	new_player.pre_ready(peer_id)
	#new_player.get_node("player_input").set_process(false)
	$players.add_child(new_player,true)
	new_player.post_ready(peer_id)

func remove_player(peer_id: int):
	print("remove_player triggered for %s" % peer_id)
	var player = get_node_or_null("players/"+str(peer_id))
	if multiplayer.is_server() and player:
		player.queue_free()

##############################################################################################################################
# Map loading and unloading
# when spawning, join map that host is on
#func load_map_on_spawn():
#	rpc_id(1,"current_map_query",multiplayer.get_unique_id())
#@rpc("any_peer")
#func current_map_query(peer_id):
#	rpc_id(peer_id,"current_map_reply",Autoload.current_map_path)
#@rpc("authority")
#func current_map_reply(reply):
#	var new_map_load = load("res://scenes/maps/"+reply)
#	var map_instance = new_map_load.instantiate()
#	Autoload.current_map_reference = map_instance
#	add_child(map_instance)
#	Autoload.current_map_path = reply

#func swap_map_init(new_map):
#	# if only one player, load map
#	if get_tree().get_nodes_in_group("playergroup").size() == 1:
#		swap_map(new_map)
#	# show popup to all players to accept map change
#	# change map if all players agree
#	swap_map(new_map)
#
#
#@rpc("call_local")
#func swap_map(new_map):
#	if Autoload.current_map_reference != null:
#		Autoload.current_map_reference.queue_free()
#	var new_map_load = load(new_map)
#	var map_instance = new_map_load.instantiate()
#	Autoload.current_map_reference = map_instance
#	add_child(map_instance)
#	# get spawn location on loaded map
#	var spawnlocation = Autoload.current_map_reference.get_node("spawnlocation").position
#	Autoload.player_reference.set_position(spawnlocation)
	

##############################################################################################################################
# exit game (in minecraft)
func exit_game():
	get_tree().quit()
