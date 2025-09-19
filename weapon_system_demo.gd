extends Node

## Demo script showcasing the weapon rarity, condition, and stat system
## Run this to see examples of the weapon system in action

func _ready():
	print("=== PROJECT ARES WEAPON SYSTEM DEMO ===\n")
	
	var factory = WeaponFactory.new()
	
	demo_rarity_system(factory)
	demo_condition_system(factory)
	demo_weapon_generation(factory)
	demo_stat_system(factory)
	demo_upgrade_system(factory)
	demo_dps_calculations(factory)
	
	print("\n=== DEMO COMPLETE ===")

func demo_rarity_system(factory: WeaponFactory):
	"""Demonstrate the 10 rarity grades"""
	print("📊 RARITY SYSTEM DEMO")
	print("====================")
	
	var rarities = factory.get_all_rarities()
	
	for rarity in rarities:
		var stat_range = rarity.get_stat_range()
		print("🏆 %s (Grade %d)" % [rarity.name, rarity.grade])
		print("   Max Level: %d | Stat Range: %.0f to %.0f | Drop Weight: %d" % [
			rarity.get_max_upgrade_level(), 
			stat_range.x, 
			stat_range.y, 
			rarity.drop_weight as int
		])
	
	print()

func demo_condition_system(factory: WeaponFactory):
	"""Demonstrate weapon conditions"""
	print("🔧 CONDITION SYSTEM DEMO")
	print("========================")
	
	var conditions = factory.get_all_conditions()
	
	for condition in conditions:
		print("⚙️  %s" % condition.name)
		print("   Damage: %.0f%% | Speed: %.0f%% | Value: %.0f%%" % [
			condition.damage_modifier * 100,
			condition.speed_modifier * 100,
			condition.trade_value_modifier * 100
		])
	
	print()

func demo_weapon_generation(factory: WeaponFactory):
	"""Demonstrate weapon generation with different rarities"""
	print("⚔️  WEAPON GENERATION DEMO")
	print("==========================")
	
	var weapon_types = ["sword", "bow", "magic_staff", "axe"]
	
	for weapon_type in weapon_types:
		print("🗡️  Generating %s weapons:" % weapon_type.capitalize())
		
		# Generate weapons of different rarities
		var common = factory.generate_weapon_instance(weapon_type, 
			factory.get_rarity_by_id("common"), 
			factory.get_condition_by_id("good"))
		
		var epic = factory.generate_weapon_instance(weapon_type, 
			factory.get_rarity_by_id("epic"), 
			factory.get_condition_by_id("new"))
		
		var legendary = factory.generate_weapon_instance(weapon_type, 
			factory.get_rarity_by_id("legendary"), 
			factory.get_condition_by_id("pristine"))
		
		print("   Common: %.1f DPS | %d stats" % [common.get_total_dps(), common.stats.size()])
		print("   Epic: %.1f DPS | %d stats" % [epic.get_total_dps(), epic.stats.size()])
		print("   Legendary: %.1f DPS | %d stats" % [legendary.get_total_dps(), legendary.stats.size()])
		print()

func demo_stat_system(factory: WeaponFactory):
	"""Demonstrate the stat system with positive and negative values"""
	print("📈 STAT SYSTEM DEMO")
	print("===================")
	
	# Create a high-grade weapon that can have many stats
	var mythic_weapon = factory.generate_weapon_instance("bow", 
		factory.get_rarity_by_id("mythic"), 
		factory.get_condition_by_id("good"))
	
	print("🏹 Mythic Bow Stats:")
	for stat in mythic_weapon.stats:
		var color_indicator = "+" if stat.current_value >= 0 else "-"
		print("   %s %s: %s" % [color_indicator, stat.display_name, stat.get_display_value()])
	
	print()
	
	# Show stat variance
	print("🎲 Stat Randomization Demo:")
	var base_stat = WeaponStat.new(WeaponStat.StatType.DAMAGE, 100.0)
	
	for i in range(5):
		base_stat.current_value = base_stat.base_value  # Reset
		base_stat.apply_random_variance()
		print("   Roll %d: %.1f damage (variance: %+.1f)" % [
			i + 1, 
			base_stat.current_value, 
			base_stat.current_value - base_stat.base_value
		])
	
	print()

func demo_upgrade_system(factory: WeaponFactory):
	"""Demonstrate weapon upgrade system"""
	print("⬆️  UPGRADE SYSTEM DEMO")
	print("=======================")
	
	var weapon = factory.generate_weapon_instance("sword", 
		factory.get_rarity_by_id("rare"), 
		factory.get_condition_by_id("good"))
	
	print("🗡️  Rare Sword Upgrade Progression:")
	print("   Level 0: %.1f DPS" % weapon.get_total_dps())
	
	# Show upgrade progression
	for level in range(1, 6):
		if weapon.can_upgrade():
			weapon.upgrade()
			print("   Level %d: %.1f DPS" % [level, weapon.get_total_dps()])
		else:
			break
	
	print("   Max possible level: %d" % weapon.get_max_upgrade_level())
	print()

func demo_dps_calculations(factory: WeaponFactory):
	"""Demonstrate DPS calculations for different weapon types"""
	print("⚡ DPS CALCULATION DEMO")
	print("======================")
	
	var weapon_types = ["sword", "axe", "bow", "magic_staff", "shield"]
	
	print("Base DPS by weapon type (Common rarity, Good condition):")
	
	for weapon_type in weapon_types:
		var weapon = factory.generate_weapon_instance(weapon_type, 
			factory.get_rarity_by_id("common"), 
			factory.get_condition_by_id("good"))
		
		var base_fire_rate = weapon._get_base_fire_rate()
		var total_dps = weapon.get_total_dps()
		var trade_value = weapon.get_trade_value()
		
		print("   %s: %.1f DPS (%.1f att/sec) | Value: %.0f" % [
			weapon_type.capitalize().pad_right(12),
			total_dps,
			base_fire_rate,
			trade_value
		])
	
	print()
	
	# Show how rarity affects DPS
	print("DPS scaling by rarity (Bow example):")
	var rarity_names = ["common", "rare", "epic", "legendary", "omnipotent"]
	
	for rarity_name in rarity_names:
		var weapon = factory.generate_weapon_instance("bow", 
			factory.get_rarity_by_id(rarity_name), 
			factory.get_condition_by_id("good"))
		
		print("   %s: %.1f DPS | %d max levels" % [
			rarity_name.capitalize().pad_right(12),
			weapon.get_total_dps(),
			weapon.get_max_upgrade_level()
		])
	
	print()

func demo_complete_weapon_example():
	"""Show a complete detailed weapon example"""
	print("🎯 COMPLETE WEAPON EXAMPLE")
	print("===========================")
	
	var factory = WeaponFactory.new()
	var weapon = factory.generate_weapon_instance("bow", 
		factory.get_rarity_by_id("legendary"), 
		factory.get_condition_by_id("pristine"))
	
	print(weapon.get_description())
	print()