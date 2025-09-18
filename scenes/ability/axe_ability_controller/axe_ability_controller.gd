extends Node

@export var base_damage = 5
@export var axe_ability_scene: PackedScene
@onready var timer = $Timer

var additional_damage_percent = 1
var base_wait_time 
var cached_player_position = Vector2.ZERO

func _ready():
	base_wait_time = timer.wait_time
	timer.timeout.connect(on_timer_timeout)
	GameEvents.ability_upgrade_added.connect(on_ability_upgrade_added)
	GameEvents.player_position_updated.connect(on_player_position_updated)

func on_player_position_updated(player_position: Vector2):
	cached_player_position = player_position

func on_timer_timeout():
	if cached_player_position == Vector2.ZERO:
		return
		
	var damage = base_damage * additional_damage_percent
	
	# Use event system for ability spawning instead of direct layer access
	GameEvents.emit_ability_spawn_requested(axe_ability_scene, cached_player_position, damage, 0.0)
	
func on_ability_upgrade_added(upgrade: AbilityUpgrade, current_upgrades: Dictionary):
	if upgrade.id == "axe_damage":
		additional_damage_percent = 1 + (current_upgrades["axe_damage"]["quantity"] * .1)
	elif upgrade.id == "axe_rate":
		var percent_reduction = current_upgrades["axe_rate"]["quantity"] * .1
		timer.wait_time = base_wait_time * (1 - percent_reduction)
		timer.start()
