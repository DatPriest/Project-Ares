extends Node

## Quick validation test for weapon system classes

func _ready():
	print("Quick weapon system validation...")
	
	# Test basic class creation
	var rarity = WeaponRarity.new()
	rarity.id = "test"
	rarity.name = "Test Rarity"
	rarity.grade = 5
	print("✓ WeaponRarity created: " + rarity.name)
	
	var condition = WeaponCondition.new()
	condition.id = "test_condition"
	condition.name = "Test Condition"
	print("✓ WeaponCondition created: " + condition.name)
	
	var stat = WeaponStat.new(WeaponStat.StatType.DAMAGE, 50.0)
	print("✓ WeaponStat created: " + stat.display_name + " = " + str(stat.current_value))
	
	var weapon = WeaponInstance.new("test_weapon", rarity, condition)
	print("✓ WeaponInstance created: " + weapon.base_weapon_id)
	print("  Stats count: " + str(weapon.stats.size()))
	
	var factory = WeaponFactory.new()
	print("✓ WeaponFactory created")
	print("  Rarities available: " + str(factory.get_all_rarities().size()))
	print("  Conditions available: " + str(factory.get_all_conditions().size()))
	
	var generated_weapon = factory.generate_weapon_instance("sword")
	print("✓ Generated weapon: " + generated_weapon.display_name)
	print("  DPS: " + str(generated_weapon.get_total_dps()))
	
	print("\n🎉 All basic weapon system classes working correctly!")