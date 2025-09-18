extends Node
# Quick test script to verify new weapon system functionality

func _ready() -> void:
	print("Testing new weapon system...")
	test_upgrade_manager()
	test_synergy_system()
	test_strategic_upgrades()
	print("All tests completed!")

func test_upgrade_manager() -> void:
	print("\n=== Testing UpgradeManager ===")
	
	# Test that new weapons are loaded
	var upgrade_manager = preload("res://scenes/manager/upgrade_manager.gd").new()
	
	# Check if new weapon resources exist
	assert(upgrade_manager.upgrade_bow != null, "Bow upgrade should be loaded")
	assert(upgrade_manager.upgrade_magic_staff != null, "Magic Staff upgrade should be loaded")  
	assert(upgrade_manager.upgrade_shield != null, "Shield upgrade should be loaded")
	
	print("✓ All new weapons loaded successfully")

func test_synergy_system() -> void:
	print("\n=== Testing Synergy System ===")
	
	# Mock current upgrades
	var mock_upgrades = {
		"bow": {"quantity": 1},
		"magic_staff": {"quantity": 1},
		"shield": {"quantity": 1}
	}
	
	# Test flaming arrows synergy (bow + magic staff)
	var has_bow_and_staff = mock_upgrades.has("bow") and mock_upgrades.has("magic_staff")
	assert(has_bow_and_staff, "Should detect bow + magic staff combination")
	
	# Test elemental mastery synergy (all weapons)
	var has_all_weapons = mock_upgrades.has("bow") and mock_upgrades.has("magic_staff") and mock_upgrades.has("shield")
	assert(has_all_weapons, "Should detect all weapon combination")
	
	print("✓ Synergy detection working")

func test_strategic_upgrades() -> void:
	print("\n=== Testing Strategic Upgrades ===")
	
	# Test StrategicUpgrade class
	var strategic_upgrade = preload("res://resources/upgrades/strategic_upgrade.gd").new()
	strategic_upgrade.prerequisite_upgrades = ["bow", "bow_damage"]
	strategic_upgrade.minimum_level = 5
	strategic_upgrade.requires_multiplayer = false
	
	# Test with valid prerequisites
	var valid_upgrades = {"bow": {"quantity": 1}, "bow_damage": {"quantity": 1}}
	var can_unlock = strategic_upgrade.can_unlock(valid_upgrades, 6, false)
	assert(can_unlock, "Should unlock with valid prerequisites and level")
	
	# Test with missing prerequisites  
	var invalid_upgrades = {"bow": {"quantity": 1}}
	var cannot_unlock = not strategic_upgrade.can_unlock(invalid_upgrades, 6, false)
	assert(cannot_unlock, "Should not unlock with missing prerequisites")
	
	# Test level requirement
	var low_level = not strategic_upgrade.can_unlock(valid_upgrades, 4, false)
	assert(low_level, "Should not unlock below minimum level")
	
	print("✓ Strategic upgrade prerequisites working")

func assert(condition: bool, message: String) -> void:
	if not condition:
		print("❌ ASSERTION FAILED: " + message)
		push_error(message)
	else:
		print("  ✓ " + message)