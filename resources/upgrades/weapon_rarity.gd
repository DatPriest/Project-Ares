extends Resource
class_name WeaponRarity

# 10 Rarity Grades: 0=Broken, 1=Poor, 2=Common, 3=Uncommon, 4=Rare,
# 5=Epic, 6=Legendary, 7=Mythic, 8=Divine, 9=Transcendent
@export_range(0, 9) var rarity_grade: int = 2  # Default to Common

@export var rarity_name: String = "Common"
@export var rarity_color: Color = Color.WHITE
@export var max_upgrade_level: int = 10  # Each rarity allows 10 more levels (0-10, 0-20, etc.)

# Stat modifier ranges - negative values are allowed for lower rarities
@export var damage_modifier_range: Vector2 = Vector2(-10.0, 10.0)  # Min/Max percentage modifier
@export var cooldown_modifier_range: Vector2 = Vector2(-10.0, 10.0)  # Negative = faster, Positive = slower
@export var range_modifier_range: Vector2 = Vector2(-10.0, 10.0)
@export var critical_chance_range: Vector2 = Vector2(0.0, 5.0)  # 0-5% critical chance at Common
@export var critical_multiplier_range: Vector2 = Vector2(1.0, 1.5)  # 1x-1.5x critical damage

# Additional stat modifiers for higher rarities
@export var durability_modifier_range: Vector2 = Vector2(-20.0, 20.0)  # Weapon durability
@export var mana_cost_modifier_range: Vector2 = Vector2(-10.0, 10.0)  # For magical weapons
@export var accuracy_modifier_range: Vector2 = Vector2(-15.0, 15.0)  # Hit chance modifier

func _init(grade: int = 2) -> void:
	rarity_grade = grade
	_setup_rarity_properties()

func _setup_rarity_properties() -> void:
	"""Configure rarity properties based on grade"""
	match rarity_grade:
		0:  # Broken
			rarity_name = "Broken"
			rarity_color = Color(0.4, 0.3, 0.2)  # Dark brown
			max_upgrade_level = 5  # Limited upgrades
			damage_modifier_range = Vector2(-50.0, -20.0)  # Always negative
			cooldown_modifier_range = Vector2(20.0, 50.0)  # Always slower
			range_modifier_range = Vector2(-30.0, -10.0)
			critical_chance_range = Vector2(0.0, 1.0)
			critical_multiplier_range = Vector2(1.0, 1.1)
			durability_modifier_range = Vector2(-50.0, -30.0)
			mana_cost_modifier_range = Vector2(10.0, 30.0)
			accuracy_modifier_range = Vector2(-30.0, -15.0)
		1:  # Poor
			rarity_name = "Poor"
			rarity_color = Color(0.6, 0.6, 0.6)  # Gray
			max_upgrade_level = 10
			damage_modifier_range = Vector2(-30.0, 0.0)
			cooldown_modifier_range = Vector2(0.0, 30.0)
			range_modifier_range = Vector2(-20.0, 0.0)
			critical_chance_range = Vector2(0.0, 2.0)
			critical_multiplier_range = Vector2(1.0, 1.2)
			durability_modifier_range = Vector2(-30.0, -10.0)
			mana_cost_modifier_range = Vector2(0.0, 20.0)
			accuracy_modifier_range = Vector2(-20.0, -5.0)
		2:  # Common
			rarity_name = "Common"
			rarity_color = Color.WHITE
			max_upgrade_level = 20
			damage_modifier_range = Vector2(-10.0, 10.0)
			cooldown_modifier_range = Vector2(-10.0, 10.0)
			range_modifier_range = Vector2(-10.0, 10.0)
			critical_chance_range = Vector2(0.0, 5.0)
			critical_multiplier_range = Vector2(1.0, 1.5)
			durability_modifier_range = Vector2(-20.0, 20.0)
			mana_cost_modifier_range = Vector2(-10.0, 10.0)
			accuracy_modifier_range = Vector2(-15.0, 15.0)
		3:  # Uncommon
			rarity_name = "Uncommon"
			rarity_color = Color(0.2, 1.0, 0.2)  # Green
			max_upgrade_level = 30
			damage_modifier_range = Vector2(0.0, 25.0)
			cooldown_modifier_range = Vector2(-20.0, 5.0)
			range_modifier_range = Vector2(0.0, 20.0)
			critical_chance_range = Vector2(2.0, 10.0)
			critical_multiplier_range = Vector2(1.2, 1.8)
			durability_modifier_range = Vector2(0.0, 40.0)
			mana_cost_modifier_range = Vector2(-15.0, 5.0)
			accuracy_modifier_range = Vector2(-5.0, 25.0)
		4:  # Rare
			rarity_name = "Rare"
			rarity_color = Color(0.2, 0.6, 1.0)  # Blue
			max_upgrade_level = 40
			damage_modifier_range = Vector2(10.0, 40.0)
			cooldown_modifier_range = Vector2(-30.0, 0.0)
			range_modifier_range = Vector2(10.0, 35.0)
			critical_chance_range = Vector2(5.0, 15.0)
			critical_multiplier_range = Vector2(1.5, 2.2)
			durability_modifier_range = Vector2(20.0, 60.0)
			mana_cost_modifier_range = Vector2(-25.0, 0.0)
			accuracy_modifier_range = Vector2(5.0, 35.0)
		5:  # Epic
			rarity_name = "Epic"
			rarity_color = Color(0.8, 0.2, 1.0)  # Purple
			max_upgrade_level = 50
			damage_modifier_range = Vector2(25.0, 60.0)
			cooldown_modifier_range = Vector2(-40.0, -10.0)
			range_modifier_range = Vector2(25.0, 50.0)
			critical_chance_range = Vector2(10.0, 25.0)
			critical_multiplier_range = Vector2(1.8, 2.8)
			durability_modifier_range = Vector2(40.0, 80.0)
			mana_cost_modifier_range = Vector2(-35.0, -10.0)
			accuracy_modifier_range = Vector2(15.0, 45.0)
		6:  # Legendary
			rarity_name = "Legendary"
			rarity_color = Color(1.0, 0.6, 0.0)  # Orange
			max_upgrade_level = 60
			damage_modifier_range = Vector2(40.0, 80.0)
			cooldown_modifier_range = Vector2(-50.0, -20.0)
			range_modifier_range = Vector2(40.0, 70.0)
			critical_chance_range = Vector2(20.0, 35.0)
			critical_multiplier_range = Vector2(2.5, 3.5)
			durability_modifier_range = Vector2(60.0, 100.0)
			mana_cost_modifier_range = Vector2(-45.0, -20.0)
			accuracy_modifier_range = Vector2(25.0, 55.0)
		7:  # Mythic
			rarity_name = "Mythic"
			rarity_color = Color(1.0, 0.2, 0.2)  # Red
			max_upgrade_level = 70
			damage_modifier_range = Vector2(60.0, 120.0)
			cooldown_modifier_range = Vector2(-60.0, -30.0)
			range_modifier_range = Vector2(60.0, 100.0)
			critical_chance_range = Vector2(30.0, 50.0)
			critical_multiplier_range = Vector2(3.0, 4.5)
			durability_modifier_range = Vector2(80.0, 150.0)
			mana_cost_modifier_range = Vector2(-55.0, -30.0)
			accuracy_modifier_range = Vector2(35.0, 70.0)
		8:  # Divine
			rarity_name = "Divine"
			rarity_color = Color(1.0, 1.0, 0.0)  # Gold
			max_upgrade_level = 80
			damage_modifier_range = Vector2(100.0, 180.0)
			cooldown_modifier_range = Vector2(-70.0, -40.0)
			range_modifier_range = Vector2(100.0, 150.0)
			critical_chance_range = Vector2(45.0, 70.0)
			critical_multiplier_range = Vector2(4.0, 6.0)
			durability_modifier_range = Vector2(120.0, 200.0)
			mana_cost_modifier_range = Vector2(-65.0, -40.0)
			accuracy_modifier_range = Vector2(50.0, 90.0)
		9:  # Transcendent
			rarity_name = "Transcendent"
			rarity_color = Color(1.0, 1.0, 1.0)  # Brilliant white
			max_upgrade_level = 90
			damage_modifier_range = Vector2(150.0, 250.0)
			cooldown_modifier_range = Vector2(-80.0, -50.0)
			range_modifier_range = Vector2(150.0, 200.0)
			critical_chance_range = Vector2(60.0, 90.0)
			critical_multiplier_range = Vector2(5.0, 8.0)
			durability_modifier_range = Vector2(180.0, 300.0)
			mana_cost_modifier_range = Vector2(-75.0, -50.0)
			accuracy_modifier_range = Vector2(70.0, 120.0)

