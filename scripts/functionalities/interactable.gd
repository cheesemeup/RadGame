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
	
func hide_interact_popup():
	$"../interact_prompt".visible = false

func interaction_start(bodyname):
	# request interaction on server
	rpc_id(1,"request_interaction",bodyname)

@rpc("any_peer","call_remote")
func request_interaction(bodyname):
	if not multiplayer.is_server():
		return
	Serverscript.request_interaction(bodyname,self.get_parent().name)
