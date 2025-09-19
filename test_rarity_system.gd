extends Node
# Simple test runner for the weapon rarity system
# This can be run as a standalone script to validate rarity mechanics

func _ready() -> void:
	print("=== Weapon Rarity System Validation ===")
	test_basic_functionality()
	test_stat_ranges()
	test_negative_scenarios()
	test_dps_scaling()
	print("=== Validation Complete ===")

func test_basic_functionality() -> void:
	print("\n--- Basic Functionality Tests ---")
	
	# Test all 10 rarity grades
	for grade in range(10):
		var rarity: WeaponRarity = WeaponRarity.new(grade)
		var weapon: WeaponStats = WeaponStats.new(10.0, 1.0, 0.1, 0.1, 100.0, grade)
		
		assert(rarity.rarity_grade == grade, "Rarity grade mismatch")
		assert(weapon.weapon_rarity.rarity_grade == grade, "Weapon rarity assignment failed")
		print("✓ Grade %d (%s): Max Level %d" % [grade, rarity.rarity_name, rarity.max_upgrade_level])

func test_stat_ranges() -> void:
	print("\n--- Stat Range Tests ---")
	
	# Test broken weapons have negative stats
	var broken_weapon: WeaponStats = WeaponStats.new(10.0, 1.0, 0.1, 0.1, 100.0, 0)
	assert(broken_weapon.applied_damage_modifier < 0, "Broken weapon should have negative damage")
	print("✓ Broken weapon damage modifier: %.2f%%" % broken_weapon.applied_damage_modifier)
	
	# Test transcendent weapons have massive bonuses
	var transcendent_weapon: WeaponStats = WeaponStats.new(10.0, 1.0, 0.1, 0.1, 100.0, 9)
	assert(transcendent_weapon.applied_damage_modifier > 100, "Transcendent weapon should have massive damage bonus")
	print("✓ Transcendent weapon damage modifier: %.2f%%" % transcendent_weapon.applied_damage_modifier)

func test_negative_scenarios() -> void:
	print("\n--- Negative Scenario Tests ---")
	
	# Test that broken weapons still function
	var broken_weapon: WeaponStats = WeaponStats.new(10.0, 1.0, 0.1, 0.1, 100.0, 0)
	broken_weapon.apply_damage_upgrade(1)
	assert(broken_weapon.current_damage > 0, "Broken weapon should still deal damage")
	print("✓ Broken weapon functional damage: %.2f" % broken_weapon.current_damage)
	
	# Test extreme cooldown values
	var fast_weapon: WeaponStats = WeaponStats.new(5.0, 0.01, 0.1, 0.1, 50.0, 8)
	fast_weapon.apply_rate_upgrade(10)
	assert(fast_weapon.current_cooldown >= 0.05, "Cooldown should be clamped to minimum")
	print("✓ Minimum cooldown enforced: %.3fs" % fast_weapon.current_cooldown)
	
	# Test null rarity handling
	var weapon: WeaponStats = WeaponStats.new()
	weapon.weapon_rarity = null
	weapon._update_all_current_values()  # Should not crash
	print("✓ Null rarity handled gracefully")

func test_dps_scaling() -> void:
	print("\n--- DPS Scaling Tests ---")
	
	var dps_values: Array[float] = []
	
	# Calculate DPS for each rarity
	for grade in range(10):
		var weapon: WeaponStats = WeaponStats.new(10.0, 1.0, 0.1, 0.1, 50.0, grade)
		var dps: float = weapon.get_dps_estimate()
		dps_values.append(dps)
		print("Grade %d (%s): DPS %.2f" % [grade, weapon.weapon_rarity.rarity_name, dps])
	
	# Verify that higher rarities generally have higher DPS (excluding broken/poor)
	for i in range(2, 9):
		if dps_values[i] > dps_values[i-1]:
			print("✓ DPS increases from %s to %s" % [
				WeaponRarity.new(i-1).rarity_name,
				WeaponRarity.new(i).rarity_name
			])
	
	# Verify broken weapons have lower DPS than common
	assert(dps_values[0] < dps_values[2], "Broken weapons should have lower DPS than Common")
	print("✓ Broken < Common DPS verified")

func assert(condition: bool, message: String) -> void:
	if not condition:
		print("❌ ASSERTION FAILED: " + message)
		push_error(message)
	else:
		print("  ✓ " + message)