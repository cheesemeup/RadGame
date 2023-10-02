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
### COMBAT
###############################################################
@rpc("any_peer")
func request_combat_event_targeted():
	# get spell info
	
	# check resource
	
	# check target legality
	
	# check range
	
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
