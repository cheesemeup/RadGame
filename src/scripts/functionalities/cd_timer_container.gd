extends Node


func relay_cd_timer(spell_id: String, full_duration: float, duration: float):
	rpc_id(get_parent().name.to_int(),"start_cd_timer",spell_id,full_duration,duration)


@rpc("authority","call_local")
func start_cd_timer(spell_id: String, full_duration: float, duration: float):
	print("spell_id: %s"%spell_id)
	print("full_duration: %d"%full_duration)
	print("duration: %d"%duration)
	get_node("cd_timer_spell_%s"%spell_id).trigger_cd(full_duration,duration)
