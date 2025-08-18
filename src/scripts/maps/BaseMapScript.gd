extends Node

class_name BaseMap

var current_spawn_position: Vector3
var current_spawn_rotation: Vector3
var initial_spawn_position: Vector3
var initial_spawn_rotation: Vector3
var interactable_despawn_position: Vector3

func _initialize():
	# print warning if initialization has not been overridden
	print("WARNING: MAP INITIALIZATION HAS NOT BEEN OVERRIDDEN!")


func spawn_interactable(unit_id: int, script_path: String, position: Vector3, rotation: Vector3):
	var interactable = load("res://scenes/units/base_interactable.tscn").instantiate()
	var interactable_script = load("res://scripts/units/%s.gd"%script_path)
	interactable.set_script(interactable_script)
	interactable.position = position
	interactable.rotation = rotation
	interactable.pre_ready(unit_id)
	$interactables.add_child(interactable, true)
	interactable.post_ready()
