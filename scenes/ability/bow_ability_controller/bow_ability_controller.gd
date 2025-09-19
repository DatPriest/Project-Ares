extends Node

const MAX_RANGE = 200.0

@onready var timer = $Timer

@export var arrow_projectile_scene: PackedScene
var base_damage: float = 4.0
var additional_damage_percent: float = 1.0
var base_wait_time: float
var cached_player_position: Vector2 = Vector2.ZERO
var cached_enemies: Array[Node2D] = []
var arrow_count: int = 1
var arrow_speed: float = 400.0
var has_flaming_arrows: bool = false

func _ready() -> void:
	base_wait_time = timer.wait_time
	timer.timeout.connect(on_timer_timeout)
	GameEvents.ability_upgrade_added.connect(on_ability_upgrade_added)
	GameEvents.player_position_updated.connect(on_player_position_updated)
	GameEvents.enemies_near_player_updated.connect(on_enemies_near_player_updated)

func on_player_position_updated(player_position: Vector2) -> void:
	cached_player_position = player_position

func on_enemies_near_player_updated(enemies: Array[Node2D], player_position: Vector2) -> void:
	cached_enemies = enemies

func on_timer_timeout() -> void:
	if cached_player_position == Vector2.ZERO:
		return
		
	# Use cached enemy list instead of expensive tree lookup
	var enemies = cached_enemies.filter(func(enemy: Node2D): 
		return enemy.global_position.distance_squared_to(cached_player_position) < pow(MAX_RANGE, 2)
	)
	
	if enemies.size() == 0:
		return
	
	# Sort enemies by distance
	enemies.sort_custom(func(a: Node2D, b: Node2D):
		var a_distance = a.global_position.distance_squared_to(cached_player_position)
		var b_distance = b.global_position.distance_squared_to(cached_player_position)
		return a_distance < b_distance
	)
	
	# Fire arrows at closest enemies
	var targets_to_hit = min(arrow_count, enemies.size())
	for i in range(targets_to_hit):
		_fire_arrow_at_enemy(enemies[i])

func _fire_arrow_at_enemy(enemy: Node2D) -> void:
	if arrow_projectile_scene == null:
		return
		
	var direction = (enemy.global_position - cached_player_position).normalized()
	var damage = base_damage * additional_damage_percent
	
	# Create arrow instance and configure it
	var arrow = arrow_projectile_scene.instantiate()
	arrow.global_position = cached_player_position
	arrow.set_direction_and_damage(direction, damage)
	
	# Add special properties for synergies
	if has_flaming_arrows:
		# This would set the arrow to explode on impact
		# For now, just increase damage as placeholder
		if arrow.has_method("set_explosive"):
			arrow.set_explosive(true)
	
	# Add to scene (using GameEvents if available, otherwise direct)
	if GameEvents.has_signal("projectile_spawn_requested"):
		var velocity = direction * arrow_speed
		GameEvents.emit_projectile_spawn_requested(arrow_projectile_scene, cached_player_position, velocity)
	else:
		# Fallback: add directly to scene
		get_tree().current_scene.add_child(arrow)

func on_ability_upgrade_added(upgrade: AbilityUpgrade, current_upgrades: Dictionary) -> void:
	if upgrade.id == "bow_damage":
		additional_damage_percent = 1 + (current_upgrades["bow_damage"]["quantity"] * 0.15)
	elif upgrade.id == "bow_rate":
		var percent_reduction = current_upgrades["bow_rate"]["quantity"] * 0.1
		timer.wait_time = base_wait_time * (1 - percent_reduction)
		timer.start()
	elif upgrade.id == "bow_multishot":
		arrow_count = 1 + current_upgrades["bow_multishot"]["quantity"]
	elif upgrade.id == "bow_speed":
		arrow_speed = 400.0 + (current_upgrades["bow_speed"]["quantity"] * 50.0)
	elif upgrade.id == "flaming_arrows":
		has_flaming_arrows = true
		# Flaming arrows deal 50% more base damage
		base_damage *= 1.5