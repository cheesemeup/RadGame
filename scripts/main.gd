extends Node


var PORT = 4545

func _ready():
	#get_tree().paused = true
	print("start main")
	if OS.has_feature("dedicated_server"):
		multiplayer.peer_connected.connect(spawn_player)
		multiplayer.peer_disconnected.connect(remove_player)
#		multiplayer.connected_to_server.connect(load_map_on_spawn)
		return
	Autoload.main_reference = self
	var mainmenu = preload("res://scenes/ui/mainmenu.tscn")
	mainmenu = mainmenu.instantiate()
	add_child(mainmenu)
#
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
	print("end join")
	get_tree().paused = false
	# rpc_id(1,"spawn_player",peer)
 
func spawn_player(peer_id: int):
	print("spawn_player begin")
#	if not multiplayer.is_server():
#		return
#	print("spawn_player no return")
#	var new_player = preload("res://scenes/testing/test_player.tscn").instantiate()
#	new_player.name = str(peer_id)
#	new_player.player = peer_id
#	$players.add_child(new_player,true)
	print("player spawned")
	# rpc_id(peer_id,"initialize_persistent_ui")

func remove_player(peer_id):
	print("remove_player triggered")
	var player = get_node_or_null("players/"+str(peer_id))
	if multiplayer.is_server() and player:
		player.queue_free()

@rpc("authority")
func initialize_persistent_ui():
	# add persistent ui child node
	var ui_scene = load("res://scenes/ui/ui_main.tscn")
	ui_scene = ui_scene.instantiate()
	add_child(ui_scene)
	Autoload.player_ui_main_reference = ui_scene

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
