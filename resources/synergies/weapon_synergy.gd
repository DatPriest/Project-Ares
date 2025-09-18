extends Resource
class_name WeaponSynergy

@export var id: String
@export var name: String
@export_multiline var description: String

# Required weapons/abilities for this synergy
@export var required_abilities: Array[String] = []

# The synergy ability that gets unlocked
@export var synergy_ability: AbilityUpgrade

# Check if player has all required abilities
func can_unlock(current_upgrades: Dictionary) -> bool:
	for ability_id in required_abilities:
		if not current_upgrades.has(ability_id):
			return false
	return true

# Get a description of missing requirements
func get_missing_requirements(current_upgrades: Dictionary) -> Array[String]:
	var missing: Array[String] = []
	for ability_id in required_abilities:
		if not current_upgrades.has(ability_id):
			missing.append(ability_id)
	return missing