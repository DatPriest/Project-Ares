extends Node

@export var experience_manager: Node
@export var upgrade_screen_scene: PackedScene
@export var weapon_system_manager: WeaponSystemManager

var current_upgrades = {
}
var upgrade_pool: WeightedTable = WeightedTable.new()

var upgrade_axe = preload("res://resources/upgrades/axe.tres")
var upgrade_axe_damage = preload("res://resources/upgrades/axe_damage.tres")
var upgrade_axe_rate = preload("res://resources/upgrades/axe_rate.tres")

var upgrade_sword_rate = preload("res://resources/upgrades/sword_rate.tres")
var upgrade_sword_damage = preload("res://resources/upgrades/sword_damage.tres")

var upgrade_player_speed = preload("res://resources/upgrades/player_speed.tres")

var upgrade_double_sword = preload("res://resources/upgrades/double_sword.tres")
var upgrade_double_sword_damage = preload("res://resources/upgrades/double_sword_damage.tres")
var upgrade_double_sword_rate = preload("res://resources/upgrades/double_sword_rate.tres")

# New weapons
var upgrade_bow = preload("res://resources/upgrades/bow.tres")
var upgrade_bow_damage = preload("res://resources/upgrades/bow_damage.tres")
var upgrade_bow_rate = preload("res://resources/upgrades/bow_rate.tres")
var upgrade_bow_multishot = preload("res://resources/upgrades/bow_multishot.tres")

var upgrade_magic_staff = preload("res://resources/upgrades/magic_staff.tres")
var upgrade_magic_staff_damage = preload("res://resources/upgrades/magic_staff_damage.tres")
var upgrade_magic_staff_rate = preload("res://resources/upgrades/magic_staff_rate.tres")
var upgrade_magic_staff_aoe = preload("res://resources/upgrades/magic_staff_aoe.tres")
var upgrade_magic_staff_multicast = preload("res://resources/upgrades/magic_staff_multicast.tres")

# Shield weapon
var upgrade_shield = preload("res://resources/upgrades/shield.tres")
var upgrade_shield_damage = preload("res://resources/upgrades/shield_damage.tres")
var upgrade_shield_count = preload("res://resources/upgrades/shield_count.tres")

# Synergy abilities
var upgrade_flaming_arrows = preload("res://resources/upgrades/flaming_arrows.tres")
var upgrade_elemental_mastery = preload("res://resources/upgrades/elemental_mastery.tres")

# Evolution abilities
var upgrade_evolved_bow = preload("res://resources/upgrades/evolved_bow.tres")
var upgrade_evolved_magic_staff = preload("res://resources/upgrades/evolved_magic_staff.tres")

# Strategic paths
var upgrade_berserker_path = preload("res://resources/upgrades/berserker_path.tres")
var upgrade_archer_path = preload("res://resources/upgrades/archer_path.tres")

# Multiplayer abilities
var upgrade_team_buff_aura = preload("res://resources/upgrades/multiplayer/team_buff_aura.tres")
var upgrade_shared_experience = preload("res://resources/upgrades/multiplayer/shared_experience.tres")
var upgrade_team_shield = preload("res://resources/upgrades/multiplayer/team_shield.tres")

# Character stat upgrades
var upgrade_health_boost = preload("res://resources/upgrades/character_stats/health_boost.tres")
var upgrade_lucky_charm = preload("res://resources/upgrades/character_stats/lucky_charm.tres")
var upgrade_experience_boost = preload("res://resources/upgrades/character_stats/experience_boost.tres")
var upgrade_crit_chance_boost = preload("res://resources/upgrades/character_stats/crit_chance_boost.tres")

func _ready():
	upgrade_pool.add_item(upgrade_axe, 10)
	upgrade_pool.add_item(upgrade_sword_rate, 10)
	upgrade_pool.add_item(upgrade_sword_damage, 10)
	upgrade_pool.add_item(upgrade_player_speed, 5)
	upgrade_pool.add_item(upgrade_double_sword, 5)
	
	# Add new weapons to pool
	upgrade_pool.add_item(upgrade_bow, 10)
	upgrade_pool.add_item(upgrade_magic_staff, 10)
	upgrade_pool.add_item(upgrade_shield, 10)
	
	# Add character stat upgrades to pool
	upgrade_pool.add_item(upgrade_health_boost, 8)
	upgrade_pool.add_item(upgrade_lucky_charm, 6)
	upgrade_pool.add_item(upgrade_experience_boost, 7)
	upgrade_pool.add_item(upgrade_crit_chance_boost, 8)
	
	if experience_manager == null:
		push_error("UpgradeManager: experience_manager is null, level-up upgrades will not work")
		return
		
	experience_manager.level_up.connect(on_level_up)


func update_upgrade_pool(chosen_upgrade: AbilityUpgrade):
	if chosen_upgrade.id == upgrade_axe.id:
		upgrade_pool.add_item(upgrade_axe_damage, 10)
		upgrade_pool.add_item(upgrade_axe_rate, 10)
	elif chosen_upgrade.id == upgrade_double_sword.id:
		upgrade_pool.add_item(upgrade_double_sword_damage, 10)
		upgrade_pool.add_item(upgrade_double_sword_rate, 10)
	elif chosen_upgrade.id == upgrade_bow.id:
		upgrade_pool.add_item(upgrade_bow_damage, 10)
		upgrade_pool.add_item(upgrade_bow_rate, 10)
		upgrade_pool.add_item(upgrade_bow_multishot, 8)
	elif chosen_upgrade.id == upgrade_magic_staff.id:
		upgrade_pool.add_item(upgrade_magic_staff_damage, 10)
		upgrade_pool.add_item(upgrade_magic_staff_rate, 10)
		upgrade_pool.add_item(upgrade_magic_staff_aoe, 8)
		upgrade_pool.add_item(upgrade_magic_staff_multicast, 8)
	elif chosen_upgrade.id == upgrade_shield.id:
		upgrade_pool.add_item(upgrade_shield_damage, 10)
		upgrade_pool.add_item(upgrade_shield_count, 8)
	
	# Check for synergies
	_check_and_add_synergies()

