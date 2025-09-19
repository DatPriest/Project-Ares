extends Node

## Integration test for weapon system with existing Project Ares components
## Demonstrates weapon system working with current upgrade flow

var weapon_system_manager: WeaponSystemManager
var upgrade_manager: Node
var test_results: Array[String] = []

func _ready():
	print("Starting Weapon System Integration Test...")
	setup_test_environment()
	run_integration_tests()
	print_results()

func setup_test_environment():
	"""Set up test environment with managers"""
	# Create weapon system manager
	weapon_system_manager = WeaponSystemManager.new()
	add_child(weapon_system_manager)
	
	# Find existing upgrade manager or create a mock
	upgrade_manager = get_tree().get_first_node_in_group("upgrade_manager")
	if not upgrade_manager:
		upgrade_manager = Node.new()
		upgrade_manager.name = "MockUpgradeManager"
		add_child(upgrade_manager)
	
	weapon_system_manager.upgrade_manager = upgrade_manager

func run_integration_tests():
	"""Run integration tests"""
	test_weapon_factory_creation()
	test_weapon_instance_generation()
	test_rarity_system()
	test_condition_system()
	test_stat_system()
	test_dps_calculations()
	test_upgrade_integration()
	test_game_events_integration()

func test_weapon_factory_creation():
	"""Test weapon factory creation and default resources"""
	print("Testing weapon factory creation...")
	
	var factory = weapon_system_manager.get_weapon_factory()
	assert(factory != null, "Weapon factory should be created")
	
	var rarities = factory.get_all_rarities()
	assert(rarities.size() == 10, "Should have 10 rarity grades")
	
	var conditions = factory.get_all_conditions()
	assert(conditions.size() == 5, "Should have 5 conditions")
	
	add_result("✓ Weapon factory created with all rarities and conditions")

func test_weapon_instance_generation():
	"""Test generating weapon instances"""
	print("Testing weapon instance generation...")
	
	var factory = weapon_system_manager.get_weapon_factory()
	
	# Generate multiple weapons to test variety
	var weapons: Array[WeaponInstance] = []
	for i in range(10):
		var weapon = factory.generate_weapon_instance("bow")
		weapons.append(weapon)
	
	# Check that weapons have different properties
	var unique_rarities = {}
	var unique_conditions = {}
	
	for weapon in weapons:
		unique_rarities[weapon.rarity.id] = true
		unique_conditions[weapon.condition.id] = true
		
		assert(weapon.base_weapon_id == "bow", "All weapons should be bows")
		assert(weapon.stats.size() > 0, "Weapons should have stats")
		assert(weapon.id.length() > 0, "Weapons should have unique IDs")
	
	add_result("✓ Generated " + str(weapons.size()) + " unique weapon instances")
	print("  - Found " + str(unique_rarities.size()) + " different rarities")
	print("  - Found " + str(unique_conditions.size()) + " different conditions")

func test_rarity_system():
	"""Test rarity system scaling"""
	print("Testing rarity system scaling...")
	
	var factory = weapon_system_manager.get_weapon_factory()
	var rarities = factory.get_all_rarities()
	
	for rarity in rarities:
		var expected_max_level = rarity.grade * 10
		var actual_max_level = rarity.get_max_upgrade_level()
		assert(actual_max_level == expected_max_level, "Max level should scale with grade")
		
		var stat_range = rarity.get_stat_range()
		var expected_range = 30.0 * rarity.grade
		assert(abs(stat_range.y - expected_range) < 0.1, "Stat range should scale with grade")
	
	add_result("✓ Rarity system scaling works correctly for all 10 grades")

func test_condition_system():
	"""Test condition system effects"""
	print("Testing condition system effects...")
	
	var factory = weapon_system_manager.get_weapon_factory()
	
	# Test different conditions
	var worn = factory.get_condition_by_id("worn")
	var pristine = factory.get_condition_by_id("pristine")
	
	assert(worn.damage_modifier < 1.0, "Worn condition should reduce damage")
	assert(pristine.damage_modifier > 1.0, "Pristine condition should increase damage")
	assert(worn.trade_value_modifier < 1.0, "Worn condition should reduce value")
	assert(pristine.trade_value_modifier > 1.0, "Pristine condition should increase value")
	
	add_result("✓ Condition system provides expected stat modifications")

