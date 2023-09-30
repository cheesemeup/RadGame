extends CharacterBody3D

class_name BaseUnit

var stats
var aura_dict: Dictionary
var absorb_dict: Dictionary

func initialize(unittype,UnitID):
	# stats
	stat_init(unittype,UnitID)
	pass

func stat_init(unit_type: String,UnitID: String) -> void:
	# read stats dict from file
	var file = "res://Data/db_stats_"+unit_type+".json"
	var json_dict = JSON.parse_string(FileAccess.get_file_as_string(file))
	var stats_dict = json_dict[UnitID]
	# instance stat object
	stats = StatsBase.new(stats_dict)
	pass

class StatsBase:
	var name: String
	var unit_class: String
	var size: float
	var spell_list: Array[String]
	var speed: float
	var health_max: int
	var health_current: int
	var resource_type: String
	var resource_max: int
	var resource_current: float
	var resource_regen: float
	var primary: int
	var avoidance: float
	var crit_chance: float
	var damage_modifier_physical: float
	var damage_modifier_magic: float
	var heal_modifier_physical: float
	var heal_modifier_magic: float
	var defense_modifier_physical: float
	var defense_modifier_magic: float
	var heal_taken_modifier_physical: float
	var heal_taken_modifier_magic: float
	var stat_mult: StatMult
	var stat_add: StatAdd
	
	func _init(stat_dict,stat_mods):
		self.name = stat_dict["name"]
		
		if stat_mods:
			stat_mult = StatMult.new()
			stat_add = StatAdd.new()
	
class StatMult:
	var speed: Dictionary = {}
	var health_max: Dictionary = {}
	var resource_max: Dictionary = {}
	var primary: Dictionary = {}
	var damage_modifier_physical: Dictionary = {}
	var damage_modifier_magic: Dictionary = {}
	var heal_modifier_physical: Dictionary = {}
	var heal_modifier_magic: Dictionary = {}
	var defense_modififer_physical: Dictionary = {}
	var defense_midfier_magic: Dictionary = {}
	var healing_taken_modifier_physical: Dictionary = {}
	var healing_takne_modifier_magic: Dictionary = {}

class StatAdd:
	var health_max: Dictionary = {}
	var resource_max: Dictionary = {}
	var primary: Dictionary = {}
	var avoidance: Dictionary = {}
	var crit_chance: Dictionary = {}

