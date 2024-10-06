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
