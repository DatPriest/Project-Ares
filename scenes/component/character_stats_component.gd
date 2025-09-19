extends Node
class_name CharacterStatsComponent

## Component that manages character statistics
## Follows the established component architecture pattern
## Handles stat initialization, modification, and integration with other systems

signal stat_changed(stat: CharacterStat)
signal stats_recalculated

@export var base_stats: Array[CharacterStat] = []
@export var enable_random_variance: bool = true

var current_stats: Dictionary = {}  # StatType -> CharacterStat
var stat_modifiers: Dictionary = {}  # StatType -> Array of modifiers

func _ready() -> void:
	_initialize_stats()
	GameEvents.ability_upgrade_added.connect(_on_ability_upgrade_added)

func _initialize_stats() -> void:
	"""Initialize stats from base_stats array and create defaults if needed"""
	current_stats.clear()
	
	# Add base stats
	for stat in base_stats:
		current_stats[stat.stat_type] = stat.duplicate()
		if enable_random_variance:
			current_stats[stat.stat_type].apply_random_variance()
	
	# Create default stats if not provided
	_create_default_stats()
	
	stats_recalculated.emit()

func _create_default_stats() -> void:
	"""Create default stats that every character should have"""
	var default_stat_values = {
		CharacterStat.StatType.HEALTH: 100.0,
		CharacterStat.StatType.STAMINA: 50.0,
		CharacterStat.StatType.SPEED: 0.0,  # 0% speed modifier by default
		CharacterStat.StatType.DAMAGE: 0.0,
		CharacterStat.StatType.CRITICAL_CHANCE: 5.0,  # 5% base crit
		CharacterStat.StatType.LUCK: 0.0,
		CharacterStat.StatType.EXPERIENCE_GAIN: 0.0,  # 0% bonus XP by default
		CharacterStat.StatType.PICKUP_RANGE: 0.0,
	}
	
	for stat_type in default_stat_values:
		if not current_stats.has(stat_type):
			var new_stat = CharacterStat.new(stat_type, default_stat_values[stat_type])
			if enable_random_variance:
				new_stat.apply_random_variance()
			current_stats[stat_type] = new_stat

func get_stat_value(stat_type: CharacterStat.StatType) -> float:
	"""Get the current value of a specific stat"""
	if current_stats.has(stat_type):
		return current_stats[stat_type].current_value
	return 0.0

func get_stat(stat_type: CharacterStat.StatType) -> CharacterStat:
	"""Get the complete stat object"""
	return current_stats.get(stat_type, null)

func modify_stat(stat_type: CharacterStat.StatType, modifier: float, is_additive: bool = true, is_temporary: bool = false) -> void:
	"""Modify a stat value"""
	if not current_stats.has(stat_type):
		# Create the stat if it doesn't exist
		var new_stat = CharacterStat.new(stat_type, 0.0)
		current_stats[stat_type] = new_stat
	
	var stat = current_stats[stat_type]
	stat.apply_modifier(modifier, is_additive)
	
	# Track temporary modifiers for removal later
	if is_temporary:
		if not stat_modifiers.has(stat_type):
			stat_modifiers[stat_type] = []
		stat_modifiers[stat_type].append({
			"value": modifier,
			"is_additive": is_additive
		})
	
	stat_changed.emit(stat)

func add_stat_modifier(stat_type: CharacterStat.StatType, modifier: float, is_additive: bool = true) -> void:
	"""Add a permanent stat modifier"""
	modify_stat(stat_type, modifier, is_additive, false)

func remove_all_temporary_modifiers() -> void:
	"""Remove all temporary stat modifiers and recalculate"""
	stat_modifiers.clear()
	_recalculate_all_stats()

func _recalculate_all_stats() -> void:
	"""Recalculate all stats from base values"""
	for stat_type in current_stats:
		var stat = current_stats[stat_type]
		stat.reset_to_base()
		if enable_random_variance:
			stat.apply_random_variance()
	
	stats_recalculated.emit()

func get_all_stats() -> Array[CharacterStat]:
	"""Get all current stats as an array"""
	var stats_array: Array[CharacterStat] = []
	for stat in current_stats.values():
		stats_array.append(stat)
	return stats_array

func get_stats_for_display() -> Array[CharacterStat]:
	"""Get stats that should be displayed in UI (non-zero values)"""
	var display_stats: Array[CharacterStat] = []
	for stat in current_stats.values():
		# Show stat if it has a meaningful value or is a core stat
		if abs(stat.current_value) > 0.1 or _is_core_stat(stat.stat_type):
			display_stats.append(stat)
	return display_stats

func _is_core_stat(stat_type: CharacterStat.StatType) -> bool:
	"""Check if this is a core stat that should always be displayed"""
	return stat_type in [
		CharacterStat.StatType.HEALTH,
		CharacterStat.StatType.STAMINA,
		CharacterStat.StatType.DAMAGE,
		CharacterStat.StatType.CRITICAL_CHANCE
	]

func _on_ability_upgrade_added(ability_upgrade: AbilityUpgrade, current_upgrades: Dictionary) -> void:
	"""Handle ability upgrades that might affect character stats"""
	# Handle player speed upgrade (existing system integration)
	if ability_upgrade.id == "player_speed":
		var speed_bonus = current_upgrades["player_speed"]["quantity"] * 10.0  # 10% per level
		modify_stat(CharacterStat.StatType.SPEED, speed_bonus, true, false)
	
	# Handle other potential stat-affecting upgrades
	# This can be extended as new upgrades are added
	pass

# Integration methods for existing systems
func get_health_bonus() -> float:
	"""Get health bonus for health component integration"""
	return get_stat_value(CharacterStat.StatType.HEALTH)

func get_speed_multiplier() -> float:
	"""Get speed multiplier for velocity component integration"""
	var speed_bonus = get_stat_value(CharacterStat.StatType.SPEED)
	return 1.0 + (speed_bonus / 100.0)  # Convert percentage to multiplier

func get_damage_bonus() -> float:
	"""Get damage bonus for weapon integration"""
	return get_stat_value(CharacterStat.StatType.DAMAGE)

func get_critical_chance() -> float:
	"""Get critical hit chance as percentage"""
	return get_stat_value(CharacterStat.StatType.CRITICAL_CHANCE)

func get_experience_multiplier() -> float:
	"""Get experience gain multiplier"""
	var xp_bonus = get_stat_value(CharacterStat.StatType.EXPERIENCE_GAIN)
	return 1.0 + (xp_bonus / 100.0)

func get_pickup_range_bonus() -> float:
	"""Get pickup range bonus in pixels"""
	return get_stat_value(CharacterStat.StatType.PICKUP_RANGE)