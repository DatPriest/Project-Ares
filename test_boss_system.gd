extends Node

# Simple test script to validate the boss system
# This script can be run in the Godot editor to test boss functionality

func _ready():
	print("Testing Boss System...")
	test_boss_data_resource()
	test_boss_phase_resource()
	test_boss_events()
	print("Boss system tests completed!")

func test_boss_data_resource():
	print("Testing BossData resource...")
	
	# Load the boss data resource
	var boss_data = load("res://resources/enemy_data/boss_goblin_king_data.tres") as EnemyData
	
	assert(boss_data != null, "Boss data resource should load successfully")
	assert(boss_data.is_boss == true, "Boss data should be marked as boss")
	assert(boss_data.behavior_type == "Boss", "Boss behavior type should be 'Boss'")
	assert(boss_data.boss_phases.size() > 0, "Boss should have at least one phase")
	assert(boss_data.special_attacks.size() > 0, "Boss should have special attacks")
	assert(boss_data.max_health > 50.0, "Boss should have high health")
	assert(boss_data.xp_reward > 10.0, "Boss should give good XP reward")
	
	print("✓ BossData resource tests passed")

func test_boss_phase_resource():
	print("Testing BossPhase resource...")
	
	var boss_data = load("res://resources/enemy_data/boss_goblin_king_data.tres") as EnemyData
	if boss_data == null or boss_data.boss_phases.size() == 0:
		print("✗ Cannot test boss phases - no boss data")
		return
	
	var phase = boss_data.boss_phases[0] as BossPhase
	assert(phase != null, "Boss phase should be valid")
	assert(phase.name != "", "Boss phase should have a name")
	assert(phase.health_threshold > 0.0 and phase.health_threshold <= 1.0, "Health threshold should be between 0 and 1")
	assert(phase.movement_speed_multiplier > 0.0, "Movement speed multiplier should be positive")
	assert(phase.attack_speed_multiplier > 0.0, "Attack speed multiplier should be positive")
	
	print("✓ BossPhase resource tests passed")

func test_boss_events():
	print("Testing Boss GameEvents...")
	
	# Test that boss events exist and can be connected
	var events_connected = 0
	
	if GameEvents.has_signal("boss_spawned"):
		GameEvents.boss_spawned.connect(_on_test_boss_spawned)
		events_connected += 1
	
	if GameEvents.has_signal("boss_defeated"):
		GameEvents.boss_defeated.connect(_on_test_boss_defeated)
		events_connected += 1
	
	if GameEvents.has_signal("boss_phase_changed"):
		GameEvents.boss_phase_changed.connect(_on_test_boss_phase_changed)
		events_connected += 1
	
	if GameEvents.has_signal("boss_special_attack_started"):
		GameEvents.boss_special_attack_started.connect(_on_test_boss_special_attack)
		events_connected += 1
	
	if GameEvents.has_signal("boss_health_changed"):
		GameEvents.boss_health_changed.connect(_on_test_boss_health_changed)
		events_connected += 1
	
	assert(events_connected == 5, "All boss events should be available")
	
	print("✓ Boss GameEvents tests passed (", events_connected, " events connected)")

# Test event handlers
func _on_test_boss_spawned(boss_data: EnemyData, boss_node: Node2D):
	print("Boss spawned event received: ", boss_data.name)

func _on_test_boss_defeated(boss_data: EnemyData, experience_amount: float):
	print("Boss defeated event received: ", boss_data.name, " (XP: ", experience_amount, ")")

func _on_test_boss_phase_changed(boss_data: EnemyData, new_phase: BossPhase, phase_index: int):
	print("Boss phase changed event received: ", new_phase.name, " (Index: ", phase_index, ")")

func _on_test_boss_special_attack(boss_data: EnemyData, attack_name: String):
	print("Boss special attack event received: ", attack_name)

func _on_test_boss_health_changed(boss_data: EnemyData, current_health: float, max_health: float):
	print("Boss health changed event received: ", current_health, "/", max_health)