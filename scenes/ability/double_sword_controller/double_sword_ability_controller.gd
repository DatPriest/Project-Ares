extends Node

@export var double_sword_ability_scene: PackedScene
@export var ability_stats: AbilityStats
@onready var timer: Timer = $Timer

func _ready() -> void:
	if ability_stats == null:
		ability_stats = preload("res://resources/upgrades/double_sword_stats.tres")
	
	# Initialize stats and timer
	ability_stats.reset_to_base()
	timer.wait_time = ability_stats.current_cooldown
	
	timer.timeout.connect(on_timer_timeout)
	GameEvents.ability_upgrade_added.connect(on_ability_upgrade_added)

func on_timer_timeout() -> void:
	var player: Node2D = get_tree().get_first_node_in_group("player") as Node2D
	if player == null:
		return
		
	var foreground: Node2D = get_tree().get_first_node_in_group("foreground_layer") as Node2D
	if foreground == null: 
		return
		
	var double_sword_instance: Node2D = double_sword_ability_scene.instantiate() as Node2D
	foreground.add_child(double_sword_instance)
	double_sword_instance.global_position = player.global_position
	double_sword_instance.hitbox_component.damage = ability_stats.current_damage
	
func on_ability_upgrade_added(upgrade: AbilityUpgrade, current_upgrades: Dictionary) -> void:
	if upgrade.id == "double_sword_damage":
		var quantity: int = current_upgrades["double_sword_damage"]["quantity"]
		ability_stats.apply_damage_upgrade(quantity)
	elif upgrade.id == "double_sword_rate":
		var quantity: int = current_upgrades["double_sword_rate"]["quantity"]
		ability_stats.apply_rate_upgrade(quantity)
		timer.wait_time = ability_stats.current_cooldown
		timer.start()