func _check_and_add_synergies():
	# Flaming Arrows synergy (Bow + Magic Staff)
	if current_upgrades.has("bow") and current_upgrades.has("magic_staff"):
		if not current_upgrades.has("flaming_arrows"):
			upgrade_pool.add_item(upgrade_flaming_arrows, 15)  # Higher weight for synergies
	
	# Elemental Mastery synergy (All 3 weapons)
	if current_upgrades.has("bow") and current_upgrades.has("magic_staff") and current_upgrades.has("shield"):
		if not current_upgrades.has("elemental_mastery"):
			upgrade_pool.add_item(upgrade_elemental_mastery, 20)  # Very high weight for ultimate synergy
	
	# Strategic paths (level-gated)
	var player_level = _get_current_player_level()
	var is_multiplayer = _is_multiplayer_game()
	
	_check_strategic_upgrade(upgrade_berserker_path, player_level, is_multiplayer)
	_check_strategic_upgrade(upgrade_archer_path, player_level, is_multiplayer)
	_check_strategic_upgrade(upgrade_evolved_bow, player_level, is_multiplayer)
	_check_strategic_upgrade(upgrade_evolved_magic_staff, player_level, is_multiplayer)
	
	# Multiplayer-specific upgrades
	if is_multiplayer:
		if not current_upgrades.has("team_buff_aura"):
			upgrade_pool.add_item(upgrade_team_buff_aura, 8)
		if not current_upgrades.has("shared_experience"):
			upgrade_pool.add_item(upgrade_shared_experience, 8)
		
		# Advanced multiplayer abilities (require prerequisites)
		_check_strategic_upgrade(upgrade_team_shield, player_level, is_multiplayer)

func _check_strategic_upgrade(upgrade: StrategicUpgrade, player_level: int, is_multiplayer: bool):
	if upgrade.can_unlock(current_upgrades, player_level, is_multiplayer):
		if not current_upgrades.has(upgrade.id):
			upgrade_pool.add_item(upgrade, 12)  # Medium-high weight for strategic paths

func _get_current_player_level() -> int:
	# Get current level from experience manager
	if experience_manager and experience_manager.has_method("get_current_level"):
		return experience_manager.get_current_level()
	return 1

func _is_multiplayer_game() -> bool:
	# Check if this is a multiplayer session
	return multiplayer.get_peers().size() > 0

func apply_upgrade(upgrade: AbilityUpgrade):
	var has_upgrade = current_upgrades.has(upgrade.id)
	if !has_upgrade:
		current_upgrades[upgrade.id] = {
			"resource": upgrade,
			"quantity": 1
		}
	else:
		current_upgrades[upgrade.id]["quantity"] += 1
		
	if upgrade.max_quantity > 0:
		var current_quantity = current_upgrades[upgrade.id]["quantity"]
		if current_quantity == upgrade.max_quantity:
			upgrade_pool.remove_item(upgrade)
	
	# Apply character stat upgrades
	_apply_character_stat_upgrade(upgrade)
			
	update_upgrade_pool(upgrade)
	GameEvents.emit_ability_upgrade_added(upgrade, current_upgrades)

func _apply_character_stat_upgrade(upgrade: AbilityUpgrade) -> void:
	"""Apply character stat modifications based on upgrade type"""
	var player = get_tree().get_first_node_in_group("player")
	if not player or not player.has_method("get_character_stats_component"):
		return
	
	var stats_component = player.get_character_stats_component()
	if not stats_component:
		return
	
	match upgrade.id:
		"health_boost":
			stats_component.modify_stat(CharacterStat.StatType.HEALTH, 25.0)
		"lucky_charm":
			stats_component.modify_stat(CharacterStat.StatType.LUCK, 10.0)
		"experience_boost":
			stats_component.modify_stat(CharacterStat.StatType.EXPERIENCE_GAIN, 15.0)
		"crit_chance_boost":
			stats_component.modify_stat(CharacterStat.StatType.CRITICAL_CHANCE, 8.0)

func on_upgrade_selected(upgrade: AbilityUpgrade):
	apply_upgrade(upgrade)

func pick_upgrades():
	var chosen_upgrades: Array[AbilityUpgrade] = []
	var max_choices = min(3, upgrade_pool.items.size())
	
	for i in max_choices:
		if upgrade_pool.items.size() == chosen_upgrades.size():
			break
		var chosen_upgrade = upgrade_pool.pick_item(chosen_upgrades)
		if chosen_upgrade != null:
			chosen_upgrades.append(chosen_upgrade)
		else:
			break
		
	return chosen_upgrades
	

func on_level_up(current_level: int):
	if upgrade_screen_scene == null:
		push_warning("UpgradeManager: upgrade_screen_scene is null, cannot show upgrade screen")
		return
		
	var chosen_upgrades = pick_upgrades()
	if chosen_upgrades.size() == 0:
		push_warning("UpgradeManager: No upgrades available to show - all upgrades may be maxed out")
		# Could show a different screen or message here, but for now just continue
		return
		
	var upgrade_screen_instance = upgrade_screen_scene.instantiate()
	add_child(upgrade_screen_instance)
	upgrade_screen_instance.set_ability_upgrades(chosen_upgrades as Array[AbilityUpgrade])
	upgrade_screen_instance.upgrade_selected.connect(on_upgrade_selected)
	
