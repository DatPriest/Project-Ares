extends Node

const SPAWN_RADIUS = 380
@export var arena_time_manager: Node
@export var wave_spawner_scene: PackedScene = preload("res://scenes/component/wave_spawner/wave_spawner.tscn")

@export var generic_enemy_scene: PackedScene



# Enemy data resources
@export var basic_enemy_data: EnemyData
@export var wizard_enemy_data: EnemyData  
@export var goblin_enemy_data: EnemyData
@export var goblin_archer_data: EnemyData

@onready var timer = $Timer

var base_spawn_time = 0
var enemy_table = WeightedTable.new()

func _ready():
	enemy_table.add_item(basic_enemy_data, 10)
	base_spawn_time = timer.wait_time
	timer.timeout.connect(on_timer_timeout)
	arena_time_manager.arena_difficulty_increased.connect(on_arena_difficulty_increased)

# Wave resources to load - can be configured in the editor
@export var wave_resources: Array[WaveResource] = [
	preload("res://resources/wave_resources/advanced_wave.tres")
]

@onready var wave_spawner: WaveSpawner


func _ready() -> void:
	# Create and configure wave spawner
	wave_spawner = wave_spawner_scene.instantiate()
	add_child(wave_spawner)
	
	# Configure wave spawner
	wave_spawner.arena_time_manager = arena_time_manager
	wave_spawner.wave_resources = wave_resources
	
	# Connect to wave spawner signals if needed
	wave_spawner.enemy_spawned.connect(_on_enemy_spawned)


func on_timer_timeout():
	timer.start()	
	var enemy_data = enemy_table.pick_item() as EnemyData
	var enemy = generic_enemy_scene.instantiate() as GenericEnemy
	enemy.enemy_data = enemy_data
	
	var entities_layer = get_tree().get_first_node_in_group("entities_layer")
	entities_layer.add_child(enemy)
	enemy.global_position = get_spawn_position()
	
func on_arena_difficulty_increased(arena_difficulty: int):
	var time_off = (.1/12) * arena_difficulty
	time_off = min(time_off, .8)
	timer.wait_time = base_spawn_time - time_off
	
	if arena_difficulty == 4:
		enemy_table.add_item(goblin_enemy_data, 30)
	if arena_difficulty == 5:
		enemy_table.add_item(goblin_archer_data, 25)
	if arena_difficulty == 6:
		enemy_table.add_item(wizard_enemy_data, 20)

func _on_enemy_spawned(enemy: Node2D) -> void:
	# This can be used for additional logic when enemies are spawned
	# For example, tracking enemy counts, triggering events, etc.
	pass

