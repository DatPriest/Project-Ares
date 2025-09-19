extends Resource
class_name CharacterStat

## Represents a single character stat with its type, value, and modifiers
## Supports both positive and negative stats for build variety and trade-offs

enum StatType {
	# Core Stats
	HEALTH,
	STAMINA,
	SPEED,
	
	# Combat Stats
	DAMAGE,
	CRITICAL_CHANCE,
	CRITICAL_DAMAGE,
	ATTACK_SPEED,
	
	# Defensive Stats
	ARMOR_RATING,
	MAGIC_RESISTANCE,
	FIRE_RESISTANCE,
	ICE_RESISTANCE,
	POISON_RESISTANCE,
	
	# Utility Stats
	LUCK,
	EXPERIENCE_GAIN,
	DROP_RATE,
	PICKUP_RANGE,
	
	# Advanced Stats
	AGILITY,
	INTELLIGENCE,
	SKILL_PROFICIENCY,
	REGENERATION
}

@export var stat_type: StatType
@export var base_value: float = 0.0
@export var current_value: float = 0.0
@export var is_percentage: bool = false  # True for percentages, false for flat values

# Randomization
@export var random_variance: float = 2.0  # ±2 random variance by default (slightly less than weapons)

# Display
@export var display_name: String = ""
@export var display_format: String = "%+.1f"  # Format string for display
@export var positive_color: Color = Color.GREEN
@export var negative_color: Color = Color.RED

# Stat constraints
@export var min_value: float = -999.0  # Minimum allowed value
@export var max_value: float = 999.0   # Maximum allowed value

func _init(type: StatType = StatType.HEALTH, value: float = 0.0) -> void:
	stat_type = type
	base_value = value
	current_value = value
	_setup_display_properties()

func apply_random_variance() -> void:
	"""Apply random variance to the stat value"""
	var variance = randf_range(-random_variance, random_variance)
	current_value = clamp(base_value + variance, min_value, max_value)

func apply_modifier(modifier: float, is_additive: bool = true) -> void:
	"""Apply a modifier to this stat (additive or multiplicative)"""
	if is_additive:
		current_value = clamp(current_value + modifier, min_value, max_value)
	else:
		current_value = clamp(current_value * modifier, min_value, max_value)

func get_display_value() -> String:
	"""Get formatted display string for this stat"""
	var format_str = display_format
	
	if is_percentage:
		format_str += "%%"
	
	return format_str % current_value

func get_display_color() -> Color:
	"""Get color for displaying this stat based on positive/negative value"""
	return positive_color if current_value >= 0 else negative_color

func reset_to_base() -> void:
	"""Reset current value to base value"""
	current_value = base_value

func _setup_display_properties() -> void:
	"""Setup display properties based on stat type"""
	match stat_type:
		StatType.HEALTH:
			display_name = "Health"
			display_format = "%+.0f"
			max_value = 9999.0
			min_value = 1.0  # Health shouldn't go below 1
		StatType.STAMINA:
			display_name = "Stamina"
			display_format = "%+.0f"
			max_value = 500.0
		StatType.SPEED:
			display_name = "Speed"
			display_format = "%+.1f"
			is_percentage = true
		StatType.DAMAGE:
			display_name = "Damage"
			display_format = "%+.0f"
		StatType.CRITICAL_CHANCE:
			display_name = "Crit Chance"
			display_format = "%+.1f"
			is_percentage = true
			max_value = 100.0
		StatType.CRITICAL_DAMAGE:
			display_name = "Crit Damage"
			display_format = "%+.0f"
			is_percentage = true
		StatType.ATTACK_SPEED:
			display_name = "Attack Speed"
			display_format = "%+.1f"
			is_percentage = true
		StatType.ARMOR_RATING:
			display_name = "Armor"
			display_format = "%+.0f"
		StatType.MAGIC_RESISTANCE:
			display_name = "Magic Resist"
			display_format = "%+.1f"
			is_percentage = true
			max_value = 90.0  # Cap at 90% resistance
		StatType.FIRE_RESISTANCE:
			display_name = "Fire Resist"
			display_format = "%+.1f"
			is_percentage = true
			max_value = 90.0
		StatType.ICE_RESISTANCE:
			display_name = "Ice Resist"
			display_format = "%+.1f"
			is_percentage = true
			max_value = 90.0
		StatType.POISON_RESISTANCE:
			display_name = "Poison Resist"
			display_format = "%+.1f"
			is_percentage = true
			max_value = 90.0
		StatType.LUCK:
			display_name = "Luck"
			display_format = "%+.0f"
			max_value = 100.0
		StatType.EXPERIENCE_GAIN:
			display_name = "XP Gain"
			display_format = "%+.1f"
			is_percentage = true
		StatType.DROP_RATE:
			display_name = "Drop Rate"
			display_format = "%+.1f"
			is_percentage = true
		StatType.PICKUP_RANGE:
			display_name = "Pickup Range"
			display_format = "%+.0f"
		StatType.AGILITY:
			display_name = "Agility"
			display_format = "%+.0f"
		StatType.INTELLIGENCE:
			display_name = "Intelligence"
			display_format = "%+.0f"
		StatType.SKILL_PROFICIENCY:
			display_name = "Skill Proficiency"
			display_format = "%+.1f"
			is_percentage = true
		StatType.REGENERATION:
			display_name = "Regeneration"
			display_format = "%+.1f"
			is_percentage = true