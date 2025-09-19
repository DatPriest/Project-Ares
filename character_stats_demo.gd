extends SceneTree

## Demo script for Character Stats System
## Demonstrates stat creation, modification, and display functionality

func _init():
	print("=== Character Stats System Demo ===")
	print("Demonstrating character stat functionality...")
	print()
	
	demo_basic_stats()
	demo_stat_modifiers()
	demo_random_variance()
	demo_stats_component()
	demo_negative_stats()
	
	print("\nDemo completed. Character stats system is ready for integration!")
	quit()

func demo_basic_stats():
	print("--- Basic Stat Creation ---")
	
	var health_stat = CharacterStat.new(CharacterStat.StatType.HEALTH, 100.0)
	print("Health Stat: ", health_stat.display_name, " = ", health_stat.get_display_value())
	print("  Color: ", health_stat.get_display_color())
	
	var crit_stat = CharacterStat.new(CharacterStat.StatType.CRITICAL_CHANCE, 15.0)
	print("Crit Chance: ", crit_stat.display_name, " = ", crit_stat.get_display_value())
	print("  Is Percentage: ", crit_stat.is_percentage)
	
	var luck_stat = CharacterStat.new(CharacterStat.StatType.LUCK, 25.0)
	print("Luck: ", luck_stat.display_name, " = ", luck_stat.get_display_value())
	print()

func demo_stat_modifiers():
	print("--- Stat Modifiers ---")
	
	var damage_stat = CharacterStat.new(CharacterStat.StatType.DAMAGE, 50.0)
	print("Base Damage: ", damage_stat.get_display_value())
	
	damage_stat.apply_modifier(25.0, true)  # Additive
	print("After +25 additive: ", damage_stat.get_display_value())
	
	damage_stat.reset_to_base()
	damage_stat.apply_modifier(1.5, false)  # Multiplicative
	print("After x1.5 multiplicative: ", damage_stat.get_display_value())
	print()

func demo_random_variance():
	print("--- Random Variance ---")
	
	var agility_stat = CharacterStat.new(CharacterStat.StatType.AGILITY, 100.0)
	print("Base Agility: ", agility_stat.get_display_value())
	
	print("5 random variance samples:")
	for i in range(5):
		agility_stat.current_value = agility_stat.base_value
		agility_stat.apply_random_variance()
		print("  Sample ", i + 1, ": ", agility_stat.get_display_value())
	print()

func demo_stats_component():
	print("--- Character Stats Component ---")
	
	var stats_component = CharacterStatsComponent.new()
	stats_component.enable_random_variance = false  # Predictable for demo
	stats_component._initialize_stats()
	
	print("Default stats:")
	print("  Health: ", stats_component.get_stat_value(CharacterStat.StatType.HEALTH))
	print("  Critical Chance: ", stats_component.get_stat_value(CharacterStat.StatType.CRITICAL_CHANCE), "%")
	print("  Speed Multiplier: ", stats_component.get_speed_multiplier())
	
	# Apply some modifications
	stats_component.modify_stat(CharacterStat.StatType.DAMAGE, 35.0)
	stats_component.modify_stat(CharacterStat.StatType.SPEED, 20.0)  # 20% speed boost
	stats_component.modify_stat(CharacterStat.StatType.LUCK, 15.0)
	
	print("\nAfter modifications:")
	print("  Damage Bonus: ", stats_component.get_stat_value(CharacterStat.StatType.DAMAGE))
	print("  Speed Multiplier: ", stats_component.get_speed_multiplier())
	print("  Luck: ", stats_component.get_stat_value(CharacterStat.StatType.LUCK))
	
	var display_stats = stats_component.get_stats_for_display()
	print("  Stats for display: ", display_stats.size(), " stats")
	print()

func demo_negative_stats():
	print("--- Negative Stats ---")
	
	var speed_stat = CharacterStat.new(CharacterStat.StatType.SPEED, 10.0)
	print("Base Speed: ", speed_stat.get_display_value(), " (Color: ", speed_stat.get_display_color(), ")")
	
	speed_stat.apply_modifier(-25.0, true)
	print("After -25 penalty: ", speed_stat.get_display_value(), " (Color: ", speed_stat.get_display_color(), ")")
	
	var resistance_stat = CharacterStat.new(CharacterStat.StatType.FIRE_RESISTANCE, -10.0)
	print("Fire Vulnerability: ", resistance_stat.get_display_value(), " (Negative resistance)")
	print()