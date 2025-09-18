extends Node

const SPAWN_RADIUS = 380

@export var generic_enemy_scene: PackedScene
@export var arena_time_manager: Node

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

func get_spawn_position():
	var player = get_tree().get_first_node_in_group("player")
	if player == null:
		return Vector2.ZERO
	
	var spawn_position = Vector2.ZERO
	var random_direction = Vector2.RIGHT.rotated(randf_range(0, TAU))
	
	for i in 4:
		spawn_position = player.global_position + (random_direction * SPAWN_RADIUS)
		var additional_check_offset = random_direction * 20
		
		var query_parameters = PhysicsRayQueryParameters2D.create(player.global_position, spawn_position + additional_check_offset, 1)
		var result = get_tree().root.world_2d.direct_space_state.intersect_ray(query_parameters)
		
		if result.is_empty():
			break
		else:
			random_direction = random_direction.rotated(deg_to_rad(90))
	return spawn_position 

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
