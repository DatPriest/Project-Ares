extends Node

@export var axe_ability_scene: PackedScene
@export var ability_stats: AbilityStats
@onready var timer: Timer = $Timer

func _ready() -> void:
	if ability_stats == null:
		ability_stats = preload("res://resources/upgrades/axe_stats.tres")
	
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
		
	var axe_instance: Node2D = axe_ability_scene.instantiate() as Node2D
	foreground.add_child(axe_instance)
	axe_instance.global_position = player.global_position
	axe_instance.hitbox_component.damage = ability_stats.current_damage
	
func on_ability_upgrade_added(upgrade: AbilityUpgrade, current_upgrades: Dictionary) -> void:
	if upgrade.id == "axe_damage":
		var quantity: int = current_upgrades["axe_damage"]["quantity"]
		ability_stats.apply_damage_upgrade(quantity)
	elif upgrade.id == "axe_rate":
		var quantity: int = current_upgrades["axe_rate"]["quantity"]
		ability_stats.apply_rate_upgrade(quantity)
		timer.wait_time = ability_stats.current_cooldown
		timer.start()
