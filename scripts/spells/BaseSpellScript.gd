extends Node

class_name BaseSpell

var spell_base: Spell
var spell_current: Spell
var result_strings

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

func initialize_base_spell(spell_id: String):
	var json_dict = JSON.parse_string(FileAccess.get_file_as_string("res://data/db_spells.json"))
	var spell_dict = json_dict[spell_id]
	spell_base = Spell.new(spell_dict)
	spell_current = spell_base
	result_strings = [
		"insufficient resources",
		"invalid target",
		"out of range"
	]

class Spell:
	var spell_name
	var type
	var resource_cost
	var cooldown
	var on_gcd
	var range
	var targetgroup
	var effect_type
	var valuebase
	var base_modifier
	var casttime
	var avoidable
	var avoidance_modifier
	var can_crit
	var crit_chance_modifier
	var crit_multiplier_modifier

	func _init(spell_dict):
		self.spell_name = spell_dict["spell_name"]
		self.type = spell_dict["event_type"]
		self.resource_cost = spell_dict["resource_cost"]
		self.cooldown = spell_dict["cooldown"]
		self.on_gcd = spell_dict["on_gcd"]
		self.range = spell_dict["range"]
		self.targetgroup = spell_dict["targetgroup"]
		self.effect_type = spell_dict["effect_type"]
		self.valuebase = spell_dict["valuebase"]
		self.base_modifier = spell_dict["base_modifier"]
		self.casttime = spell_dict["casttime"]
		self.avoidable = spell_dict["avoidable"]
		self.avoidance_modifier = spell_dict["avoidance_modifier"]
		self.can_crit = spell_dict["can_crit"]
		self.crit_chance_modifier = spell_dict["crit_chance_modifier"]
		self.crit_multiplier_modifier = spell_dict["crit_multiplier_modifier"]
