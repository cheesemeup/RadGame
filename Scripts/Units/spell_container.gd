extends Node

var gcd_timer = 1.5
signal signal_gcd(duration)

# apply role swap changes

# apply talent changes

# send gcd
func send_gcd():
	# emit signal
	signal_gcd.emit(gcd_timer)
