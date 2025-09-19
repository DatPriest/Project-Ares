extends Node
class_name WeaponSystemManager

## Manages the weapon rarity, condition, and stat system
## Integrates with existing UpgradeManager and provides weapon instance management

@export var upgrade_manager: Node
var weapon_factory: WeaponFactory
var player_weapon_instances: Dictionary = {}  # weapon_id -> WeaponInstance
var discovered_rarities: Array[String] = []

func _ready() -> void:
	weapon_factory = WeaponFactory.new()
	_connect_game_events()
	_initialize_default_weapons()

func _connect_game_events() -> void:
	"""Connect to relevant game events"""
	GameEvents.ability_upgrade_added.connect(_on_ability_upgrade_added)
	GameEvents.weapon_instance_created.connect(_on_weapon_instance_created)

func _initialize_default_weapons() -> void:
	"""Initialize default weapon instances for existing weapons"""
	var default_weapons = ["sword", "axe", "bow", "magic_staff", "shield", "double_sword"]
	
	for weapon_id in default_weapons:
		if not player_weapon_instances.has(weapon_id):
			# Create a common rarity weapon instance for existing weapons
			var common_rarity = weapon_factory.get_rarity_by_id("common")
			var good_condition = weapon_factory.get_condition_by_id("good")
			var weapon_instance = WeaponInstance.new(weapon_id, common_rarity, good_condition)
			player_weapon_instances[weapon_id] = weapon_instance

func _on_ability_upgrade_added(upgrade: AbilityUpgrade, current_upgrades: Dictionary) -> void:
	"""Handle weapon upgrades from the existing upgrade system"""
	# Check if this is a weapon upgrade and apply it to our weapon instance
	var weapon_id = _extract_weapon_id_from_upgrade(upgrade)
	if weapon_id == "":
		return
	
	# Get or create weapon instance
	var weapon_instance = get_weapon_instance(weapon_id)
	if not weapon_instance:
		weapon_instance = _create_weapon_instance_for_upgrade(upgrade, weapon_id)
		player_weapon_instances[weapon_id] = weapon_instance
	
	# Apply upgrade based on upgrade type
	_apply_upgrade_to_weapon_instance(upgrade, weapon_instance, current_upgrades)

func _extract_weapon_id_from_upgrade(upgrade: AbilityUpgrade) -> String:
	"""Extract weapon ID from upgrade ID"""
	var upgrade_id = upgrade.id
	
	# Handle base weapons
	if upgrade_id in ["sword", "axe", "bow", "magic_staff", "shield", "double_sword"]:
		return upgrade_id
	
	# Handle weapon upgrades (e.g., "sword_damage", "bow_rate")
	var parts = upgrade_id.split("_")
	if parts.size() >= 2:
		var potential_weapon = parts[0]
		if potential_weapon in ["sword", "axe", "bow", "magic", "shield", "double"]:
			if potential_weapon == "magic":
				return "magic_staff"
			elif potential_weapon == "double":
				return "double_sword"
			else:
				return potential_weapon
	
	return ""

func _create_weapon_instance_for_upgrade(upgrade: AbilityUpgrade, weapon_id: String) -> WeaponInstance:
	"""Create a weapon instance when first acquiring a weapon"""
	# For new weapon acquisitions, generate a random rarity/condition
	var player_level = _get_current_player_level()
	var weapon_instance = weapon_factory.generate_weapon_drop(weapon_id, player_level)
	
	# Announce new rarity discovery
	if not weapon_instance.rarity.id in discovered_rarities:
		discovered_rarities.append(weapon_instance.rarity.id)
		GameEvents.emit_weapon_rarity_discovered(weapon_instance.rarity)
		_show_rarity_discovery_notification(weapon_instance.rarity)
	
	return weapon_instance

func _apply_upgrade_to_weapon_instance(upgrade: AbilityUpgrade, weapon_instance: WeaponInstance, current_upgrades: Dictionary) -> void:
	"""Apply upgrade effects to weapon instance"""
	var upgrade_id = upgrade.id
	
	# Handle damage upgrades
	if upgrade_id.ends_with("_damage"):
		_upgrade_weapon_stat(weapon_instance, WeaponStat.StatType.DAMAGE, current_upgrades, upgrade_id)
	
	# Handle rate upgrades
	elif upgrade_id.ends_with("_rate"):
		_upgrade_weapon_stat(weapon_instance, WeaponStat.StatType.FIRE_RATE, current_upgrades, upgrade_id)
	
	# Handle other specific upgrades
	elif upgrade_id.ends_with("_multishot") or upgrade_id.ends_with("_count"):
		_upgrade_weapon_stat(weapon_instance, WeaponStat.StatType.PROJECTILE_COUNT, current_upgrades, upgrade_id)
	
	elif upgrade_id.ends_with("_aoe"):
		_upgrade_weapon_stat(weapon_instance, WeaponStat.StatType.AREA_OF_EFFECT, current_upgrades, upgrade_id)
	
	# For base weapon acquisition, just ensure the weapon instance exists
	elif upgrade_id in ["sword", "axe", "bow", "magic_staff", "shield", "double_sword"]:
		# Weapon instance already created, just log
		print("Acquired weapon: " + weapon_instance.get_description())

