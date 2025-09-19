extends AbilityStats
class_name WeaponStats

# Rarity system integration
@export var weapon_rarity: WeaponRarity
@export var current_weapon_level: int = 0

# Extended stats beyond base AbilityStats
@export var base_critical_chance: float = 0.0
@export var base_critical_multiplier: float = 1.0
@export var base_durability: float = 100.0
@export var base_mana_cost: float = 0.0
@export var base_accuracy: float = 100.0

# Current runtime values with rarity modifiers applied
var current_critical_chance: float = 0.0
var current_critical_multiplier: float = 1.0
var current_durability: float = 100.0
var current_mana_cost: float = 0.0
var current_accuracy: float = 100.0
var current_max_level: int = 20

# Applied rarity modifiers (cached for performance)
var applied_damage_modifier: float = 0.0
var applied_cooldown_modifier: float = 0.0
var applied_range_modifier: float = 0.0
var applied_critical_chance_modifier: float = 0.0
var applied_critical_multiplier_modifier: float = 0.0
var applied_durability_modifier: float = 0.0
var applied_mana_cost_modifier: float = 0.0
var applied_accuracy_modifier: float = 0.0

func _init(
	damage: float = 1.0, 
	cooldown: float = 1.0, 
	damage_upgrade: float = 0.1, 
	rate_upgrade: float = 0.1, 
	range_val: float = 0.0,
	rarity_grade: int = 2
) -> void:
	super._init(damage, cooldown, damage_upgrade, rate_upgrade, range_val)
	
	# Initialize extended base stats
	base_critical_chance = 0.0
	base_critical_multiplier = 1.0
	base_durability = 100.0
	base_mana_cost = 0.0
	base_accuracy = 100.0
	
	# Set up rarity
	weapon_rarity = WeaponRarity.new(rarity_grade)
	_generate_random_rarity_modifiers()
	_update_all_current_values()

func set_weapon_rarity(new_rarity: WeaponRarity) -> void:
	"""Set a new rarity and regenerate modifiers"""
	weapon_rarity = new_rarity
	_generate_random_rarity_modifiers()
	_update_all_current_values()

func _generate_random_rarity_modifiers() -> void:
	"""Generate random stat modifiers based on rarity ranges"""
	if weapon_rarity == null:
		weapon_rarity = WeaponRarity.new(2)  # Default to Common
	
	applied_damage_modifier = weapon_rarity.get_random_damage_modifier()
	applied_cooldown_modifier = weapon_rarity.get_random_cooldown_modifier()
	applied_range_modifier = weapon_rarity.get_random_range_modifier()
	applied_critical_chance_modifier = weapon_rarity.get_random_critical_chance()
	applied_critical_multiplier_modifier = weapon_rarity.get_random_critical_multiplier()
	applied_durability_modifier = weapon_rarity.get_random_durability_modifier()
	applied_mana_cost_modifier = weapon_rarity.get_random_mana_cost_modifier()
	applied_accuracy_modifier = weapon_rarity.get_random_accuracy_modifier()
	
	current_max_level = weapon_rarity.get_max_level_for_rarity()

func apply_damage_upgrade(quantity: int) -> void:
	"""Override to include rarity modifiers"""
	var base_multiplier: float = 1 + (quantity * damage_upgrade_percent)
	var rarity_multiplier: float = 1 + (applied_damage_modifier / 100.0)
	current_damage = base_damage * base_multiplier * rarity_multiplier

func apply_rate_upgrade(quantity: int) -> void:
	"""Override to include rarity modifiers"""
	var base_multiplier: float = 1 - (quantity * rate_upgrade_percent)
	var rarity_multiplier: float = 1 + (applied_cooldown_modifier / 100.0)
	current_cooldown = base_cooldown * base_multiplier * rarity_multiplier
	
	# Ensure cooldown doesn't go negative or too low
	current_cooldown = maxf(current_cooldown, 0.05)

func apply_range_upgrade(quantity: int) -> void:
	"""Apply range upgrades with rarity modifier"""
	var base_range: float = max_range + (quantity * 10.0)  # 10 units per upgrade
	var rarity_multiplier: float = 1 + (applied_range_modifier / 100.0)
	max_range = base_range * rarity_multiplier

func get_current_max_level() -> int:
	"""Get maximum level for this weapon based on rarity"""
	return current_max_level

func can_upgrade_to_level(target_level: int) -> bool:
	"""Check if weapon can be upgraded to target level"""
	return target_level <= current_max_level

func get_level_upgrade_cost(target_level: int) -> int:
	"""Calculate experience cost for upgrading to target level"""
	if not can_upgrade_to_level(target_level):
		return -1  # Invalid upgrade
	
	var base_cost: int = 100
	var level_multiplier: float = 1.2
	var rarity_multiplier: float = 1.0 + (weapon_rarity.rarity_grade * 0.1)
	
	return int(base_cost * pow(level_multiplier, target_level) * rarity_multiplier)

func upgrade_weapon_level() -> bool:
	"""Upgrade weapon by one level if possible"""
	if current_weapon_level >= current_max_level:
		return false
	
	current_weapon_level += 1
	_update_all_current_values()
	return true

