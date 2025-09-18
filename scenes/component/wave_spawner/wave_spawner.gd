extends Node
class_name WaveSpawner

signal enemy_spawned(enemy: Node2D)

const SPAWN_RADIUS = 380

@export var wave_resources: Array[WaveResource] = []
@export var arena_time_manager: Node

@onready var timer: Timer = $Timer

var current_wave: WaveResource
var current_wave_enemy_table: WeightedTable
var arena_difficulty: int = 0

func _ready() -> void:
	timer.timeout.connect(_on_timer_timeout)
	if arena_time_manager != null:
		arena_time_manager.arena_difficulty_increased.connect(_on_arena_difficulty_increased)
	
	# Start the first wave
	_update_current_wave()

func _update_current_wave() -> void:
	var time_elapsed: float = 0.0
	if arena_time_manager != null:
		time_elapsed = arena_time_manager.get_time_elapsed()
	
	# Find the appropriate wave for current time
	var best_wave: WaveResource = null
	for wave_resource in wave_resources:
		if time_elapsed >= wave_resource.start_time:
			if best_wave == null or wave_resource.start_time > best_wave.start_time:
				# Check if wave is still active (duration check)
				if wave_resource.duration < 0 or time_elapsed <= wave_resource.start_time + wave_resource.duration:
					best_wave = wave_resource
	
	if best_wave != current_wave:
		current_wave = best_wave
		_setup_wave()

func _setup_wave() -> void:
	if current_wave == null:
		timer.stop()
		return
	
	# Create weighted table for current wave
	current_wave_enemy_table = WeightedTable.new()
	
	for enemy_data in current_wave.enemy_types:
		if enemy_data.min_difficulty <= arena_difficulty:
			if enemy_data.max_difficulty < 0 or arena_difficulty <= enemy_data.max_difficulty:
				current_wave_enemy_table.add_item(enemy_data.enemy_scene, enemy_data.weight)
	
	# Calculate spawn interval based on difficulty scaling
	var spawn_interval: float = current_wave.base_spawn_interval
	for i in arena_difficulty:
		spawn_interval *= current_wave.spawn_interval_scaling
	spawn_interval = max(spawn_interval, current_wave.min_spawn_interval)
	
	timer.wait_time = spawn_interval
	timer.start()

func get_spawn_position() -> Vector2:
	var player: Node2D = get_tree().get_first_node_in_group("player")
	if player == null:
		return Vector2.ZERO
	
	var spawn_position: Vector2 = Vector2.ZERO
	var random_direction: Vector2 = Vector2.RIGHT.rotated(randf_range(0, TAU))
	
	for i in 4:
		spawn_position = player.global_position + (random_direction * SPAWN_RADIUS)
		var additional_check_offset: Vector2 = random_direction * 20
		
		var query_parameters: PhysicsRayQueryParameters2D = PhysicsRayQueryParameters2D.create(
			player.global_position, 
			spawn_position + additional_check_offset, 
			1
		)
		var result: Dictionary = get_tree().root.world_2d.direct_space_state.intersect_ray(query_parameters)
		
		if result.is_empty():
			break
		else:
			random_direction = random_direction.rotated(deg_to_rad(90))
	
	return spawn_position

func _on_timer_timeout() -> void:
	if current_wave_enemy_table == null or current_wave_enemy_table.items.is_empty():
		return
	
	var enemy_scene: PackedScene = current_wave_enemy_table.pick_item()
	if enemy_scene == null:
		return
	
	var enemy: Node2D = enemy_scene.instantiate() as Node2D
	if enemy == null:
		return
	
	var entities_layer: Node = get_tree().get_first_node_in_group("entities_layer")
	if entities_layer != null:
		entities_layer.add_child(enemy)
		enemy.global_position = get_spawn_position()
		enemy_spawned.emit(enemy)
	
	# Restart timer for next spawn
	timer.start()

func _on_arena_difficulty_increased(new_arena_difficulty: int) -> void:
	arena_difficulty = new_arena_difficulty
	_update_current_wave()
	_setup_wave()

func add_wave_resource(wave_resource: WaveResource) -> void:
	if wave_resource not in wave_resources:
		wave_resources.append(wave_resource)
		_update_current_wave()

func remove_wave_resource(wave_resource: WaveResource) -> void:
	wave_resources.erase(wave_resource)
	_update_current_wave()