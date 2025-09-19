extends Resource
class_name WeaponInstance

## Represents a specific weapon instance with rarity, condition, and stats
## This is the main class that ties together all weapon system components

@export var id: String
@export var base_weapon_id: String  # Reference to base weapon (e.g., "bow", "sword")
@export var rarity: WeaponRarity
@export var condition: WeaponCondition
@export var stats: Array[WeaponStat] = []

# Upgrade progression
@export var current_upgrade_level: int = 0
@export var upgrade_experience: float = 0.0

# Identification and display
@export var display_name: String = ""
@export var full_description: String = ""

func _init(weapon_id: String = "", rarity_resource: WeaponRarity = null, condition_resource: WeaponCondition = null) -> void:
	if weapon_id != "":
		base_weapon_id = weapon_id
		_generate_id()
	
	if rarity_resource:
		rarity = rarity_resource
	
	if condition_resource:
		condition = condition_resource
	
	if rarity and condition:
		_generate_stats()
		_update_display_name()

func _generate_id() -> void:
	"""Generate unique ID for this weapon instance"""
	id = base_weapon_id + "_" + str(Time.get_unix_time_from_system()) + "_" + str(randi() % 10000)

func _generate_stats() -> void:
	"""Generate random stats based on rarity and condition"""
	if not rarity:
		return
	
	stats.clear()
	var stat_count = rarity.get_random_stat_count()
	var stat_range = rarity.get_stat_range()
	
	# Get available stat types for this weapon
	var available_stats = _get_available_stat_types()
	available_stats.shuffle()
	
	for i in range(stat_count):
		if i >= available_stats.size():
			break
			
		var stat_type = available_stats[i]
		var base_value = randf_range(stat_range.x, stat_range.y)
		
		var weapon_stat = WeaponStat.new(stat_type, base_value)
		weapon_stat.apply_random_variance()
		
		if condition:
			weapon_stat.apply_condition_modifier(condition)
		
		stats.append(weapon_stat)

func _get_available_stat_types() -> Array[WeaponStat.StatType]:
	"""Get available stat types based on weapon type"""
	# Base stats available to all weapons
	var available_stats: Array[WeaponStat.StatType] = [
		WeaponStat.StatType.DAMAGE,
		WeaponStat.StatType.FIRE_RATE,
		WeaponStat.StatType.RANGE,
		WeaponStat.StatType.CRITICAL_CHANCE,
		WeaponStat.StatType.CRITICAL_DAMAGE
	]
	
	# Add weapon-specific stats
	match base_weapon_id:
		"bow", "magic_staff":
			available_stats.append_array([
				WeaponStat.StatType.PROJECTILE_COUNT,
				WeaponStat.StatType.PROJECTILE_SPEED,
				WeaponStat.StatType.PENETRATION
			])
		"magic_staff":
			available_stats.append(WeaponStat.StatType.AREA_OF_EFFECT)
		"sword", "axe", "double_sword":
			available_stats.append_array([
				WeaponStat.StatType.LIFE_STEAL,
				WeaponStat.StatType.STATUS_CHANCE
			])
		"shield":
			available_stats.append_array([
				WeaponStat.StatType.AREA_OF_EFFECT,
				WeaponStat.StatType.STATUS_CHANCE
			])
	
	return available_stats

func _update_display_name() -> void:
	"""Update the display name based on rarity and condition"""
	display_name = ""
	
	if condition and condition.condition_suffix != "":
		display_name = condition.condition_suffix + " "
	
	# Get base weapon name (this could be improved with a lookup table)
	var base_name = base_weapon_id.capitalize()
	display_name += base_name
	
	if rarity:
		display_name = "[color=#" + rarity.color.to_html() + "]" + display_name + "[/color]"
		display_name += " (" + rarity.name + ")"

func get_max_upgrade_level() -> int:
	"""Get maximum upgrade level for this weapon"""
	if rarity:
		return rarity.get_max_upgrade_level()
	return 10  # Default fallback

func can_upgrade() -> bool:
	"""Check if weapon can be upgraded further"""
	return current_upgrade_level < get_max_upgrade_level()

func upgrade() -> bool:
	"""Upgrade the weapon by one level"""
	if not can_upgrade():
		return false
	
	current_upgrade_level += 1
	_apply_upgrade_bonuses()
	return true

func _apply_upgrade_bonuses() -> void:
	"""Apply stat bonuses for current upgrade level"""
	var upgrade_bonus = current_upgrade_level * 0.1  # 10% per level
	
	for stat in stats:
		if stat.stat_type == WeaponStat.StatType.DAMAGE:
			stat.current_value = stat.base_value * (1.0 + upgrade_bonus)

func get_total_dps() -> float:
	"""Calculate total DPS for this weapon instance"""
	var damage = 0.0
	var fire_rate_bonus = 0.0
	var crit_chance = 0.0
	var crit_damage = 1.0
	
	for stat in stats:
		match stat.stat_type:
			WeaponStat.StatType.DAMAGE:
				damage += stat.current_value
			WeaponStat.StatType.FIRE_RATE:
				fire_rate_bonus += stat.current_value / 100.0  # Convert percentage
			WeaponStat.StatType.CRITICAL_CHANCE:
				crit_chance += stat.current_value / 100.0
			WeaponStat.StatType.CRITICAL_DAMAGE:
				crit_damage += stat.current_value / 100.0
	
	# Base fire rate depends on weapon type
	var base_fire_rate = _get_base_fire_rate()
	var effective_fire_rate = base_fire_rate * (1.0 + fire_rate_bonus)
	
	# Calculate DPS with critical hits
	var average_damage = damage * (1.0 + (crit_chance * crit_damage))
	return average_damage * effective_fire_rate

func _get_base_fire_rate() -> float:
	"""Get base fire rate for weapon type"""
	match base_weapon_id:
		"sword", "double_sword":
			return 1.5  # 1.5 attacks per second
		"axe":
			return 1.0
		"bow":
			return 0.8
		"magic_staff":
			return 0.6
		"shield":
			return 2.0
		_:
			return 1.0

func get_trade_value() -> float:
	"""Calculate trade value based on rarity, condition, and stats"""
	var base_value = 10.0
	
	if rarity:
		base_value *= rarity.trade_value_multiplier * rarity.grade
	
	if condition:
		base_value *= condition.trade_value_modifier
	
	# Add value for positive stats
	for stat in stats:
		if stat.current_value > 0:
			base_value += stat.current_value * 0.1
	
	# Add value for upgrade level
	base_value *= (1.0 + current_upgrade_level * 0.2)
	
	return base_value

func get_description() -> String:
	"""Get full description including stats"""
	var desc = display_name + "\n\n"
	
	if rarity:
		desc += "Rarity: " + rarity.name + " (Grade " + str(rarity.grade) + ")\n"
	
	if condition:
		desc += "Condition: " + condition.name + "\n"
	
	desc += "Upgrade Level: " + str(current_upgrade_level) + "/" + str(get_max_upgrade_level()) + "\n\n"
	
	desc += "Stats:\n"
	for stat in stats:
		var color = "#00ff00" if stat.current_value >= 0 else "#ff0000"
		desc += "[color=" + color + "]" + stat.display_name + ": " + stat.get_display_value() + "[/color]\n"
	
	desc += "\nDPS: " + "%.1f" % get_total_dps()
	desc += "\nTrade Value: " + "%.0f" % get_trade_value()
	
	return desc