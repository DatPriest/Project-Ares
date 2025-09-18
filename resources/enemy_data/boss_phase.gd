extends Resource
class_name BossPhase

@export var name: String
@export_multiline var description: String
@export var health_threshold: float = 1.0  # Percentage of health when this phase starts
@export var movement_speed_multiplier: float = 1.0
@export var attack_speed_multiplier: float = 1.0
@export var special_abilities: Array[PackedScene] = []
@export var visual_effects: Array[PackedScene] = []
@export var phase_duration: float = -1.0  # -1 means infinite
@export var invulnerable_during_transition: bool = true