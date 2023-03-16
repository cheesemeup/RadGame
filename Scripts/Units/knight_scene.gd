extends Node3D

@onready var synchronizer = $MultiplayerSynchronizer

func _enter_tree() -> void:
	print(get_parent().get_parent().name.to_int())
	$MultiplayerSynchronizer.set_multiplayer_authority(get_parent().get_parent().name.to_int())
	

func _ready():
	if synchronizer.is_multiplayer_authority():
		Autoload.playermodel_reference = self
	
