extends BaseUnit

# tutorial boss for dps players
# needs a dmg amp phase, a large aoe hit to necessitate defensives,
# a ground aoe to dodge, add spawns for aoe

const JUMP_VELOCITY = 4.5

# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")


func _physics_process(delta):
	# Add the gravity.
	if not is_on_floor():
		velocity.y -= gravity * delta
	move_and_slide()


###############################################################################
# SPAWNING
func initialize():
	initialize_base_unit("npc","2")
