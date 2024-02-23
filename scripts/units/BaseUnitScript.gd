extends CharacterBody3D

class_name BaseUnit

# combat
@export var stats_current: Dictionary
var stats_base: Dictionary
var stats_mult
var stats_add
var aura_list: Array = []
var absorb_dict: Dictionary

# targeting
var target = null  # for unitframes, only local
var selected_target = null  # for targeting with spells
var mouseover_target = null  # for targeting with spells

# state
var is_dead: bool = false
var is_moving: bool = false

func initialize_base_unit(unittype: String,UnitID: String):
	# stats
	stat_init(unittype,UnitID)
	# spells
	spell_container_init(self.stats_current.spell_list)
	# auras
	var aura_container = preload("res://scenes/functionalities/aura_container.tscn").instantiate()
	add_child(aura_container)

func stat_init(unit_type: String,unit_id: String) -> void:
	# read stats dict from file
	var file = "res://data/db_stats_"+unit_type+".json"
	var json_dict = JSON.parse_string(FileAccess.get_file_as_string(file))
	stats_base = json_dict[unit_id]
	stats_current = stats_base.duplicate(true)
	stats_mult = initialize_statmult()
	stats_add = initialize_statadd()

func initialize_statmult():
	var stat_mult = {}
	stat_mult["size"] = {}
	stat_mult["speed"] = {}
	stat_mult["size"] = {}
	stat_mult["health_max"] = {}
	stat_mult["resource_max"] = {}
	stat_mult["primary"] = {}
	stat_mult["damage_modifier"] = {}
	stat_mult["damage_modifier"]["physical"] = {}
	stat_mult["damage_modifier"]["magic"] = {}
	stat_mult["heal_modifier"] = {}
	stat_mult["heal_modifier"]["physical"] = {}
	stat_mult["heal_modifier"]["magic"] = {}
	stat_mult["defense_modifier"] = {}
	stat_mult["defense_modifier"]["physical"] = {}
	stat_mult["defense_modifier"]["magic"] = {}
	stat_mult["heal_taken_modifier"] = {}
	stat_mult["heal_taken_modifier"]["physical"] = {}
	stat_mult["heal_taken_modifier"]["magic"] = {}
	return stat_mult
func initialize_statadd():
	var stat_add = {}
	stat_add["health_max"] = {}
	stat_add["resource_max"] = {}
	stat_add["primary"] = {}
	stat_add["avoidance"] = {}
	stat_add["crit_chance"] = {}
	return stat_add

func spell_container_init(spell_list):
	# remove previous spells
	for spell in $spell_container.get_children():
		spell.queue_free()
	# add spells to spell container
	for spell in spell_list:
		var spell_scene = load("res://scenes/spells/spell_%s.tscn" % spell)
		spell_scene = spell_scene.instantiate()
		$spell_container.add_child(spell_scene)
