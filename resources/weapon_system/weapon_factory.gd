extends Resource
class_name WeaponFactory

## Factory class for generating weapon instances with rarity, condition, and stats
## Handles all weapon creation logic and integrates with existing upgrade system

# Weapon rarity definitions (loaded from resources)
var rarity_resources: Array[WeaponRarity] = []
var condition_resources: Array[WeaponCondition] = []

# Weighted tables for random generation
var rarity_table: WeightedTable
var condition_table: WeightedTable

func _init() -> void:
	# Initialize empty arrays - resources will be loaded lazily
	rarity_resources = []
	condition_resources = []

func _ensure_resources_loaded() -> void:
	"""Ensure rarity and condition resources are loaded"""
	if rarity_resources.is_empty():
		_load_rarity_resources()
	if condition_resources.is_empty():
		_load_condition_resources()
	if not rarity_table or not condition_table:
		_setup_weighted_tables()

func _load_rarity_resources() -> void:
	"""Load all rarity resources from the file system"""
	# This would be replaced with actual resource loading in a real implementation
	# For now, create default rarities programmatically
	_create_default_rarity_resources()

func _load_condition_resources() -> void:
	"""Load all condition resources from the file system"""
	# Create default conditions programmatically
	_create_default_condition_resources()

func _create_default_rarity_resources() -> void:
	"""Create the 10 default rarity grades"""
	var rarity_data = [
		{"id": "common", "name": "Common", "grade": 1, "color": Color.WHITE, "weight": 100},
		{"id": "uncommon", "name": "Uncommon", "grade": 2, "color": Color.GREEN, "weight": 70},
		{"id": "rare", "name": "Rare", "grade": 3, "color": Color.BLUE, "weight": 50},
		{"id": "epic", "name": "Epic", "grade": 4, "color": Color.PURPLE, "weight": 30},
		{"id": "legendary", "name": "Legendary", "grade": 5, "color": Color.ORANGE, "weight": 20},
		{"id": "mythic", "name": "Mythic", "grade": 6, "color": Color.RED, "weight": 15},
		{"id": "divine", "name": "Divine", "grade": 7, "color": Color(1.0, 0.843, 0.0), "weight": 10},
		{"id": "cosmic", "name": "Cosmic", "grade": 8, "color": Color.CYAN, "weight": 7},
		{"id": "transcendent", "name": "Transcendent", "grade": 9, "color": Color.MAGENTA, "weight": 5},
		{"id": "omnipotent", "name": "Omnipotent", "grade": 10, "color": Color.YELLOW, "weight": 2}
	]
	
	for data in rarity_data:
		var rarity = WeaponRarity.new()
		rarity.id = data.id
		rarity.name = data.name
		rarity.grade = data.grade
		rarity.color = data.color
		rarity.drop_weight = data.weight
		rarity.description = "Grade " + str(data.grade) + " weapon rarity"
		rarity.max_upgrade_level = data.grade * 10
		rarity.stat_range_multiplier = data.grade * 0.2
		rarity.stat_count_min = 1 + (data.grade - 1) / 3  # More stats at higher grades
		rarity.stat_count_max = 3 + (data.grade - 1) / 2
		rarity.trade_value_multiplier = data.grade * 1.5
		
		rarity_resources.append(rarity)

func _create_default_condition_resources() -> void:
	"""Create default weapon conditions"""
	var condition_data = [
		{"id": "worn", "name": "Worn", "damage_mod": 0.8, "speed_mod": 0.9, "value_mod": 0.6, "suffix": "Worn", "weight": 25},
		{"id": "used", "name": "Used", "damage_mod": 0.9, "speed_mod": 0.95, "value_mod": 0.8, "suffix": "Used", "weight": 35},
		{"id": "good", "name": "Good", "damage_mod": 1.0, "speed_mod": 1.0, "value_mod": 1.0, "suffix": "", "weight": 30},
		{"id": "new", "name": "New", "damage_mod": 1.1, "speed_mod": 1.05, "value_mod": 1.3, "suffix": "New", "weight": 8},
		{"id": "pristine", "name": "Pristine", "damage_mod": 1.2, "speed_mod": 1.1, "value_mod": 1.8, "suffix": "Pristine", "weight": 2}
	]
	
	for data in condition_data:
		var condition = WeaponCondition.new()
		condition.id = data.id
		condition.name = data.name
		condition.damage_modifier = data.damage_mod
		condition.speed_modifier = data.speed_mod
		condition.trade_value_modifier = data.value_mod
		condition.condition_suffix = data.suffix
		condition.description = "Weapon in " + data.name.to_lower() + " condition"
		
		# Add visual tint based on condition
		match data.id:
			"worn":
				condition.visual_tint = Color(0.7, 0.7, 0.7, 1.0)  # Darker
			"used":
				condition.visual_tint = Color(0.9, 0.9, 0.9, 1.0)  # Slightly darker
			"good":
				condition.visual_tint = Color.WHITE
			"new":
				condition.visual_tint = Color(1.1, 1.1, 1.1, 1.0)  # Slightly brighter
			"pristine":
				condition.visual_tint = Color(1.2, 1.2, 1.2, 1.0)  # Much brighter
		
		condition_resources.append(condition)
		# Store weight for weighted table (we'll add this in setup)

