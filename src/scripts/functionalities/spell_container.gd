extends Node

var player = get_parent()
var gcd_timer: float = 1.5
var result: int
var queue: String = ""
var queue_instant: Array = []
signal signal_gcd(duration)

################################################################################
# ENTRYPOINT FROM ACTIONBAR
func spell_entrypoint(spell_id: String) -> int:
	# determine whether spell is present in container
	var node_name = "spell_"+spell_id
	var spell_node = get_node_or_null(node_name)
	if spell_node == null:
		print("spell %s not known"%spell_id)
		return 1  # spell not known
	result = spell_node.trigger()
	return result

# apply role swap changes

# apply talent changes

# send gcd
func send_gcd() -> void:
	# emit signal, true to denote gcd
	signal_gcd.emit(gcd_timer,true)


func set_queue(ID: String) -> void:
	if get_node("spell_%s"%ID).cd_timer.is_connected("timeout",cast_queued):
		get_node("spell_%s"%ID).cd_timer.disconnect("timeout",cast_queued)
	queue = ID
	get_node("spell_%s"%ID).cd_timer.connect("timeout",cast_queued)


func cast_queued() -> void:
	# trigger queued spell if it exists, prioritizing instant casts
	if not queue_instant == []:
		var new_id = queue_instant.pop_front()
		spell_entrypoint(new_id)
		return
	if not queue == "":
		if get_node("spell_%s"%queue).cd_timer.is_connected("timeout",cast_queued):
			get_node("spell_%s"%queue).cd_timer.disconnect("timeout",cast_queued)
		var new_id = queue
		queue = ""
		spell_entrypoint(new_id)
