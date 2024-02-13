extends CharacterBody3D

class_name BaseUnit

# combat
var stats: Stats
var aura_dict: Dictionary
var absorb_dict: Dictionary

# targeting
var target = null

# state
var is_dead: bool = false
var is_moving: bool = false

@rpc("authority","call_local")
func initialize_base_unit(unittype,UnitID):
	# stats
	stat_init(unittype,UnitID)
	# spells
	spell_container_update(self.stats.stats_current.spell_list)

func stat_init(unit_type: String,unit_id: String) -> void:
	# read stats dict from file
	var file = "res://data/db_stats_"+unit_type+".json"
	var json_dict = JSON.parse_string(FileAccess.get_file_as_string(file))
	var stats_dict = json_dict[unit_id]
	# instantiate stat object
	stats = Stats.new(stats_dict)

func spell_container_update(spell_list):
	# remove previous spells
	for spell in $spell_container.get_children():
		spell.queue_free()
	# add spells to spell container
	for spell in spell_list:
		var spell_scene = load("res://scenes/spells/spell_%s.tscn" % spell)
		spell_scene = spell_scene.instantiate()
		$spell_container.add_child(spell_scene)
	
	pass

class Stats:
	var stats_base: StatsBase
	var stats_current: StatsBase
	var stats_mult: StatMult
	var stats_add: StatAdd
	
	func _init(stat_dict):
		stats_base = StatsBase.new(stat_dict)
		stats_current = stats_base
		stats_mult = StatMult.new()
		stats_add = StatAdd.new()

class StatsBase:
	var unit_name: String
	var unit_class: String
	var size: float
	var spell_list: Array
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
	var modifier: Array = [[[0,0],[0,0]],[[0,0],[0,0]]]
	var damage_modifier: Array = [0,0]
	var heal_modifier: Array = [0,0]
	var defense_modifier: Array = [0,0]
	var heal_taken_modifier: Array = [0,0]
	
	func _init(stat_dict):
		self.unit_name = stat_dict["unit_name"]
		self.unit_class = stat_dict["unit_class"]
		self.size = stat_dict["size"]
		self.spell_list = stat_dict["spell_list"]
		self.speed = stat_dict["speed"]
		self.health_max = stat_dict["health_max"]
		self.health_current = stat_dict["health_max"]
		self.resource_type = stat_dict["resource_type"]
		self.resource_max = stat_dict["resource_max"]
		self.resource_current = stat_dict["resource_current"]
		self.resource_regen = stat_dict["resource_regen"]
		self.primary = stat_dict["primary"]
		self.avoidance = stat_dict["avoidance"]
		self.crit_chance = stat_dict["crit_chance"]
		self.damage_modifier[0] = stat_dict["damage_modifier"]["physical"]
		self.damage_modifier[1] = stat_dict["damage_modifier"]["magic"]
		self.heal_modifier[0] = stat_dict["heal_modifier"]["physical"]
		self.heal_modifier[1] = stat_dict["heal_modifier"]["magic"]
		self.defense_modifier[0] = stat_dict["defense_modifier"]["physical"]
		self.defense_modifier[1] = stat_dict["defense_modifier"]["magic"]
		self.heal_taken_modifier[0] = stat_dict["heal_taken_modifier"]["physical"]
		self.heal_taken_modifier[1] = stat_dict["heal_taken_modifier"]["magic"]
	
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

