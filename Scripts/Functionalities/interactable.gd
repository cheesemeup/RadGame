extends Area3D

func _on_body_entered(body):
	if not body.is_in_group("playergroup"):
		return
	print("body entered",body)
	body.interactables_in_range.append(self)
	print("in range: ",body.interactables_in_range)


func _on_body_exited(body):
	if not body.is_in_group("playergroup"):
		return
	print("body exited",body)
	body.interactables_in_range.erase(self)
	if body.interactables_in_range.size() == 0:
		body.current_interact_target = null
	print("in range: ",body.interactables_in_range)

func show_interact_popup():
	$"../interact_prompt".visible = true
	return
	
func hide_interact_popup():
	$"../interact_prompt".visible = false
	return

func interaction(body):
	print("starting interaction")
	$"../".interaction(body)
