class_name UnitStats
extends Resource


@export var unit_name: String
@export var unit_class: String
@export var model: String
@export var size: int
@export var melee_hitbox_size: int
@export var spell_list: Array
@export var movement_speed: float
@export var health_max: int
@export var resource_type: String
@export var resource_max: float
@export var resource_init: float
@export var resource_regen: float
@export var primary: int
@export var avoidance: float
@export var crit_chance: float
@export var crit_magnitude: float
@export var damage_modifier_physical: float
@export var damage_modifier_magic: float
@export var heal_modifier_physical: float
@export var heal_modifier_magic: float
@export var defense_modifier_physical: float
@export var defense_modifier_magic: float
@export var heal_taken_modifier_physical: float
@export var heal_taken_modifier_magic: float


func init_stats_current() -> Dictionary:
	var stats_current = {
		"unit_name":unit_name,
		"unit_class":unit_class,
		"model":model,
		"size":size,
		"melee_hitbox_size":melee_hitbox_size,
		"spell_list":spell_list,
		"movement_speed":movement_speed,
		"health_max":health_max,
		"health_current":health_max,
		"resource_type":resource_type,
		"resource_max":resource_max,
		"resource_current":resource_init,
		"resource_regen":resource_regen,
		"primary":primary,
		"avoidance":avoidance,
		"crit_chance":crit_chance,
		"crit_magnitude":crit_magnitude,
		"damage_modifier_physical":damage_modifier_physical,
		"damage_modifier_magic":damage_modifier_magic,
		"heal_modifier_physical":heal_modifier_physical,
		"heal_modifier_magic":heal_modifier_magic,
		"defense_modifier_physical":defense_modifier_physical,
		"defense_modifier_magic":defense_modifier_magic,
		"heal_taken_modifier_physical":heal_taken_modifier_physical,
		"heal_taken_modifier_magic":heal_taken_modifier_magic
	}
	
	return stats_current


func init_statmult() -> Dictionary:
	var stat_mult = {
	"size":{},
	"movement_speed":{},
	"health_max":{},
	"resource_max":{},
	"primary":{},
	"crit_magnitude":{},
	"damage_modifier_physical":{},
	"damage_modifier_magic":{},
	"heal_modifier_physical":{},
	"heal_modifier_magic":{},
	"defense_modifier_physical":{},
	"defense_modifier_magic":{},
	"heal_taken_modifier_physical":{},
	"heal_taken_modifier_magic":{},
	}
	
	return stat_mult


func init_statadd() -> Dictionary:
	var stat_add = {
	"health_max":{},
	"resource_max":{},
	"primary":{},
	"avoidance":{},
	"crit_chance":{}
	}
	
	return stat_add


func calc_current_partial(
	stats_current: Dictionary,
	stat_mult: Dictionary,
	stat_add: Dictionary,
	stat_list: Array) -> Dictionary:
	if "size" in stat_list:
		stats_current["size"] = size * total_mult_coeff(stat_mult["size"])
	if "movement_speed" in stat_list:
		stats_current["movement_speed"] = movement_speed * total_mult_coeff(stat_mult["movement_speed"])
	if "health_max" in stat_list:
		stats_current["health_max"] = (health_max + total_add_coeff(stat_add["health_max"])) * \
													total_mult_coeff(stat_mult["health_max"])
	if "resource_max" in stat_list:
		stats_current["resource_max"] = (resource_max + total_add_coeff(stat_add ["resource_max"])) * \
													total_mult_coeff(stat_mult["resource_max"])
	if "resource_regen" in stat_list:
		stats_current["resource_regen"] = (resource_regen + total_add_coeff(stat_add["resource_regen"])) * \
													total_mult_coeff(stat_mult["resource_regen"])
	if "primary" in stat_list:
		stats_current["primary"] = (primary + total_add_coeff(stat_add["primary"])) * \
													total_mult_coeff(stat_mult["primary"])
	if "avoidance" in stat_list:
		stats_current["avoidance"] = avoidance + total_add_coeff(stat_add["avoidance"])
	if "crit_chance" in stat_list:
		stats_current["crit_chance"] = crit_chance + total_add_coeff(stat_add["crit_chance"])
	if "crit_magnitude" in stat_list:
		stats_current["crit_magnitude"] = crit_magnitude * total_mult_coeff(stat_mult["crit_magnitude"])
	if "damage_modifier_physical" in stat_list:
		stats_current["damage_modifier_physical"] = damage_modifier_physical * \
													total_mult_coeff(stat_mult["damage_modifier_physical"])
	if "damage_modifier_magic" in stat_list:
		stats_current["damage_modifier_magic"] = damage_modifier_magic * \
													total_mult_coeff(stat_mult["damage_modifier_magic"])
	if "heal_modifier_physical" in stat_list:
		stats_current["heal_modifier_physical"] = heal_modifier_physical * \
													total_mult_coeff(stat_mult["heal_modifier_physical"])
	if "heal_modifier_magic" in stat_list:
		stats_current["heal_modifier_magic"] = heal_modifier_magic * \
													total_mult_coeff(stat_mult["heal_modifier_magic"])
	if "defense_modifier_physical" in stat_list:
		stats_current["defense_modifier_physical"] = defense_modifier_physical * \
													total_mult_coeff(stat_mult["defense_modifier_physical"])
	if "defense_modifier_magic" in stat_list:
		stats_current["defense_modifier_magic"] = defense_modifier_magic * \
													total_mult_coeff(stat_mult["defense_modifier_magic"])
	if "heal_taken_modifier_physical" in stat_list:
		stats_current["heal_taken_modifier_physical"] = heal_taken_modifier_physical * \
													total_mult_coeff(stat_mult["heal_taken_modifier_physical"])
	if "heal_taken_modifier_magic" in stat_list:
		stats_current["heal_taken_modifier_magic"] = heal_taken_modifier_magic * \
													total_mult_coeff(stat_mult["heal_taken_modifier_magic"])
	
	return stats_current


