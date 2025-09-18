extends Node

const SHIELD_RADIUS = 60.0

@onready var timer = $Timer

@export var shield_orb_scene: PackedScene
var base_damage: float = 3.0
var additional_damage_percent: float = 1.0
var base_wait_time: float
var cached_player_position: Vector2 = Vector2.ZERO
var orb_count: int = 3
var rotation_speed: float = 1.0
var active_orbs: Array[Node2D] = []

func _ready() -> void:
	base_wait_time = timer.wait_time
	timer.timeout.connect(on_timer_timeout)
	GameEvents.ability_upgrade_added.connect(on_ability_upgrade_added)
	GameEvents.player_position_updated.connect(on_player_position_updated)

func on_player_position_updated(player_position: Vector2) -> void:
	cached_player_position = player_position
	_update_orb_positions()

func on_timer_timeout() -> void:
	# Maintain shield orbs around player
	_manage_shield_orbs()

func _manage_shield_orbs() -> void:
	# Remove destroyed orbs from tracking
	active_orbs = active_orbs.filter(func(orb): return is_instance_valid(orb))
	
	# Add new orbs if needed
	while active_orbs.size() < orb_count:
		_create_new_orb()

func _create_new_orb() -> void:
	if shield_orb_scene == null or cached_player_position == Vector2.ZERO:
		return
		
	var damage = base_damage * additional_damage_percent
	
	# Use event system for ability spawning
	GameEvents.emit_ability_spawn_requested(shield_orb_scene, cached_player_position, damage, 0.0)

func _update_orb_positions() -> void:
	if cached_player_position == Vector2.ZERO or active_orbs.is_empty():
		return
	
	var angle_step = TAU / active_orbs.size()
	var current_time = Time.get_ticks_msec() / 1000.0
	
	for i in range(active_orbs.size()):
		var orb = active_orbs[i]
		if is_instance_valid(orb) and orb.has_method("update_position"):
			var angle = (angle_step * i) + (current_time * rotation_speed)
			var position = cached_player_position + Vector2.from_angle(angle) * SHIELD_RADIUS
			orb.update_position(position)

func _process(delta: float) -> void:
	_update_orb_positions()

func on_ability_upgrade_added(upgrade: AbilityUpgrade, current_upgrades: Dictionary) -> void:
	if upgrade.id == "shield_damage":
		additional_damage_percent = 1 + (current_upgrades["shield_damage"]["quantity"] * 0.15)
	elif upgrade.id == "shield_count":
		orb_count = 3 + current_upgrades["shield_count"]["quantity"]
	elif upgrade.id == "shield_speed":
		rotation_speed = 1.0 + (current_upgrades["shield_speed"]["quantity"] * 0.5)
	elif upgrade.id == "shield_size":
		# This would be handled by the orb itself, but we can track it here
		pass