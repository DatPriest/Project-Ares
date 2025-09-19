extends Node
class_name RarityTestSuite

"""
Comprehensive test suite for the weapon rarity system.
Tests all aspects of rarity mechanics including edge cases, negative stats, and DPS calculations.
"""

signal test_completed(results: Dictionary)
signal all_tests_completed(summary: Dictionary)

var test_results: Array[Dictionary] = []
var current_test_index: int = 0
var total_tests: int = 0

func _ready() -> void:
	print("=== Weapon Rarity System Test Suite ===")
	run_all_tests()

func run_all_tests() -> void:
	"""Run all rarity system tests"""
	test_results.clear()
	current_test_index = 0
	
	# Define all test methods
	var test_methods: Array[Callable] = [
		test_rarity_grade_ranges,
		test_stat_modifier_ranges,
		test_negative_stats,
		test_level_progression,
		test_durability_system,
		test_critical_hit_system,
		test_accuracy_system,
		test_mana_cost_system,
		test_dps_calculations,
		test_weapon_variants,
		test_edge_cases,
		test_max_level_constraints,
		test_false_scenarios,
		test_performance_benchmarks
	]
	
	total_tests = test_methods.size()
	print("Running %d test categories..." % total_tests)
	
	for test_method in test_methods:
		await run_test_category(test_method)
	
	_print_final_summary()
	all_tests_completed.emit(_generate_test_summary())

func run_test_category(test_method: Callable) -> void:
	"""Run a single test category"""
	current_test_index += 1
	var test_name: String = str(test_method).get_slice("::", 1)
	print("\n--- Test %d/%d: %s ---" % [current_test_index, total_tests, test_name])
	
	var start_time: float = Time.get_time_dict_from_system()["unix"]
	var test_result: Dictionary = await test_method.call()
	var end_time: float = Time.get_time_dict_from_system()["unix"]
	
	test_result["duration"] = end_time - start_time
	test_result["test_name"] = test_name
	test_results.append(test_result)
	
	test_completed.emit(test_result)
	
	# Brief pause between tests
	await get_tree().process_frame

func test_rarity_grade_ranges() -> Dictionary:
	"""Test that all 10 rarity grades work correctly"""
	var results: Dictionary = {"passed": 0, "failed": 0, "details": []}
	
	for grade in range(10):
		var rarity: WeaponRarity = WeaponRarity.new(grade)
		
		# Test basic properties
		if rarity.rarity_grade == grade:
			results.passed += 1
			results.details.append("✓ Grade %d: %s configured correctly" % [grade, rarity.rarity_name])
		else:
			results.failed += 1
			results.details.append("❌ Grade %d: incorrect configuration" % grade)
		
		# Test max level progression (should increase with rarity)
		var expected_min_level: int = (grade + 1) * 10
		if grade == 0:  # Broken weapons have limited levels
			expected_min_level = 5
		
		if rarity.max_upgrade_level >= expected_min_level or grade == 0:
			results.passed += 1
			results.details.append("✓ Grade %d: max level %d is appropriate" % [grade, rarity.max_upgrade_level])
		else:
			results.failed += 1
			results.details.append("❌ Grade %d: max level %d too low" % [grade, rarity.max_upgrade_level])
	
	return results

func test_stat_modifier_ranges() -> Dictionary:
	"""Test that stat modifiers are within expected ranges"""
	var results: Dictionary = {"passed": 0, "failed": 0, "details": []}
	
	for grade in range(10):
		var rarity: WeaponRarity = WeaponRarity.new(grade)
		
		# Test multiple random generations for consistency
		for iteration in range(10):
			var damage_mod: float = rarity.get_random_damage_modifier()
			var cooldown_mod: float = rarity.get_random_cooldown_modifier()
			var range_mod: float = rarity.get_random_range_modifier()
			
			# Check if modifiers are within expected ranges
			if (damage_mod >= rarity.damage_modifier_range.x and 
				damage_mod <= rarity.damage_modifier_range.y):
				results.passed += 1
			else:
				results.failed += 1
				results.details.append("❌ Grade %d: damage modifier %.2f out of range [%.2f, %.2f]" % 
					[grade, damage_mod, rarity.damage_modifier_range.x, rarity.damage_modifier_range.y])
			
			if (cooldown_mod >= rarity.cooldown_modifier_range.x and 
				cooldown_mod <= rarity.cooldown_modifier_range.y):
				results.passed += 1
			else:
				results.failed += 1
				results.details.append("❌ Grade %d: cooldown modifier %.2f out of range" % [grade, cooldown_mod])
	
	if results.failed == 0:
		results.details.append("✓ All stat modifiers within expected ranges")
	
	return results

func test_negative_stats() -> Dictionary:
	"""Test negative stat scenarios for lower rarity weapons"""
	var results: Dictionary = {"passed": 0, "failed": 0, "details": []}
	
	# Test Broken (grade 0) and Poor (grade 1) weapons
	for grade in range(2):
		var weapon: WeaponStats = WeaponStats.new(10.0, 1.0, 0.1, 0.1, 100.0, grade)
		
		# These should have negative damage modifiers
		if weapon.applied_damage_modifier < 0:
			results.passed += 1
			results.details.append("✓ Grade %d: negative damage modifier %.2f%%" % [grade, weapon.applied_damage_modifier])
		else:
			results.failed += 1
			results.details.append("❌ Grade %d: expected negative damage, got %.2f%%" % [grade, weapon.applied_damage_modifier])
		
		# Test that weapons with negative stats still function
		weapon.apply_damage_upgrade(1)
		if weapon.current_damage > 0:
			results.passed += 1
			results.details.append("✓ Grade %d: weapon still functional with damage %.2f" % [grade, weapon.current_damage])
		else:
			results.failed += 1
			results.details.append("❌ Grade %d: weapon non-functional" % grade)
	
	return results

func test_level_progression() -> Dictionary:
	"""Test weapon level progression and constraints"""
	var results: Dictionary = {"passed": 0, "failed": 0, "details": []}
	
	# Test each rarity grade
	for grade in range(10):
		var weapon: WeaponStats = WeaponStats.new(5.0, 1.0, 0.1, 0.1, 50.0, grade)
		var max_level: int = weapon.get_current_max_level()
		
		# Test upgrading to max level
		var upgrades_successful: int = 0
		for level in range(max_level):
			if weapon.upgrade_weapon_level():
				upgrades_successful += 1
			else:
				break
		
		if upgrades_successful == max_level:
			results.passed += 1
			results.details.append("✓ Grade %d: successfully upgraded to max level %d" % [grade, max_level])
		else:
			results.failed += 1
			results.details.append("❌ Grade %d: only upgraded %d/%d levels" % [grade, upgrades_successful, max_level])
		
		# Test that further upgrades fail
		if not weapon.upgrade_weapon_level():
			results.passed += 1
			results.details.append("✓ Grade %d: correctly prevents over-leveling" % grade)
		else:
			results.failed += 1
			results.details.append("❌ Grade %d: allowed over-leveling" % grade)
	
	return results