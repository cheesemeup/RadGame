extends Node

class_name BaseInteractable

var stats_current

@export var model: String

################################################################################
### spawning
func pre_ready(unit_id: int) -> void:
	$mpsynchronizer.set_multiplayer_authority(1)
	# initialize stats
	initialize_base_interactable(str(unit_id))
	name = stats_current["unit_name"]
	$interact_prompt.position.y = stats_current["prompt_offset"]
	custom_pre_ready()


func _ready():
	# for all peers
	if not $mpsynchronizer.is_multiplayer_authority():
		# create interact prompt text locally for all peers
		$pivot/signpost.interact_prompt.text = create_prompt_text()
		return
	
	# server only
	if $mpsynchronizer.is_multiplayer_authority():
		set_model(model)


func post_ready():
	custom_post_ready()


func initialize_base_interactable(unit_id: String):
	# read stats dict from file
	var file = "res://data/db_stats_interactable.json"
	var json_dict = JSON.parse_string(FileAccess.get_file_as_string(file))
	stats_current = json_dict[unit_id]
	model = stats_current["model"]
	# spell container
	var spell_container = preload("res://scenes/functionalities/spell_container.tscn").instantiate()
	add_child(spell_container)
	if stats_current.has("spell"):
		# add spells to container
		var spell_scene = load("res://scenes/spells/spell_%d.tscn" % stats_current["spell"])
		spell_scene = spell_scene.instantiate()
		$spell_container.add_child(spell_scene)
	# connect enter and exit signals
	connect_signals()
	# set interact radius
	$"range/range_shape".shape.radius = stats_current["interact_range"]


func connect_signals():
	$range.connect("body_entered",add_interactable)
	$range.connect("body_exited",remove_interactable)


func custom_pre_ready():
	# override this function to enable custom pre_ready functionality
	pass


func custom_post_ready():
	# override this function to enable custom post_ready functionality
	pass


################################################################################
# MODELS
func set_model(model_name: String) -> void:
	# unload previous model if it exists
	if $pivot.get_node_or_null("active_model"):
		$pivot/active_model.free()
	# load new model
	var model_scene = load("res://scenes/models/%s.tscn"%model_name).instantiate()
	model_scene.name = "active_model"
	$pivot.add_child(model_scene, true)


################################################################################
### player interactions
func manual_body_exited(player: CharacterBody3D):
	$range.body_exited.emit(player)


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


func create_prompt_text() -> String:
	# Create the text for the interaction prompt, trimming (Physical)
	var hotkey = InputMap.action_get_events("interact")[0].as_text()
	return "Interact [%s]"%hotkey.trim_suffix(" (Physical)")


func trigger(interactor):
	# write interaction to log
	Combat.log_interact(interactor.stats_current["unit_name"],self.stats_current["unit_name"])
	custom_trigger(interactor)


func custom_trigger(interactor):
	# override this function in the interactable script for any functionality past log entry
	pass
