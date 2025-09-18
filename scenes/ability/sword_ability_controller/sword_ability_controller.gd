extends Node

@export var sword_ability: PackedScene
@export var ability_stats: AbilityStats
@onready var timer: Timer = $Timer

func _ready() -> void:
	if ability_stats == null:
		ability_stats = preload("res://resources/upgrades/sword_stats.tres")
	
	# Initialize stats and timer
	ability_stats.reset_to_base()
	timer.wait_time = ability_stats.current_cooldown
	
	timer.timeout.connect(on_timer_timeout)
	GameEvents.ability_upgrade_added.connect(on_ability_upgrade_added)

func on_timer_timeout() -> void:
	var player: Node2D = get_tree().get_first_node_in_group("player") as Node2D
	if player == null:
		return
	var enemies: Array = get_tree().get_nodes_in_group("enemy")
	enemies = enemies.filter(func(enemy: Node2D): 
		return enemy.global_position.distance_squared_to(player.global_position) < pow(ability_stats.max_range, 2)
	)
	
	if enemies.size() == 0:
		return
	
	enemies.sort_custom(func(a: Node2D, b: Node2D):
		var a_distance: float = a.global_position.distance_squared_to(player.global_position)
		var b_distance: float = b.global_position.distance_squared_to(player.global_position)
		return a_distance < b_distance
	)
	
	var sword_instance: SwordAbility = sword_ability.instantiate() as SwordAbility
	var foreground_layer: Node = get_tree().get_first_node_in_group("foreground_layer")
	foreground_layer.add_child(sword_instance)
	sword_instance.hitbox_component.damage = ability_stats.current_damage
	
	sword_instance.global_position = enemies[0].global_position
	sword_instance.global_position += Vector2.RIGHT.rotated(randf_range(0, TAU) * 4)
	
	var enemy_direction: Vector2 = enemies[0].global_position - sword_instance.global_position
	sword_instance.rotation = enemy_direction.angle()

func on_ability_upgrade_added(upgrade: AbilityUpgrade, current_upgrades: Dictionary) -> void:
	if upgrade.id == "sword_rate":
		var quantity: int = current_upgrades["sword_rate"]["quantity"]
		ability_stats.apply_rate_upgrade(quantity)
		timer.wait_time = ability_stats.current_cooldown
		timer.start()
	elif upgrade.id == "sword_damage":
		var quantity: int = current_upgrades["sword_damage"]["quantity"]
		ability_stats.apply_damage_upgrade(quantity)
	

