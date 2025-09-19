extends Node

const MAX_RANGE = 150

@onready var timer = $Timer

@export var sword_ability: PackedScene
var base_damage = 5
var additional_damage_percent = 1
var base_wait_time 
var cached_player_position = Vector2.ZERO
var cached_enemies: Array[Node2D] = []

# Called when the node enters the scene tree for the first time.
func _ready():
	base_wait_time = timer.wait_time
	timer.timeout.connect(on_timer_timeout)
	GameEvents.ability_upgrade_added.connect(on_ability_upgrade_added)
	GameEvents.player_position_updated.connect(on_player_position_updated)
	GameEvents.enemies_near_player_updated.connect(on_enemies_near_player_updated)

func on_player_position_updated(player_position: Vector2):
	cached_player_position = player_position

func on_enemies_near_player_updated(enemies: Array[Node2D], player_position: Vector2):
	cached_enemies = enemies

func on_timer_timeout():
	if cached_player_position == Vector2.ZERO:
		return
		
	# Use cached enemy list instead of expensive tree lookup
	var enemies = cached_enemies.filter(func(enemy: Node2D): 
		return enemy.global_position.distance_squared_to(cached_player_position) < pow(MAX_RANGE, 2)
	)
	
	if enemies.size() == 0:
		return
	
	enemies.sort_custom(func(a: Node2D, b: Node2D):
		var a_distance = a.global_position.distance_squared_to(cached_player_position)
		var b_distance = b.global_position.distance_squared_to(cached_player_position)
		return a_distance < b_distance
	)
	
	var target_position = enemies[0].global_position
	target_position += Vector2.RIGHT.rotated(randf_range(0, TAU) * 4)
	
	var enemy_direction = enemies[0].global_position - target_position
	var rotation_angle = enemy_direction.angle()
	var damage = base_damage * additional_damage_percent
	
	# Use event system for spawning instead of direct layer access
	GameEvents.emit_ability_spawn_requested(sword_ability, target_position, damage, rotation_angle)

func on_ability_upgrade_added(upgrade: AbilityUpgrade, current_upgrades: Dictionary):
	if upgrade.id == "sword_rate":
		var percent_reduction = current_upgrades["sword_rate"]["quantity"] * .1
		timer.wait_time = base_wait_time * (1 - percent_reduction)
		timer.start()
	elif upgrade.id == "sword_damage":
		additional_damage_percent = 1 + (current_upgrades["sword_damage"]["quantity"] * .15)
	
