extends Resource
class_name EnemySpawnData

@export var enemy_scene: PackedScene
@export var weight: int = 1
@export var min_difficulty: int = 0  # Minimum difficulty level to spawn
@export var max_difficulty: int = -1  # Maximum difficulty level to spawn (-1 = no limit)