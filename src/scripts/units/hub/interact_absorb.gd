extends BaseInteractable


func custom_post_ready():
	$pivot/active_model/sign_text.text = "Absorb"


func custom_trigger(interactor):
	# trigger spell
	$spell_container.get_node("spell_%d"%stats_current["spell"]).trigger(interactor)
