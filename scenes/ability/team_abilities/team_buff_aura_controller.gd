extends Node

const BUFF_RADIUS = 150.0

@onready var area_2d: Area2D = $Area2D
var damage_buff_percent: float = 0.1  # 10% base damage buff
var cached_player_position: Vector2 = Vector2.ZERO
var cached_main_player: Node2D = null
var buffed_players: Array[Node] = []

func _ready() -> void:
	GameEvents.ability_upgrade_added.connect(on_ability_upgrade_added)
	GameEvents.player_position_updated.connect(on_player_position_updated)
	
	# Cache main player reference to avoid repeated tree lookups
	cached_main_player = get_tree().get_first_node_in_group("player")
	
	if area_2d:
		area_2d.body_entered.connect(_on_player_entered_aura)
		area_2d.body_exited.connect(_on_player_exited_aura)
	
	# Update aura position continuously
	set_process(true)

func _process(delta: float) -> void:
	if cached_player_position != Vector2.ZERO:
		global_position = cached_player_position

func on_player_position_updated(player_position: Vector2) -> void:
	cached_player_position = player_position

func _on_player_entered_aura(body: Node2D) -> void:
	if _is_teammate(body) and body not in buffed_players:
		buffed_players.append(body)
		_apply_buff_to_player(body, true)

func _on_player_exited_aura(body: Node2D) -> void:
	if body in buffed_players:
		buffed_players.erase(body)
		_apply_buff_to_player(body, false)

func _is_teammate(body: Node2D) -> bool:
	# Check if the body is another player (not the owner of this aura)
	return body.is_in_group("player") and body != cached_main_player

func _apply_buff_to_player(player: Node, apply: bool) -> void:
	# This would need to integrate with the player's damage system
	# For now, we'll use a signal-based approach
	if apply:
		# Apply damage buff
		if player.has_method("apply_damage_buff"):
			player.apply_damage_buff(damage_buff_percent)
		print("Applied team buff to player: ", player.name)
	else:
		# Remove damage buff
		if player.has_method("remove_damage_buff"):
			player.remove_damage_buff(damage_buff_percent)
		print("Removed team buff from player: ", player.name)

func on_ability_upgrade_added(upgrade: AbilityUpgrade, current_upgrades: Dictionary) -> void:
	if upgrade.id == "team_buff_aura":
		# Increase buff strength with each upgrade
		damage_buff_percent = 0.1 + (current_upgrades["team_buff_aura"]["quantity"] * 0.05)
		
		# Re-apply buffs to current players
		for player in buffed_players:
			_apply_buff_to_player(player, false)  # Remove old buff
			_apply_buff_to_player(player, true)   # Apply new buff