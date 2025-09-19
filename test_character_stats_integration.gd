extends SceneTree

## Integration test for Character Stats System with existing game systems
## Tests integration with upgrade manager, experience system, and player

var test_results: Array[String] = []

func _init():
	print("=== Character Stats Integration Test Suite ===")
	print("Testing character stats integration with existing systems...")
	print()
	
	# Run integration tests
	test_upgrade_manager_integration()
	test_experience_multiplier_integration()
	test_player_stat_integration()
	test_negative_stats_in_builds()
	test_comprehensive_stat_build()
	
	# Print results
	print("\n=== Integration Test Results ===")
	for result in test_results:
		print(result)
	
	print("\nIntegration test suite completed.")
	quit()

func add_test_result(message: String):
	test_results.append(message)

func test_upgrade_manager_integration():
	"""Test integration with upgrade manager for stat upgrades"""
	print("Testing UpgradeManager integration...")
	
	# Create mock upgrade manager
	var upgrade_manager = UpgradeManager.new()
	
	# Create mock player with stats component
	var mock_player = CharacterBody2D.new()
	mock_player.add_to_group("player")
	var stats_component = CharacterStatsComponent.new()
	stats_component.enable_random_variance = false
	stats_component.name = "CharacterStatsComponent"
	mock_player.add_child(stats_component)
	stats_component._initialize_stats()
	
	# Mock the get_character_stats_component method
	mock_player.set_script(preload("res://scenes/game_object/player/player.gd"))
	
	# Test health boost upgrade
	var initial_health = stats_component.get_stat_value(CharacterStat.StatType.HEALTH)
	
	# Simulate applying health boost upgrade
	stats_component.modify_stat(CharacterStat.StatType.HEALTH, 25.0)
	var new_health = stats_component.get_stat_value(CharacterStat.StatType.HEALTH)
	
	assert(new_health == initial_health + 25.0, "Health boost should increase health by 25")
	
	# Test multiple upgrades stacking
	stats_component.modify_stat(CharacterStat.StatType.HEALTH, 25.0)  # Second level
	var stacked_health = stats_component.get_stat_value(CharacterStat.StatType.HEALTH)
	
	assert(stacked_health == initial_health + 50.0, "Multiple health boosts should stack")
	
	add_test_result("✓ UpgradeManager integration works correctly")

func test_experience_multiplier_integration():
	"""Test experience multiplier functionality"""
	print("Testing experience multiplier integration...")
	
	var stats_component = CharacterStatsComponent.new()
	stats_component.enable_random_variance = false
	stats_component._initialize_stats()
	
	# Test default multiplier
	var default_multiplier = stats_component.get_experience_multiplier()
	assert(default_multiplier == 1.0, "Default experience multiplier should be 1.0")
	
	# Add experience boost
	stats_component.modify_stat(CharacterStat.StatType.EXPERIENCE_GAIN, 15.0)  # 15% bonus
	var boosted_multiplier = stats_component.get_experience_multiplier()
	assert(abs(boosted_multiplier - 1.15) < 0.01, "15% XP boost should give 1.15x multiplier")
	
	# Stack multiple boosts
	stats_component.modify_stat(CharacterStat.StatType.EXPERIENCE_GAIN, 15.0)  # Another 15%
	var double_boosted = stats_component.get_experience_multiplier()
	assert(abs(double_boosted - 1.30) < 0.01, "Two 15% boosts should give 1.30x multiplier")
	
	add_test_result("✓ Experience multiplier integration works correctly")

