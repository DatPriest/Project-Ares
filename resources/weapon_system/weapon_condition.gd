extends Resource
class_name WeaponCondition

## Defines weapon condition affecting its stats, appearance, and value
## Conditions provide additional variation to weapon drops

@export var id: String
@export var name: String
@export var description: String

# Stat modifiers
@export var damage_modifier: float = 1.0  # Multiplier for damage stats
@export var speed_modifier: float = 1.0   # Multiplier for speed stats
@export var durability_modifier: float = 1.0  # Future durability system

# Visual and value modifiers
@export var visual_tint: Color = Color.WHITE
@export var trade_value_modifier: float = 1.0  # 0.5 = half value, 1.5 = 1.5x value
@export var condition_suffix: String = ""  # Added to weapon name display

# Condition-specific effects
@export var stat_bonus_range: Vector2 = Vector2.ZERO  # Additional random bonus/penalty
@export var special_effects: Array[String] = []  # Future special effect system