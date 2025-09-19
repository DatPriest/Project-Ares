extends SceneTree

## Test suite for Character Stats System
## Validates stat creation, modification, and integration

var test_results: Array[String] = []

func _init():
	print("=== Character Stats System Test Suite ===")
	print("Testing character stat functionality...")
	print()
	
	# Run all tests
	test_character_stat_creation()
	test_character_stat_modifiers()
	test_character_stat_randomization()
	test_character_stats_component()
	test_stats_display_integration()
	test_negative_stats_handling()
	test_stat_constraints()
	
	# Print results
	print("\n=== Test Results ===")
	for result in test_results:
		print(result)
	
	print("\nTest suite completed.")
	quit()

func add_test_result(message: String):
	test_results.append(message)

func test_character_stat_creation():
	"""Test CharacterStat creation and basic properties"""
	print("Testing CharacterStat creation...")
	
	var health_stat = CharacterStat.new(CharacterStat.StatType.HEALTH, 100.0)
	assert(health_stat.stat_type == CharacterStat.StatType.HEALTH, "Stat type should be set correctly")
	assert(health_stat.base_value == 100.0, "Base value should be set correctly")
	assert(health_stat.current_value == 100.0, "Current value should equal base value initially")
	assert(health_stat.display_name == "Health", "Display name should be set automatically")
	
	# Test percentage stats
	var crit_stat = CharacterStat.new(CharacterStat.StatType.CRITICAL_CHANCE, 15.0)
	assert(crit_stat.is_percentage == true, "Critical chance should be a percentage stat")
	assert(crit_stat.display_name == "Crit Chance", "Display name should be set correctly")
	
	add_test_result("✓ CharacterStat creation and properties work correctly")

func test_character_stat_modifiers():
	"""Test stat modification functionality"""
	print("Testing CharacterStat modifiers...")
	
	var damage_stat = CharacterStat.new(CharacterStat.StatType.DAMAGE, 50.0)
	
	# Test additive modifier
	damage_stat.apply_modifier(25.0, true)
	assert(damage_stat.current_value == 75.0, "Additive modifier should work correctly")
	
	# Test multiplicative modifier
	damage_stat.reset_to_base()
	damage_stat.apply_modifier(1.5, false)  # 50 * 1.5 = 75
	assert(damage_stat.current_value == 75.0, "Multiplicative modifier should work correctly")
	
	# Test negative modifiers
	damage_stat.reset_to_base()
	damage_stat.apply_modifier(-10.0, true)
	assert(damage_stat.current_value == 40.0, "Negative additive modifier should work correctly")
	
	add_test_result("✓ CharacterStat modifiers work correctly")

func test_character_stat_randomization():
	"""Test stat randomization and variance"""
	print("Testing CharacterStat randomization...")
	
	var values: Array[float] = []
	var luck_stat = CharacterStat.new(CharacterStat.StatType.LUCK, 50.0)
	
	# Generate multiple values to check variance
	for i in range(50):
		luck_stat.current_value = luck_stat.base_value  # Reset
		luck_stat.apply_random_variance()
		values.append(luck_stat.current_value)
	
	# Check that we got different values
	var unique_values = {}
	for value in values:
		unique_values[value] = true
	
	assert(unique_values.size() > 1, "Random variance should produce different values")
	
	# Check all values are within expected range
	var within_range = true
	for value in values:
		if value < (luck_stat.base_value - luck_stat.random_variance) or value > (luck_stat.base_value + luck_stat.random_variance):
			within_range = false
			break
	
	assert(within_range, "All random values should be within variance range")
	
	add_test_result("✓ CharacterStat randomization produces expected variance")

