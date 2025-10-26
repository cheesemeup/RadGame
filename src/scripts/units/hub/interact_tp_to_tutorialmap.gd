extends BaseInteractable


func custom_post_ready():
	$pivot/active_model/sign_text.text = "Tutorialmap"


func custom_trigger(_interactor):
	# trigger map swap
	Serverscript.request_map_swap("tutorial_area.tscn")