func _setup_weighted_tables() -> void:
	"""Setup weighted tables for random generation"""
	rarity_table = WeightedTable.new()
	condition_table = WeightedTable.new()
	
	# Add rarities to weighted table
	for rarity in rarity_resources:
		rarity_table.add_item(rarity, rarity.drop_weight)
	
	# Add conditions to weighted table with weights from condition data
	var condition_weights = [25, 35, 30, 8, 2]  # worn, used, good, new, pristine
	for i in range(condition_resources.size()):
		if i < condition_weights.size():
			condition_table.add_item(condition_resources[i], condition_weights[i])

func generate_weapon_instance(weapon_id: String, force_rarity: WeaponRarity = null, force_condition: WeaponCondition = null) -> WeaponInstance:
	"""Generate a new weapon instance with random or specified rarity and condition"""
	_ensure_resources_loaded()
	
	var rarity = force_rarity if force_rarity else rarity_table.pick_item() as WeaponRarity
	var condition = force_condition if force_condition else condition_table.pick_item() as WeaponCondition
	
	var weapon_instance = WeaponInstance.new(weapon_id, rarity, condition)
	
	# Emit event for weapon generation
	if GameEvents.has_signal("weapon_instance_created"):
		GameEvents.emit_weapon_instance_created(weapon_instance)
	
	return weapon_instance

func generate_weapon_drop(weapon_id: String, player_level: int = 1) -> WeaponInstance:
	"""Generate a weapon drop with level-based rarity scaling"""
	_ensure_resources_loaded()
	
	# Higher player levels have better chances at rare weapons
	var modified_rarity_table = WeightedTable.new()
	
	for rarity in rarity_resources:
		var weight = rarity.drop_weight
		# Increase rare weapon chances at higher levels
		if rarity.grade > 5:
			weight *= (1.0 + player_level * 0.1)
		modified_rarity_table.add_item(rarity, weight)
	
	var rarity = modified_rarity_table.pick_item() as WeaponRarity
	var condition = condition_table.pick_item() as WeaponCondition
	
	return WeaponInstance.new(weapon_id, rarity, condition)

func get_rarity_by_id(rarity_id: String) -> WeaponRarity:
	"""Get rarity resource by ID"""
	_ensure_resources_loaded()
	
	for rarity in rarity_resources:
		if rarity.id == rarity_id:
			return rarity
	return null

func get_condition_by_id(condition_id: String) -> WeaponCondition:
	"""Get condition resource by ID"""
	_ensure_resources_loaded()
	
	for condition in condition_resources:
		if condition.id == condition_id:
			return condition
	return null

func get_all_rarities() -> Array[WeaponRarity]:
	"""Get all available rarity resources"""
	_ensure_resources_loaded()
	return rarity_resources.duplicate()

func get_all_conditions() -> Array[WeaponCondition]:
	"""Get all available condition resources"""
	_ensure_resources_loaded()
	return condition_resources.duplicate()

func validate_weapon_instance(weapon_instance: WeaponInstance) -> bool:
	"""Validate a weapon instance for correctness"""
	if not weapon_instance:
		return false
	
	if not weapon_instance.rarity or not weapon_instance.condition:
		return false
	
	# Validate stat ranges
	var stat_range = weapon_instance.rarity.get_stat_range()
	for stat in weapon_instance.stats:
		if stat.base_value < stat_range.x - 10 or stat.base_value > stat_range.y + 10:
			# Allow some variance for random effects
			return false
	
	# Validate upgrade level
	if weapon_instance.current_upgrade_level > weapon_instance.get_max_upgrade_level():
		return false
	
	return true