extends Node

# run this script if server
func _ready():
	if not "--server" in OS.get_cmdline_args():
		return
	# initializations
	Autoload.current_map_path = "res://scenes/maps/hub.tscn"
	# run main function
	server_main()

func server_main():
	pass
