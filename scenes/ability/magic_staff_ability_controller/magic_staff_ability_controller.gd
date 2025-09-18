extends Node

const AOE_RADIUS = 80.0
const MAX_RANGE = 180.0

@onready var timer = $Timer

@export var fireball_scene: PackedScene
var base_damage: float = 6.0
var additional_damage_percent: float = 1.0
var base_wait_time: float
var cached_player_position: Vector2 = Vector2.ZERO
var explosion_count: int = 1
var aoe_radius: float = AOE_RADIUS

func _ready() -> void:
	base_wait_time = timer.wait_time
	timer.timeout.connect(on_timer_timeout)
	GameEvents.ability_upgrade_added.connect(on_ability_upgrade_added)
	GameEvents.player_position_updated.connect(on_player_position_updated)

func on_player_position_updated(player_position: Vector2) -> void:
	cached_player_position = player_position

func on_timer_timeout() -> void:
	if cached_player_position == Vector2.ZERO:
		return
		
	var enemies = get_tree().get_nodes_in_group("enemy")
	enemies = enemies.filter(func(enemy: Node2D): 
		return enemy.global_position.distance_squared_to(cached_player_position) < pow(MAX_RANGE, 2)
	)
	
	if enemies.size() == 0:
		return
	
	# Find enemy clusters for AOE targeting
	var target_positions: Array[Vector2] = []
	
	if explosion_count == 1:
		# Single fireball at enemy with most nearby enemies
		var best_position = _find_best_aoe_position(enemies)
		target_positions.append(best_position)
	else:
		# Multiple fireballs at different enemy clusters
		target_positions = _find_multiple_aoe_positions(enemies, explosion_count)
	
	# Spawn fireballs at target positions
	for position in target_positions:
		_create_fireball_at_position(position)

func _find_best_aoe_position(enemies: Array) -> Vector2:
	var best_position = Vector2.ZERO
	var max_enemies_hit = 0
	
	for enemy in enemies:
		var enemies_in_range = 0
		for other_enemy in enemies:
			if enemy.global_position.distance_to(other_enemy.global_position) <= aoe_radius:
				enemies_in_range += 1
		
		if enemies_in_range > max_enemies_hit:
			max_enemies_hit = enemies_in_range
			best_position = enemy.global_position
	
	return best_position if best_position != Vector2.ZERO else enemies[0].global_position

func _find_multiple_aoe_positions(enemies: Array, count: int) -> Array[Vector2]:
	var positions: Array[Vector2] = []
	var remaining_enemies = enemies.duplicate()
	
	for i in range(count):
		if remaining_enemies.is_empty():
			break
			
		var best_position = _find_best_aoe_position(remaining_enemies)
		positions.append(best_position)
		
		# Remove enemies that would be hit by this fireball
		remaining_enemies = remaining_enemies.filter(func(enemy: Node2D):
			return enemy.global_position.distance_to(best_position) > aoe_radius
		)
	
	return positions

func _create_fireball_at_position(position: Vector2) -> void:
	if fireball_scene == null:
		return
		
	var damage = base_damage * additional_damage_percent
	
	# Use event system for ability spawning
	GameEvents.emit_ability_spawn_requested(fireball_scene, position, damage, 0.0)

func on_ability_upgrade_added(upgrade: AbilityUpgrade, current_upgrades: Dictionary) -> void:
	if upgrade.id == "magic_staff_damage":
		additional_damage_percent = 1 + (current_upgrades["magic_staff_damage"]["quantity"] * 0.15)
	elif upgrade.id == "magic_staff_rate":
		var percent_reduction = current_upgrades["magic_staff_rate"]["quantity"] * 0.1
		timer.wait_time = base_wait_time * (1 - percent_reduction)
		timer.start()
	elif upgrade.id == "magic_staff_aoe":
		aoe_radius = AOE_RADIUS + (current_upgrades["magic_staff_aoe"]["quantity"] * 20.0)
	elif upgrade.id == "magic_staff_multicast":
		explosion_count = 1 + current_upgrades["magic_staff_multicast"]["quantity"]