func test_character_stats_component():
	"""Test CharacterStatsComponent functionality"""
	print("Testing CharacterStatsComponent...")
	
	var stats_component = CharacterStatsComponent.new()
	stats_component.enable_random_variance = false  # Disable for predictable testing
	
	# Test stat initialization
	stats_component._initialize_stats()
	assert(stats_component.get_stat_value(CharacterStat.StatType.HEALTH) == 100.0, "Default health should be 100")
	assert(stats_component.get_stat_value(CharacterStat.StatType.CRITICAL_CHANCE) == 5.0, "Default crit chance should be 5%")
	
	# Test stat modification
	stats_component.modify_stat(CharacterStat.StatType.DAMAGE, 25.0)
	assert(stats_component.get_stat_value(CharacterStat.StatType.DAMAGE) == 25.0, "Damage modifier should be applied")
	
	# Test integration methods
	var speed_multiplier = stats_component.get_speed_multiplier()
	assert(speed_multiplier == 1.0, "Speed multiplier should be 1.0 with no speed bonus")
	
	stats_component.modify_stat(CharacterStat.StatType.SPEED, 20.0)  # 20% speed bonus
	speed_multiplier = stats_component.get_speed_multiplier()
	assert(abs(speed_multiplier - 1.2) < 0.01, "Speed multiplier should be 1.2 with 20% bonus")
	
	add_test_result("✓ CharacterStatsComponent functionality works correctly")

func test_stats_display_integration():
	"""Test stats display functionality"""
	print("Testing stats display integration...")
	
	var stats_component = CharacterStatsComponent.new()
	stats_component.enable_random_variance = false
	stats_component._initialize_stats()
	
	# Add some non-zero stats for display
	stats_component.modify_stat(CharacterStat.StatType.DAMAGE, 35.0)
	stats_component.modify_stat(CharacterStat.StatType.LUCK, 15.0)
	
	var display_stats = stats_component.get_stats_for_display()
	assert(display_stats.size() > 0, "Should have stats to display")
	
	# Check that core stats are included
	var has_health = false
	var has_damage = false
	for stat in display_stats:
		if stat.stat_type == CharacterStat.StatType.HEALTH:
			has_health = true
		elif stat.stat_type == CharacterStat.StatType.DAMAGE:
			has_damage = true
	
	assert(has_health, "Health should always be displayed as core stat")
	assert(has_damage, "Damage should be displayed when non-zero")
	
	add_test_result("✓ Stats display integration works correctly")

func test_negative_stats_handling():
	"""Test handling of negative stats"""
	print("Testing negative stats handling...")
	
	var speed_stat = CharacterStat.new(CharacterStat.StatType.SPEED, 10.0)
	
	# Apply negative modifier
	speed_stat.apply_modifier(-25.0, true)
	assert(speed_stat.current_value == -15.0, "Negative stats should be allowed")
	assert(speed_stat.get_display_color() == speed_stat.negative_color, "Negative stats should show negative color")
	
	# Test display formatting
	var display_value = speed_stat.get_display_value()
	assert(display_value.begins_with("-"), "Negative stats should display with minus sign")
	
	add_test_result("✓ Negative stats handling works correctly")

func test_stat_constraints():
	"""Test stat value constraints and limits"""
	print("Testing stat constraints...")
	
	var health_stat = CharacterStat.new(CharacterStat.StatType.HEALTH, 100.0)
	
	# Test minimum constraint (health should not go below 1)
	health_stat.apply_modifier(-150.0, true)
	assert(health_stat.current_value >= health_stat.min_value, "Health should respect minimum value")
	assert(health_stat.current_value == 1.0, "Health minimum should be 1.0")
	
	# Test maximum constraint
	var crit_stat = CharacterStat.new(CharacterStat.StatType.CRITICAL_CHANCE, 80.0)
	crit_stat.apply_modifier(50.0, true)
	assert(crit_stat.current_value <= crit_stat.max_value, "Crit chance should respect maximum value")
	assert(crit_stat.current_value == 100.0, "Crit chance maximum should be 100.0")
	
	add_test_result("✓ Stat constraints work correctly")