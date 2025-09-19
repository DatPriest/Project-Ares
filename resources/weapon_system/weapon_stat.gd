extends Resource
class_name WeaponStat

## Represents a single weapon stat with its type, value, and modifiers
## Supports both positive and negative stats for trade-offs

enum StatType {
	DAMAGE,
	FIRE_RATE,
	RANGE,
	CRITICAL_CHANCE,
	CRITICAL_DAMAGE,
	PENETRATION,
	PROJECTILE_COUNT,
	PROJECTILE_SPEED,
	AREA_OF_EFFECT,
	LIFE_STEAL,
	STATUS_CHANCE,
	RELOAD_SPEED
}

@export var stat_type: StatType
@export var base_value: float = 0.0
@export var current_value: float = 0.0
@export var is_percentage: bool = false  # True for percentages, false for flat values

# Randomization
@export var random_variance: float = 3.0  # ±3 random variance by default

# Display
@export var display_name: String = ""
@export var display_format: String = "%+.1f"  # Format string for display
@export var positive_color: Color = Color.GREEN
@export var negative_color: Color = Color.RED

func _init(type: StatType = StatType.DAMAGE, value: float = 0.0) -> void:
	stat_type = type
	base_value = value
	current_value = value
	_setup_display_properties()

func apply_random_variance() -> void:
	"""Apply random variance to the stat value"""
	var variance = randf_range(-random_variance, random_variance)
	current_value = base_value + variance

func apply_condition_modifier(condition: WeaponCondition) -> void:
	"""Apply condition modifiers to this stat"""
	match stat_type:
		StatType.DAMAGE:
			current_value *= condition.damage_modifier
		StatType.FIRE_RATE, StatType.RELOAD_SPEED:
			current_value *= condition.speed_modifier
		_:
			# Apply generic modifier if available
			pass
	
	# Apply condition-specific bonus/penalty
	if condition.stat_bonus_range != Vector2.ZERO:
		var bonus = randf_range(condition.stat_bonus_range.x, condition.stat_bonus_range.y)
		current_value += bonus

func get_display_value() -> String:
	"""Get formatted display string for this stat"""
	var format_str = display_format
	if is_percentage:
		format_str += "%%"
	
	return format_str % current_value

func get_display_color() -> Color:
	"""Get color for displaying this stat based on positive/negative value"""
	return positive_color if current_value >= 0 else negative_color

func _setup_display_properties() -> void:
	"""Setup display properties based on stat type"""
	match stat_type:
		StatType.DAMAGE:
			display_name = "Damage"
			display_format = "%+.0f"
		StatType.FIRE_RATE:
			display_name = "Fire Rate"
			display_format = "%+.1f"
			is_percentage = true
		StatType.RANGE:
			display_name = "Range"
			display_format = "%+.0f"
		StatType.CRITICAL_CHANCE:
			display_name = "Crit Chance"
			display_format = "%+.1f"
			is_percentage = true
		StatType.CRITICAL_DAMAGE:
			display_name = "Crit Damage"
			display_format = "%+.0f"
			is_percentage = true
		StatType.PENETRATION:
			display_name = "Penetration"
			display_format = "%+.0f"
		StatType.PROJECTILE_COUNT:
			display_name = "Projectiles"
			display_format = "%+.0f"
		StatType.PROJECTILE_SPEED:
			display_name = "Projectile Speed"
			display_format = "%+.0f"
		StatType.AREA_OF_EFFECT:
			display_name = "AoE Radius"
			display_format = "%+.0f"
		StatType.LIFE_STEAL:
			display_name = "Life Steal"
			display_format = "%+.1f"
			is_percentage = true
		StatType.STATUS_CHANCE:
			display_name = "Status Chance"
			display_format = "%+.1f"
			is_percentage = true
		StatType.RELOAD_SPEED:
			display_name = "Reload Speed"
			display_format = "%+.1f"
			is_percentage = true