func get_max_level_for_rarity() -> int:
	"""Get maximum upgrade level allowed for this rarity"""
	return max_upgrade_level

func get_stat_modifier_in_range(stat_range: Vector2) -> float:
	"""Generate a random stat modifier within the given range"""
	return randf_range(stat_range.x, stat_range.y)

func get_random_damage_modifier() -> float:
	return get_stat_modifier_in_range(damage_modifier_range)

func get_random_cooldown_modifier() -> float:
	return get_stat_modifier_in_range(cooldown_modifier_range)

func get_random_range_modifier() -> float:
	return get_stat_modifier_in_range(range_modifier_range)

func get_random_critical_chance() -> float:
	return get_stat_modifier_in_range(critical_chance_range)

func get_random_critical_multiplier() -> float:
	return get_stat_modifier_in_range(critical_multiplier_range)

func get_random_durability_modifier() -> float:
	return get_stat_modifier_in_range(durability_modifier_range)

func get_random_mana_cost_modifier() -> float:
	return get_stat_modifier_in_range(mana_cost_modifier_range)

func get_random_accuracy_modifier() -> float:
	return get_stat_modifier_in_range(accuracy_modifier_range)

func get_rarity_display_name() -> String:
	"""Get formatted rarity name with color coding"""
	return "[color=#%s]%s[/color]" % [rarity_color.to_html(), rarity_name]

func is_negative_rarity() -> bool:
	"""Check if this is a negative rarity (Broken or Poor)"""
	return rarity_grade <= 1

func get_rarity_probability() -> float:
	"""Get drop probability for this rarity grade"""
	match rarity_grade:
		0: return 0.05  # 5% - Broken
		1: return 0.15  # 15% - Poor
		2: return 0.40  # 40% - Common
		3: return 0.25  # 25% - Uncommon
		4: return 0.10  # 10% - Rare
		5: return 0.04  # 4% - Epic
		6: return 0.008 # 0.8% - Legendary
		7: return 0.001 # 0.1% - Mythic
		8: return 0.0005 # 0.05% - Divine
		9: return 0.0001 # 0.01% - Transcendent
		_: return 0.40  # Default to Common