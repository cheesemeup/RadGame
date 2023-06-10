extends Node3D

func interaction(body):
	print("interacted with interact_heal sign")
	Combat.combat_event("sign_heal",self,body)
	body.unit_hp_current = min(body.unit_hp_current+100,body.unit_hp_max)
