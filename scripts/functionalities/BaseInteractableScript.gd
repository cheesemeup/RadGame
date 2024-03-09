extends Node

class_name BaseInteractable

func initialize_base_interactable(UnitID: String):
	pass

func add_interactable(target: CharacterBody3D):
	# append interactable to player's interactable list
	if not target.is_in_group("player"):
		return
	target.interactables.append(self)

func remove_interactable(target: CharacterBody3D):
	# delete interactable from player's interactable list
	if not target.is_in_group("player"):
		return
	target.interactables.erase(self)
	pass

func trigger(_interactor):
	# Log interaction in combat script
	# If no override is present in specific interactable, print message
	print("Trigger has not been overriden!")
