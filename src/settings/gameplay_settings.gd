class_name GameplaySettings extends Resource

@export var show_player_health: bool:
	set(new_value):
		if show_player_health != new_value:
			show_player_health = new_value
			emit_changed()

func apply() -> void:
	pass
	
func _to_string() -> String:
	return (
		"Video Settings:" +
		"\n\tShow player health: " + str(show_player_health)
	)
