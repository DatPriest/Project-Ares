extends Node

const SPAWN_RADIUS = 380

@export var basic_enemy_scene: PackedScene
@export var wizard_enemy_scene: PackedScene
@export var goblin_enemy_scene: PackedScene
@export var goblin_archer_scene: PackedScene
@export var arena_time_manager: Node

@onready var timer = $Timer

var base_spawn_time = 0
var enemy_table = WeightedTable.new()
var cached_player_position = Vector2.ZERO

func _ready():
	enemy_table.add_item(basic_enemy_scene, 10)
	base_spawn_time = timer.wait_time
	timer.timeout.connect(on_timer_timeout)
	arena_time_manager.arena_difficulty_increased.connect(on_arena_difficulty_increased)
	GameEvents.player_position_updated.connect(on_player_position_updated)

func on_player_position_updated(player_position: Vector2):
	cached_player_position = player_position

func get_spawn_position():
	if cached_player_position == Vector2.ZERO:
		return Vector2.ZERO
	
	var spawn_position = Vector2.ZERO
	var random_direction = Vector2.RIGHT.rotated(randf_range(0, TAU))
	
	for i in 4:
		spawn_position = cached_player_position + (random_direction * SPAWN_RADIUS)
		var additional_check_offset = random_direction * 20
		
		var query_parameters = PhysicsRayQueryParameters2D.create(cached_player_position, spawn_position + additional_check_offset, 1)
		var result = get_tree().root.world_2d.direct_space_state.intersect_ray(query_parameters)
		
		if result.is_empty():
			break
		else:
			random_direction = random_direction.rotated(deg_to_rad(90))
	return spawn_position 

func on_timer_timeout():
	timer.start()	
	var enemy_scene = enemy_table.pick_item()
	var spawn_position = get_spawn_position()
	
	# Use event system for enemy spawning instead of direct layer access
	GameEvents.emit_entity_spawn_requested(enemy_scene, spawn_position)
	
func on_arena_difficulty_increased(arena_difficulty: int):
	var time_off = (.1/12) * arena_difficulty
	time_off = min(time_off, .8	)
	timer.wait_time = base_spawn_time - time_off
	
	if arena_difficulty == 6:
		enemy_table.add_item(wizard_enemy_scene, 20)
	if arena_difficulty == 4:
		enemy_table.add_item(goblin_enemy_scene, 30)
	if arena_difficulty == 5:
		enemy_table.add_item(goblin_archer_scene, 25)
