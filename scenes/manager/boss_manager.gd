extends Node
class_name BossManager

@export var generic_enemy_scene: PackedScene
@export var boss_spawn_times: Array[float] = [120.0, 300.0, 600.0]  # Times in seconds when bosses spawn
@export var boss_data_resources: Array[EnemyData] = []

@onready var arena_time_manager: Node

var spawned_bosses: Array[float] = []
var current_boss_count: int = 0

func _ready():
	# Find arena time manager
	arena_time_manager = get_tree().get_first_node_in_group("arena_time_manager")
	if arena_time_manager == null:
		push_warning("BossManager: Could not find arena_time_manager")
		return
	
	# Connect to boss defeat events to track boss count
	GameEvents.boss_defeated.connect(_on_boss_defeated)
	GameEvents.boss_spawned.connect(_on_boss_spawned)

func _process(_delta):
	if arena_time_manager == null:
		return
	
	var current_time = arena_time_manager.get_time_elapsed()
	
	# Check if it's time to spawn a boss
	for spawn_time in boss_spawn_times:
		if current_time >= spawn_time and not spawned_bosses.has(spawn_time):
			_spawn_boss_at_time(spawn_time)
			spawned_bosses.append(spawn_time)

func _spawn_boss_at_time(spawn_time: float):
	if boss_data_resources.size() == 0:
		push_warning("BossManager: No boss data resources configured")
		return
	
	if generic_enemy_scene == null:
		push_warning("BossManager: Generic enemy scene not configured")
		return
	
	# Don't spawn if there's already a boss active (optional restriction)
	if current_boss_count > 0:
		print("BossManager: Boss already active, skipping spawn")
		return
	
	# Select boss based on spawn time (simple progression)
	var boss_index = 0
	for i in range(boss_spawn_times.size()):
		if boss_spawn_times[i] == spawn_time:
			boss_index = min(i, boss_data_resources.size() - 1)
			break
	
	var boss_data = boss_data_resources[boss_index]
	
	# Get spawn position (similar to enemy manager but with more space)
	var spawn_position = _get_boss_spawn_position()
	
	# Create boss instance
	var boss_instance = generic_enemy_scene.instantiate()
	boss_instance.enemy_data = boss_data
	boss_instance.global_position = spawn_position
	
	# Add to entities layer via GameEvents
	GameEvents.emit_entity_spawn_requested(generic_enemy_scene, spawn_position)
	
	print("BossManager: Spawning boss '", boss_data.name, "' at time ", spawn_time)

func _get_boss_spawn_position() -> Vector2:
	var player = get_tree().get_first_node_in_group("player") as Node2D
	if player == null:
		return Vector2.ZERO
	
	# Spawn boss further away than regular enemies
	var boss_spawn_radius = 500.0
	var spawn_position = Vector2.ZERO
	var random_direction = Vector2.RIGHT.rotated(randf_range(0, TAU))
	
	# Try to find a clear spawn position
	for i in 4:
		spawn_position = player.global_position + (random_direction * boss_spawn_radius)
		var additional_check_offset = random_direction * 30
		
		var query_parameters = PhysicsRayQueryParameters2D.create(player.global_position, spawn_position + additional_check_offset, 1)
		var result = get_tree().root.world_2d.direct_space_state.intersect_ray(query_parameters)
		
		if result.is_empty():
			break
		else:
			random_direction = random_direction.rotated(deg_to_rad(90))
	
	return spawn_position

func _on_boss_spawned(boss_data: EnemyData, boss_node: Node2D):
	current_boss_count += 1
	print("BossManager: Boss spawned - ", boss_data.name, " (Active bosses: ", current_boss_count, ")")

func _on_boss_defeated(boss_data: EnemyData, experience_amount: float):
	current_boss_count = max(0, current_boss_count - 1)
	print("BossManager: Boss defeated - ", boss_data.name, " (Active bosses: ", current_boss_count, ")")

# Public function to manually trigger boss spawn (for testing or special events)
func spawn_boss_manually(boss_data: EnemyData, position: Vector2 = Vector2.ZERO):
	if generic_enemy_scene == null:
		return
	
	var spawn_pos = position if position != Vector2.ZERO else _get_boss_spawn_position()
	
	var boss_instance = generic_enemy_scene.instantiate()
	boss_instance.enemy_data = boss_data
	boss_instance.global_position = spawn_pos
	
	GameEvents.emit_entity_spawn_requested(generic_enemy_scene, spawn_pos)