func _upgrade_weapon_stat(weapon_instance: WeaponInstance, stat_type: WeaponStat.StatType, current_upgrades: Dictionary, upgrade_id: String) -> void:
	"""Upgrade a specific stat on a weapon instance"""
	if not current_upgrades.has(upgrade_id):
		return
	
	var upgrade_quantity = current_upgrades[upgrade_id]["quantity"]
	
	# Find existing stat or create new one
	var target_stat: WeaponStat = null
	for stat in weapon_instance.stats:
		if stat.stat_type == stat_type:
			target_stat = stat
			break
	
	if not target_stat:
		# Create new stat if it doesn't exist
		target_stat = WeaponStat.new(stat_type, 0.0)
		weapon_instance.stats.append(target_stat)
	
	# Apply upgrade bonus based on existing system
	var bonus_percent = upgrade_quantity * 0.15  # 15% per level (matching existing system)
	if stat_type == WeaponStat.StatType.FIRE_RATE:
		bonus_percent = upgrade_quantity * 0.10  # 10% per level for rate
	
	target_stat.current_value = target_stat.base_value * (1.0 + bonus_percent)
	
	# Emit upgrade event
	GameEvents.emit_weapon_instance_upgraded(weapon_instance, upgrade_quantity)

func get_weapon_instance(weapon_id: String) -> WeaponInstance:
	"""Get weapon instance by weapon ID"""
	return player_weapon_instances.get(weapon_id, null)

func get_all_weapon_instances() -> Array[WeaponInstance]:
	"""Get all player weapon instances"""
	var instances: Array[WeaponInstance] = []
	for weapon_instance in player_weapon_instances.values():
		instances.append(weapon_instance)
	return instances

func get_weapon_dps(weapon_id: String) -> float:
	"""Get DPS for a specific weapon"""
	var weapon_instance = get_weapon_instance(weapon_id)
	if weapon_instance:
		return weapon_instance.get_total_dps()
	return 0.0

func get_total_dps() -> float:
	"""Get total DPS across all weapons"""
	var total = 0.0
	for weapon_instance in player_weapon_instances.values():
		total += weapon_instance.get_total_dps()
	return total

func _get_current_player_level() -> int:
	"""Get current player level from experience manager"""
	if upgrade_manager and upgrade_manager.has_method("get_current_level"):
		return upgrade_manager.get_current_level()
	
	# Fallback: try to get from experience manager
	var experience_manager = get_tree().get_first_node_in_group("experience_manager")
	if experience_manager and experience_manager.has_method("get_current_level"):
		return experience_manager.get_current_level()
	
	return 1  # Default fallback

func _show_rarity_discovery_notification(rarity: WeaponRarity) -> void:
	"""Show notification for discovering new rarity"""
	var message = "Discovered " + rarity.name + " Rarity!"
	print(message)  # In a real game, this would show a UI notification
	
	# You could emit a GameEvent here for UI systems to handle
	GameEvents.emit_floating_text_requested(message, Vector2.ZERO)

func _on_weapon_instance_created(weapon_instance: WeaponInstance) -> void:
	"""Handle weapon instance creation events"""
	print("New weapon instance created: " + weapon_instance.display_name)

func create_random_weapon_drop(weapon_id: String) -> WeaponInstance:
	"""Create a random weapon drop (for loot system integration)"""
	var player_level = _get_current_player_level()
	return weapon_factory.generate_weapon_drop(weapon_id, player_level)

func get_weapon_factory() -> WeaponFactory:
	"""Get the weapon factory for external use"""
	return weapon_factory

func save_weapon_data() -> Dictionary:
	"""Save weapon system data for persistence"""
	var save_data = {
		"weapon_instances": {},
		"discovered_rarities": discovered_rarities
	}
	
	for weapon_id in player_weapon_instances:
		var weapon_instance = player_weapon_instances[weapon_id]
		save_data.weapon_instances[weapon_id] = {
			"id": weapon_instance.id,
			"base_weapon_id": weapon_instance.base_weapon_id,
			"rarity_id": weapon_instance.rarity.id,
			"condition_id": weapon_instance.condition.id,
			"current_upgrade_level": weapon_instance.current_upgrade_level,
			"upgrade_experience": weapon_instance.upgrade_experience
		}
	
	return save_data

func load_weapon_data(save_data: Dictionary) -> void:
	"""Load weapon system data from persistence"""
	if save_data.has("discovered_rarities"):
		discovered_rarities = save_data.discovered_rarities
	
	if save_data.has("weapon_instances"):
		for weapon_id in save_data.weapon_instances:
			var weapon_data = save_data.weapon_instances[weapon_id]
			var rarity = weapon_factory.get_rarity_by_id(weapon_data.rarity_id)
			var condition = weapon_factory.get_condition_by_id(weapon_data.condition_id)
			
			if rarity and condition:
				var weapon_instance = WeaponInstance.new(weapon_data.base_weapon_id, rarity, condition)
				weapon_instance.id = weapon_data.id
				weapon_instance.current_upgrade_level = weapon_data.current_upgrade_level
				weapon_instance.upgrade_experience = weapon_data.upgrade_experience
				player_weapon_instances[weapon_id] = weapon_instance