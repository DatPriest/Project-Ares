extends Resource
class_name EnemyData

@export var id: String
@export var name: String
@export_multiline var description: String

# Core stats
@export var max_health: float = 10.0
@export var max_speed: int = 40
@export var acceleration: float = 5.0
@export var xp_reward: float = 1.0

# Visual
@export var sprite_texture: Texture2D

# Behavior type - determines which behavior script to use
@export_enum("Basic", "Wizard", "Goblin", "Archer") var behavior_type: String = "Basic"

# Archer-specific properties
@export_group("Archer Properties")
@export var arrow_scene: PackedScene
@export var ideal_distance: float = 200.0
@export var arrow_speed: float = 300.0
@export var shoot_interval: float = 2.0

# Wizard-specific properties
@export_group("Wizard Properties")
@export var movement_pause_duration: float = 1.0
@export var movement_active_duration: float = 2.0