extends Node

@export var base_damage = 2.5
@export var double_sword_ability_scene: PackedScene
@onready var timer = $Timer

var additional_damage_percent = 1
var base_wait_time 

func _ready():
	base_wait_time = timer.wait_time
	timer.timeout.connect(on_timer_timeout)
	GameEvents.ability_upgrade_added.connect(on_ability_upgrade_added)

func on_timer_timeout():
	var player = get_tree().get_first_node_in_group("player") as Node2D
	if player == null:
		return
		
	var foreground = get_tree().get_first_node_in_group("foreground_layer") as Node2D
	if foreground == null: 
		return
		
	var double_sword_instance = double_sword_ability_scene.instantiate() as Node2D
	foreground.add_child(double_sword_instance)
	double_sword_instance.global_position = player.global_position
	double_sword_instance.hitbox_component.damage = base_damage * additional_damage_percent
	
func on_ability_upgrade_added(upgrade: AbilityUpgrade, current_upgrades: Dictionary):
	if upgrade.id == "double_sword_damage":
		additional_damage_percent = 1 + (current_upgrades["double_sword_damage"]["quantity"] * .1)
	elif upgrade.id == "double_sword_rate":
		var percent_reduction = current_upgrades["double_sword_rate"]["quantity"] * .1
		timer.wait_time = base_wait_time * (1 - percent_reduction)
		timer.start()
