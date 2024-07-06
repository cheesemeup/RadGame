extends CharacterBody3D

class_name BaseUnit

# combat
@export var stats_current: Dictionary
var stats_base: Dictionary
var stats_mult: Dictionary
var stats_add: Dictionary
var aura_list: Array = []
var absorb_array: Array = []

# targeting
var target = null  # for unitframes, only local
var selected_target = null  # for targeting with spells
var mouseover_target = null  # for targeting with spells

# state
var is_dead: bool = false
var is_moving: bool = false


func initialize_base_unit(unittype: String, unit_id: String):
	# stats
	stat_init(unittype,unit_id)
	# spells
	var spell_container = preload("res://scenes/functionalities/spell_container.tscn").instantiate()
	add_child(spell_container)
	spell_container_init(self.stats_current.spell_list)
	# auras
	var aura_container = preload("res://scenes/functionalities/aura_container.tscn").instantiate()
	add_child(aura_container)


func stat_init(unit_type: String, unit_id: String) -> void:
	# read stats dict from file
	var file = "res://data/db_stats_"+unit_type+".json"
	var json_dict = JSON.parse_string(FileAccess.get_file_as_string(file))
	stats_base = json_dict[unit_id]
	stats_current = stats_base.duplicate(true)
	stats_mult = initialize_statmult()
	stats_add = initialize_statadd()


func initialize_statmult() -> Dictionary:
	var stat_mult = {}
	stat_mult["size"] = {}
	stat_mult["speed"] = {}
	stat_mult["size"] = {}
	stat_mult["health_max"] = {}
	stat_mult["resource_max"] = {}
	stat_mult["primary"] = {}
	stat_mult["damage_modifier_physical"] = {}
	stat_mult["damage_modifier_magic"] = {}
	stat_mult["heal_modifier_physical"] = {}
	stat_mult["heal_modifier_magic"] = {}
	stat_mult["defense_modifier_physical"] = {}
	stat_mult["defense_modifier_magic"] = {}
	stat_mult["heal_taken_modifier_physical"] = {}
	stat_mult["heal_taken_modifier_magic"] = {}
	return stat_mult


func initialize_statadd() -> Dictionary:
	var stat_add = {}
	stat_add["health_max"] = {}
	stat_add["resource_max"] = {}
	stat_add["primary"] = {}
	stat_add["avoidance"] = {}
	stat_add["crit_chance"] = {}
	return stat_add


func spell_container_init(spell_list: Array):
	# remove previous spells
	for spell in $spell_container.get_children():
		spell.queue_free()
	# add spells to spell container
	for spell in spell_list:
		var spell_scene = load("res://scenes/spells/spell_%s.tscn" % spell)
		spell_scene = spell_scene.instantiate()
		$spell_container.add_child(spell_scene)


func cd_timers_init():
	var cd_timer_scene = preload("res://scenes/functionalities/cd_timer.tscn")
	var timer: Timer
	for spell in get_node("spell_container").get_children():
		timer = cd_timer_scene.instantiate()
		timer.name = "cd_timer_%s"%spell.name
		timer.one_shot = false
		get_node("cd_timers").add_child(timer)
	print(get_node("cd_timers").get_children())
