extends Resource
class_name WaveResource

@export var id: String
@export var name: String
@export_multiline var description: String
@export var start_time: float = 0.0  # Time in seconds when this wave starts
@export var duration: float = -1.0   # Duration of wave, -1 means infinite
@export var base_spawn_interval: float = 2.0  # Base time between spawns
@export var spawn_interval_scaling: float = 0.95  # Multiplier per difficulty level
@export var min_spawn_interval: float = 0.1  # Minimum spawn interval
@export var enemy_types: Array[EnemySpawnData] = []