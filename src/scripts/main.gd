extends Node


var PORT = 4545

func _ready():
	print("start main")
	References.main_reference = self
	# dedicated server script, or continue as player with main menu
	if OS.has_feature("dedicated_server"):
		Serverscript.start_serverscript()
		return
	UIHandler.load_main_menu()
	# apply game settings on startup
	SettingsManager.apply_settings(get_tree().root)

func server_join_connect():
	multiplayer.peer_connected.connect(spawn_player)
	multiplayer.peer_disconnected.connect(remove_player)


func start_hosting(port: int = PORT):
	print("starting host on port %d" % port)
	UIHandler.hide_main_menu()
	# start server script
	Serverscript.start_serverscript()
	# create player for host, but as peer so rpc calls work
	UIHandler.hide_main_menu()
	spawn_player(1)


func start_joining(server_address: String, port: int = PORT):
	print("starting join on port %d" % port)
	UIHandler.hide_main_menu()
	multiplayer.multiplayer_peer = null
	var peer = ENetMultiplayerPeer.new()
	peer.create_client(server_address, port)
	multiplayer.multiplayer_peer = peer


func spawn_player(peer_id: int):
	if not multiplayer.is_server():
		return
	var new_player = preload("res://scenes/units/player.tscn").instantiate()
	new_player.pre_ready(peer_id)
	$players.add_child(new_player,true)
	new_player.post_ready(peer_id)


func remove_player(peer_id: int):
	print("remove_player triggered for %d" % peer_id)
	var player = get_node_or_null("players/"+str(peer_id))
	if multiplayer.is_server() and player:
		player.queue_free()


##############################################################################################################################
# exit game (in minecraft)
func exit_game():
	get_tree().quit()