func get_critical_hit_data() -> Dictionary:
	"""Get critical hit chance and multiplier"""
	return {
		"chance": current_critical_chance,
		"multiplier": current_critical_multiplier
	}

func calculate_critical_damage(base_damage_val: float) -> float:
	"""Calculate damage with critical hit consideration"""
	if randf() * 100.0 <= current_critical_chance:
		return base_damage_val * current_critical_multiplier
	return base_damage_val

func get_durability_status() -> Dictionary:
	"""Get current durability information"""
	return {
		"current": current_durability,
		"max": base_durability * (1 + applied_durability_modifier / 100.0),
		"percentage": (current_durability / (base_durability * (1 + applied_durability_modifier / 100.0))) * 100.0
	}

func apply_durability_damage(damage_amount: float) -> void:
	"""Reduce weapon durability"""
	current_durability = maxf(0.0, current_durability - damage_amount)

func repair_weapon(repair_amount: float = -1.0) -> void:
	"""Repair weapon durability"""
	var max_durability: float = base_durability * (1 + applied_durability_modifier / 100.0)
	if repair_amount < 0:
		current_durability = max_durability  # Full repair
	else:
		current_durability = minf(max_durability, current_durability + repair_amount)

func is_weapon_broken() -> bool:
	"""Check if weapon is unusable due to durability"""
	return current_durability <= 0.0

func get_accuracy_chance() -> float:
	"""Get current accuracy percentage"""
	return current_accuracy

func will_hit_target() -> bool:
	"""Roll for hit chance based on accuracy"""
	return randf() * 100.0 <= current_accuracy

func get_mana_cost() -> float:
	"""Get current mana cost for using this weapon"""
	return current_mana_cost

func _update_all_current_values() -> void:
	"""Update all current values with rarity modifiers"""
	super._update_current_values()
	
	if weapon_rarity == null:
		return
		
	# Apply rarity modifiers to extended stats
	current_critical_chance = base_critical_chance + applied_critical_chance_modifier
	current_critical_multiplier = base_critical_multiplier * (applied_critical_multiplier_modifier / 100.0 + 1.0)
	
	var durability_multiplier: float = 1 + (applied_durability_modifier / 100.0)
	var max_durability: float = base_durability * durability_multiplier
	if current_durability == base_durability or current_durability > max_durability:
		current_durability = max_durability  # Set to new max if not damaged
	
	current_mana_cost = base_mana_cost * (1 + applied_mana_cost_modifier / 100.0)
	current_mana_cost = maxf(0.0, current_mana_cost)  # Mana cost can't be negative
	
	current_accuracy = base_accuracy + applied_accuracy_modifier
	current_accuracy = clampf(current_accuracy, 0.0, 100.0)  # Accuracy bounded 0-100%

func get_weapon_info_text() -> String:
	"""Get formatted text display of weapon stats"""
	var info: Array[String] = []
	
	if weapon_rarity:
		info.append("Rarity: %s (Grade %d)" % [weapon_rarity.rarity_name, weapon_rarity.rarity_grade])
		info.append("Level: %d/%d" % [current_weapon_level, current_max_level])
	
	info.append("Damage: %.1f (%.1f%%)" % [current_damage, applied_damage_modifier])
	info.append("Cooldown: %.2fs (%.1f%%)" % [current_cooldown, applied_cooldown_modifier])
	info.append("Range: %.1f (%.1f%%)" % [max_range, applied_range_modifier])
	info.append("Critical: %.1f%% chance, %.1fx damage" % [current_critical_chance, current_critical_multiplier])
	info.append("Accuracy: %.1f%%" % current_accuracy)
	
	if current_mana_cost > 0:
		info.append("Mana Cost: %.1f" % current_mana_cost)
	
	var durability_info: Dictionary = get_durability_status()
	info.append("Durability: %.1f/%.1f (%.1f%%)" % [durability_info.current, durability_info.max, durability_info.percentage])
	
	return "\n".join(info)

func get_dps_estimate() -> float:
	"""Calculate estimated DPS including critical hits"""
	if current_cooldown <= 0:
		return 0.0
	
	var base_dps: float = current_damage / current_cooldown
	var crit_bonus: float = (current_critical_chance / 100.0) * (current_critical_multiplier - 1.0)
	var accuracy_modifier: float = current_accuracy / 100.0
	
	return base_dps * (1.0 + crit_bonus) * accuracy_modifier

func create_rarity_variant(new_rarity_grade: int) -> WeaponStats:
	"""Create a new weapon with different rarity but same base stats"""
	var variant: WeaponStats = WeaponStats.new(
		base_damage, base_cooldown, damage_upgrade_percent, 
		rate_upgrade_percent, max_range, new_rarity_grade
	)
	
	# Copy base extended stats
	variant.base_critical_chance = base_critical_chance
	variant.base_critical_multiplier = base_critical_multiplier
	variant.base_durability = base_durability
	variant.base_mana_cost = base_mana_cost
	variant.base_accuracy = base_accuracy
	
	variant._generate_random_rarity_modifiers()
	variant._update_all_current_values()
	
	return variant