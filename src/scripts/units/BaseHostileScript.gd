extends BaseUnit

class_name BaseHostile

################################################################################
### spawning
func pre_ready(unit_id: int) -> void:
	$mpsynchronizer.set_multiplayer_authority(1)
	# initialize stats
	initialize_base_unit("npc", str(unit_id))
	custom_pre_ready()


func _ready():
	# server only
	if $mpsynchronizer.is_multiplayer_authority():
		set_model(model)


func post_ready():
	custom_post_ready()


func custom_pre_ready():
	# override this function to enable custom pre_ready functionality
	pass


func custom_post_ready():
	# override this function to enable custom post_ready functionality
	pass


################################################################################
### frame
#func _process(delta):
	#if is_in_combat:
		#process_combat()


func _physics_process(delta) -> void:
	# movement
	if not is_dead:
		move_to_aggro(delta)


#func process_combat():
	## override this function in the individual NPC scripts
	#pass


################################################################################
### aggro table
var aggro_table: Dictionary = {}
func update_aggro(source: CharacterBody3D, value: int):
	if aggro_table == {} and not is_in_combat:
		is_in_combat = true
	# Update the aggro table when unit is hit, or healing is being done
	if source in aggro_table.keys():
		aggro_table[source] = aggro_table[source] + value
	else:
		# create new key if not already in table
		aggro_table[source] = value


func get_current_aggro() -> CharacterBody3D:
	var current_aggro = null
	var current_threat = 0
	if aggro_table == {}:
		return current_aggro
	for key in aggro_table.keys():
		if aggro_table[key] > current_threat:
			current_threat = aggro_table[key]
			current_aggro = key
	return current_aggro


################################################################################
### encounter
func start_encounter():
	# close off combat area
	# set initial health and resource values for players
	# reset cooldowns on players
	# log combat start
	custom_start_encounter()


func custom_start_encounter():
	# override this function in a specific hostile unit script for additional custom actions
	pass


func reset():
	# called from the map script, when an NPC has to be reset (e.g., because of a wipe)
	# disable combat processing
	is_in_combat = false
	# reset hp and resource
	stats_current["health_max"] = stats_base["health_max"]
	stats_current["health_current"] = stats_base["health_current"]
	stats_current["resource_max"] = stats_base["resource_max"]
	stats_current["resource_current"] = stats_base["resource_current"]
	# reset all timers
	# resets the NPC to initial state
	aggro_table = {}
	# move to spawn position and rotation
	set_position_and_rotation(spawn_position, spawn_rotation)
	play_animation("Idle")
	custom_reset()


func custom_reset():
	# override this function in a specific hostile unit script for additional custom actions
	pass

################################################################################
### movement
func move_to_aggro(delta):
	if aggro_table == {}:
		return
	
	var current_aggro = get_current_aggro()
	
	# check if within melee range, and only change orientation if so
	if position.distance_to(current_aggro.position) <= \
	(stats_current["melee_hitbox_size"] + current_aggro.stats_current["melee_hitbox_size"]):
		$pivot.look_at(global_position + position.direction_to(current_aggro.position))
		if is_moving:
			is_moving = false
		return
	
	# move towards the target that currently holds aggro if not within melee range
	var direction = Vector3(
		current_aggro.position.x - self.position.x,
		0,
		current_aggro.position.z - self.position.z
	).normalized()
	if direction:
		velocity.x = direction.x * speed
		velocity.z = direction.z * speed
		$pivot.look_at(global_position + direction)
	else:
		velocity.x = move_toward(velocity.x, 0, speed)
		velocity.z = move_toward(velocity.z, 0, speed)
	move_and_slide()
	# set movement state on server
	if not $mpsynchronizer.is_multiplayer_authority():
		return
	if velocity == Vector3(0,0,0):
		if is_moving:
			is_moving = false
	else:
		if not is_moving:
			is_moving = true


################################################################################
# STATES
@export var is_in_combat: bool = false:
	set(new_value):
		is_in_combat = new_value
		if new_value:
			if not is_in_group("boss"):
				return
			start_encounter()


func hostile_death():
	is_in_combat = false
	stats_current["resource_current"] = 0
	custom_hostile_death()
func custom_hostile_death():
	pass