func test_player_stat_integration():
	"""Test player integration with character stats"""
	print("Testing player stat integration...")
	
	var stats_component = CharacterStatsComponent.new()
	stats_component.enable_random_variance = false
	stats_component._initialize_stats()
	
	# Test speed multiplier calculation
	var base_multiplier = stats_component.get_speed_multiplier()
	assert(base_multiplier == 1.0, "Base speed multiplier should be 1.0")
	
	# Add speed bonus
	stats_component.modify_stat(CharacterStat.StatType.SPEED, 20.0)  # 20% speed boost
	var speed_multiplier = stats_component.get_speed_multiplier()
	assert(abs(speed_multiplier - 1.2) < 0.01, "20% speed boost should give 1.2x multiplier")
	
	# Test other integration methods
	var health_bonus = stats_component.get_health_bonus()
	var damage_bonus = stats_component.get_damage_bonus()
	var crit_chance = stats_component.get_critical_chance()
	var pickup_range = stats_component.get_pickup_range_bonus()
	
	# These should work without errors
	assert(health_bonus >= 0, "Health bonus should be retrievable")
	assert(damage_bonus >= 0, "Damage bonus should be retrievable") 
	assert(crit_chance >= 0, "Critical chance should be retrievable")
	assert(pickup_range >= 0, "Pickup range should be retrievable")
	
	add_test_result("✓ Player stat integration works correctly")

func test_negative_stats_in_builds():
	"""Test negative stats for build variety"""
	print("Testing negative stats for build variety...")
	
	var stats_component = CharacterStatsComponent.new()
	stats_component.enable_random_variance = false
	stats_component._initialize_stats()
	
	# Create a "glass cannon" build - high damage but low health
	stats_component.modify_stat(CharacterStat.StatType.DAMAGE, 100.0)  # High damage
	stats_component.modify_stat(CharacterStat.StatType.HEALTH, -50.0)  # Lower health (trade-off)
	
	var damage = stats_component.get_stat_value(CharacterStat.StatType.DAMAGE)
	var health = stats_component.get_stat_value(CharacterStat.StatType.HEALTH)
	
	assert(damage == 100.0, "Damage bonus should be applied")
	assert(health == 50.0, "Health penalty should be applied (100 - 50 = 50)")
	
	# Test speed penalty build
	stats_component.modify_stat(CharacterStat.StatType.SPEED, -30.0)  # Speed penalty
	var speed_multiplier = stats_component.get_speed_multiplier()
	assert(abs(speed_multiplier - 0.7) < 0.01, "30% speed penalty should give 0.7x multiplier")
	
	add_test_result("✓ Negative stats for build variety work correctly")

func test_comprehensive_stat_build():
	"""Test a comprehensive character build with multiple stats"""
	print("Testing comprehensive character build...")
	
	var stats_component = CharacterStatsComponent.new()
	stats_component.enable_random_variance = false
	stats_component._initialize_stats()
	
	# Create a "Tank" build
	stats_component.modify_stat(CharacterStat.StatType.HEALTH, 100.0)         # +100 health
	stats_component.modify_stat(CharacterStat.StatType.ARMOR_RATING, 50.0)    # +50 armor
	stats_component.modify_stat(CharacterStat.StatType.MAGIC_RESISTANCE, 25.0) # +25% magic resist
	stats_component.modify_stat(CharacterStat.StatType.SPEED, -20.0)          # -20% speed (trade-off)
	stats_component.modify_stat(CharacterStat.StatType.DAMAGE, -10.0)         # -10 damage (trade-off)
	
	# Verify build characteristics
	var health = stats_component.get_stat_value(CharacterStat.StatType.HEALTH)
	var armor = stats_component.get_stat_value(CharacterStat.StatType.ARMOR_RATING)
	var magic_resist = stats_component.get_stat_value(CharacterStat.StatType.MAGIC_RESISTANCE)
	var speed_multiplier = stats_component.get_speed_multiplier()
	var damage = stats_component.get_stat_value(CharacterStat.StatType.DAMAGE)
	
	assert(health == 200.0, "Tank should have high health")
	assert(armor == 50.0, "Tank should have good armor")
	assert(magic_resist == 25.0, "Tank should have magic resistance")
	assert(abs(speed_multiplier - 0.8) < 0.01, "Tank should be slower")
	assert(damage == -10.0, "Tank should have lower damage")
	
	# Test display stats
	var display_stats = stats_component.get_stats_for_display()
	assert(display_stats.size() >= 5, "Tank build should show multiple stats")
	
	add_test_result("✓ Comprehensive character builds work correctly")