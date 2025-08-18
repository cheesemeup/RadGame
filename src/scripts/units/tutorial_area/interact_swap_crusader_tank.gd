extends BaseInteractable


func custom_post_ready():
	$pivot/active_model/sign_text.text = "Tutorialmap"


func custom_trigger(interactor):
	# trigger class swap
	interactor.class_swap("4")
