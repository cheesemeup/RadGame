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