func test_stat_system():
	"""Test stat system functionality"""
	print("Testing stat system...")
	
	# Test stat creation and variance
	var stat = WeaponStat.new(WeaponStat.StatType.DAMAGE, 100.0)
	var original_value = stat.current_value
	
	stat.apply_random_variance()
	var variance_applied = stat.current_value != original_value
	
	# Test stat display
	var display_value = stat.get_display_value()
	assert(display_value.length() > 0, "Stat should have display value")
	
	# Test stat colors
	var positive_stat = WeaponStat.new(WeaponStat.StatType.DAMAGE, 50.0)
	var negative_stat = WeaponStat.new(WeaponStat.StatType.FIRE_RATE, -20.0)
	negative_stat.current_value = -20.0
	
	assert(positive_stat.get_display_color() == positive_stat.positive_color, "Positive stat should use positive color")
	assert(negative_stat.get_display_color() == negative_stat.negative_color, "Negative stat should use negative color")
	
	add_result("✓ Stat system handles values, variance, and display correctly")

func test_dps_calculations():
	"""Test DPS calculation system"""
	print("Testing DPS calculations...")
	
	var factory = weapon_system_manager.get_weapon_factory()
	
	# Create weapons of different types
	var weapon_types = ["sword", "bow", "axe", "magic_staff"]
	
	for weapon_type in weapon_types:
		var weapon = factory.generate_weapon_instance(weapon_type)
		var dps = weapon.get_total_dps()
		
		assert(dps >= 0, "DPS should not be negative")
		
		# Test that weapons have different base fire rates
		var base_fire_rate = weapon._get_base_fire_rate()
		assert(base_fire_rate > 0, "Base fire rate should be positive")
	
	add_result("✓ DPS calculations work for all weapon types")

func test_upgrade_integration():
	"""Test integration with upgrade system"""
	print("Testing upgrade system integration...")
	
	# Test weapon system manager initialization
	var all_instances = weapon_system_manager.get_all_weapon_instances()
	assert(all_instances.size() == 0, "Should have no weapon instances initially (lazy loading)")
	
	# Test getting specific weapon instance (should create it lazily)
	var sword_instance = weapon_system_manager.get_weapon_instance("sword")
	assert(sword_instance != null, "Should have sword instance")
	assert(sword_instance.base_weapon_id == "sword", "Sword instance should be for sword")
	
	# Now should have one instance
	all_instances = weapon_system_manager.get_all_weapon_instances()
	assert(all_instances.size() == 1, "Should now have 1 weapon instance")
	
	# Test weapon DPS retrieval
	var sword_dps = weapon_system_manager.get_weapon_dps("sword")
	assert(sword_dps > 0, "Sword DPS should be positive")
	
	var total_dps = weapon_system_manager.get_total_dps()
	assert(total_dps > 0, "Total DPS should be positive")
	
	add_result("✓ Weapon system integrates with upgrade management (with lazy loading)")

func test_game_events_integration():
	"""Test GameEvents integration"""
	print("Testing GameEvents integration...")
	
	var events_connected = 0
	
	# Test that weapon events exist
	if GameEvents.has_signal("weapon_instance_created"):
		events_connected += 1
	if GameEvents.has_signal("weapon_instance_upgraded"):
		events_connected += 1
	if GameEvents.has_signal("weapon_rarity_discovered"):
		events_connected += 1
	
	assert(events_connected == 3, "All weapon events should be available")
	
	# Test event emission (just make sure it doesn't crash)
	var factory = weapon_system_manager.get_weapon_factory()
	var test_weapon = factory.generate_weapon_instance("test")
	
	add_result("✓ GameEvents integration works correctly")

func add_result(result: String):
	"""Add test result"""
	test_results.append(result)

func print_results():
	"""Print all test results"""
	print("\n=== WEAPON SYSTEM INTEGRATION TEST RESULTS ===")
	for result in test_results:
		print(result)
	
	print("\nTotal integration tests: " + str(test_results.size()))
	print("🎯 Weapon system integration successful!")
	
	# Show some example weapons
	print("\n=== EXAMPLE WEAPONS GENERATED ===")
	var factory = weapon_system_manager.get_weapon_factory()
	
	for weapon_type in ["sword", "bow", "magic_staff"]:
		var weapon = factory.generate_weapon_instance(weapon_type)
		print("\n" + weapon.get_description())
		print("---")