extends Node

signal experience_vial_collected(number: float)
signal ability_upgrade_added(upgrade: AbilityUpgrade, current_upgrades: Dictionary)
signal enemy_killed(experience_amount: float)
signal player_damaged
signal resource_collected(resource: DropResource)

# Boss-specific events
signal boss_spawned(boss_data: EnemyData, boss_node: Node2D)
signal boss_defeated(boss_data: EnemyData, experience_amount: float)
signal boss_phase_changed(boss_data: EnemyData, new_phase: BossPhase, phase_index: int)
signal boss_special_attack_started(boss_data: EnemyData, attack_name: String)
signal boss_health_changed(boss_data: EnemyData, current_health: float, max_health: float)

# Player position and movement events
signal player_position_updated(player_position: Vector2)

# Entity spawning and management events  
signal entity_spawn_requested(entity_scene: PackedScene, spawn_position: Vector2)
signal projectile_spawn_requested(projectile_scene: PackedScene, spawn_position: Vector2, velocity: Vector2)
signal resource_drop_requested(material_scene: PackedScene, spawn_position: Vector2, resource: DropResource)

# UI and effect events
signal floating_text_requested(text: String, position: Vector2)
signal effect_spawn_requested(effect_scene: PackedScene, position: Vector2)
signal ability_spawn_requested(ability_scene: PackedScene, position: Vector2, damage: float, rotation_angle: float)

# Layer management events
signal entities_layer_ready(entities_layer: Node)
signal foreground_layer_ready(foreground_layer: Node)

# Multiplayer and Steam events
signal lobbies_found(lobby_list: Array)
signal player_spawned(player_data: Dictionary)
signal player_despawned(player_id: int)

func emit_experience_vial_collected(number: float):
	experience_vial_collected.emit(number)
	
func emit_ability_upgrade_added(upgrade: AbilityUpgrade, current_upgrades: Dictionary):
	ability_upgrade_added.emit(upgrade, current_upgrades)

func emit_enemy_killed(experience_amount: float):
	enemy_killed.emit(experience_amount)

func emit_resource_collected(resource: DropResource):
	resource_collected.emit(resource)

func emit_player_damaged():
	player_damaged.emit()

# Player position and movement event emitters
func emit_player_position_updated(player_position: Vector2):
	player_position_updated.emit(player_position)

# Entity spawning and management event emitters
func emit_entity_spawn_requested(entity_scene: PackedScene, spawn_position: Vector2):
	entity_spawn_requested.emit(entity_scene, spawn_position)

func emit_projectile_spawn_requested(projectile_scene: PackedScene, spawn_position: Vector2, velocity: Vector2):
	projectile_spawn_requested.emit(projectile_scene, spawn_position, velocity)

func emit_resource_drop_requested(material_scene: PackedScene, spawn_position: Vector2, resource: DropResource):
	resource_drop_requested.emit(material_scene, spawn_position, resource)

# UI and effect event emitters
func emit_floating_text_requested(text: String, position: Vector2):
	floating_text_requested.emit(text, position)

func emit_effect_spawn_requested(effect_scene: PackedScene, position: Vector2):
	effect_spawn_requested.emit(effect_scene, position)

func emit_ability_spawn_requested(ability_scene: PackedScene, position: Vector2, damage: float, rotation_angle: float):
	ability_spawn_requested.emit(ability_scene, position, damage, rotation_angle)

# Layer management event emitters
func emit_entities_layer_ready(entities_layer: Node):
	entities_layer_ready.emit(entities_layer)

func emit_foreground_layer_ready(foreground_layer: Node):
	foreground_layer_ready.emit(foreground_layer)

# Boss event emitters
func emit_boss_spawned(boss_data: EnemyData, boss_node: Node2D):
	boss_spawned.emit(boss_data, boss_node)

func emit_boss_defeated(boss_data: EnemyData, experience_amount: float):
	boss_defeated.emit(boss_data, experience_amount)

func emit_boss_phase_changed(boss_data: EnemyData, new_phase: BossPhase, phase_index: int):
	boss_phase_changed.emit(boss_data, new_phase, phase_index)

func emit_boss_special_attack_started(boss_data: EnemyData, attack_name: String):
	boss_special_attack_started.emit(boss_data, attack_name)

func emit_boss_health_changed(boss_data: EnemyData, current_health: float, max_health: float):
	boss_health_changed.emit(boss_data, current_health, max_health)

# Multiplayer event emitters
func emit_lobbies_found(lobby_list: Array):
	lobbies_found.emit(lobby_list)

func emit_player_spawned(player_data: Dictionary):
	player_spawned.emit(player_data)

func emit_player_despawned(player_id: int):
	player_despawned.emit(player_id)
