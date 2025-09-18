extends Resource
class_name AbilityStats

@export var base_damage: float = 1.0
@export var base_cooldown: float = 1.0
@export var damage_upgrade_percent: float = 0.1
@export var rate_upgrade_percent: float = 0.1
@export var max_range: float = 0.0

# Current runtime values (calculated from base + upgrades)
var current_damage: float = 1.0
var current_cooldown: float = 1.0

func _init(damage: float = 1.0, cooldown: float = 1.0, damage_upgrade: float = 0.1, rate_upgrade: float = 0.1, range: float = 0.0) -> void:
	base_damage = damage
	base_cooldown = cooldown
	damage_upgrade_percent = damage_upgrade
	rate_upgrade_percent = rate_upgrade
	max_range = range
	_update_current_values()

func apply_damage_upgrade(quantity: int) -> void:
	current_damage = base_damage * (1 + (quantity * damage_upgrade_percent))

func apply_rate_upgrade(quantity: int) -> void:
	current_cooldown = base_cooldown * (1 - (quantity * rate_upgrade_percent))

func reset_to_base() -> void:
	_update_current_values()

func _update_current_values() -> void:
	current_damage = base_damage
	current_cooldown = base_cooldown