func calc_current_full(
	stats_current: Dictionary,
	stat_mult: Dictionary,
	stat_add: Dictionary) -> Dictionary:
	stats_current["size"] = size * total_mult_coeff(stat_mult["size"])
	stats_current["movement_speed"] = movement_speed * total_mult_coeff(stat_mult["movement_speed"])
	stats_current["health_max"] = (health_max + total_add_coeff(stat_add["health_max"])) * \
												total_mult_coeff(stat_mult["health_max"])
	stats_current["resource_max"] = (resource_max + total_add_coeff(stat_add ["resource_max"])) * \
												total_mult_coeff(stat_mult["resource_max"])
	stats_current["resource_regen"] = (resource_regen + total_add_coeff(stat_add["resource_regen"])) * \
												total_mult_coeff(stat_mult["resource_regen"])
	stats_current["primary"] = (primary + total_add_coeff(stat_add["primary"])) * \
												total_mult_coeff(stat_mult["primary"])
	stats_current["avoidance"] = avoidance + total_add_coeff(stat_add["avoidance"])
	stats_current["crit_chance"] = crit_chance + total_add_coeff(stat_add["crit_chance"])
	stats_current["crit_magnitude"] = crit_magnitude * total_mult_coeff(stat_mult["crit_magnitude"])
	stats_current["damage_modifier_physical"] = damage_modifier_physical * \
												total_mult_coeff(stat_mult["damage_modifier_physical"])
	stats_current["damage_modifier_magic"] = damage_modifier_magic * \
												total_mult_coeff(stat_mult["damage_modifier_magic"])
	stats_current["heal_modifier_physical"] = heal_modifier_physical * \
												total_mult_coeff(stat_mult["heal_modifier_physical"])
	stats_current["heal_modifier_magic"] = heal_modifier_magic * \
												total_mult_coeff(stat_mult["heal_modifier_magic"])
	stats_current["defense_modifier_physical"] = defense_modifier_physical * \
												total_mult_coeff(stat_mult["defense_modifier_physical"])
	stats_current["defense_modifier_magic"] = defense_modifier_magic * \
												total_mult_coeff(stat_mult["defense_modifier_magic"])
	stats_current["heal_taken_modifier_physical"] = heal_taken_modifier_physical * \
												total_mult_coeff(stat_mult["heal_taken_modifier_physical"])
	stats_current["heal_taken_modifier_magic"] = heal_taken_modifier_magic * \
												total_mult_coeff(stat_mult["heal_taken_modifier_magic"])
	
	return stats_current


func total_mult_coeff(coeffs: Dictionary) -> float:
	var total_coeff = 1
	for coeff in coeffs.keys():
		total_coeff = total_coeff * (1+coeffs[coeff])
	return total_coeff


func total_add_coeff(coeffs: Dictionary) -> float:
	var total_coeff = 0
	for coeff in coeffs.keys():
		total_coeff += coeffs[coeff]
	return total_coeff
