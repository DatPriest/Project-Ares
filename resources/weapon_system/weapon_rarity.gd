extends Resource
class_name WeaponRarity

## Defines a weapon rarity grade with its properties and stat modifiers
## Used to determine weapon performance, upgrade potential, and value

@export var id: String
@export var name: String
@export var grade: int = 1  # 1-10 rarity grades
@export var color: Color = Color.WHITE
@export_multiline var description: String

# Upgrade progression
@export var max_upgrade_level: int = 10  # Base 10 levels per grade
@export var level_multiplier: float = 10.0  # Grade 1: 10, Grade 2: 20, etc.

# Stat modifiers
@export var stat_range_multiplier: float = 1.0  # How much stats can vary
@export var base_stat_bonus: float = 0.0  # Flat bonus to all stats
@export var stat_count_min: int = 1  # Minimum number of stats
@export var stat_count_max: int = 3  # Maximum number of stats

# Value and rarity
@export var drop_weight: float = 100.0  # Lower = rarer
@export var trade_value_multiplier: float = 1.0

func get_max_upgrade_level() -> int:
	return int(grade * level_multiplier)

func get_stat_range() -> Vector2:
	# Returns min/max stat values for this rarity
	var base_range = 30.0 * grade  # Grade 1: ±30, Grade 10: ±300
	return Vector2(-base_range, base_range)

func get_random_stat_count() -> int:
	return randi_range(stat_count_min, stat_count_max)