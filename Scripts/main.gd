extends Node


var PORT = 4242

func _ready():
	Autoload.main_reference = self
	multiplayer.peer_connected.connect(spawn_player)
	multiplayer.peer_disconnected.connect(remove_player)
	var mainmenu = preload("res://Scenes/UI/mainmenu.tscn")
	mainmenu = mainmenu.instantiate()
	add_child(mainmenu)
#	spawner.spawn_function = func spawn_player_custom(id: int):
#		var player_body = preload("res://scenes/units/Player.tscn").instantiate()
#		player_body.name = str(id)
#		return player_body
#
#
func start_hosting():
	# delete any multiplayer peer that might exist:
	multiplayer.multiplayer_peer = null
	# create new peer and set its host, then tell our multiplayer API to use it:
	var peer = ENetMultiplayerPeer.new()
	peer.create_server(PORT)
	multiplayer.multiplayer_peer = peer
	# get our multiplayer UID (as server this should always be "1" in Godot 4)
	var player_uid = multiplayer.get_unique_id()
	spawn_player(player_uid)
	

func start_joining(server):
	multiplayer.multiplayer_peer = null
	var peer = ENetMultiplayerPeer.new()
	peer.create_client(server, PORT)
	multiplayer.multiplayer_peer = peer
	

func spawn_player(peer_id: int):
	if not multiplayer.is_server():
		return
	var new_player = preload("res://Scenes/Units/player.tscn").instantiate()
	new_player.name = str(peer_id)
	print(new_player)
	$players.add_child(new_player)
	

func remove_player(peer_id):
	var player = get_node_or_null(str(peer_id))
	if player:
		player.queue_free()
	
