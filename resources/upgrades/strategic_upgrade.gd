extends AbilityUpgrade
class_name StrategicUpgrade

# Prerequisites that must be met before this upgrade becomes available
@export var prerequisite_upgrades: Array[String] = []
@export var minimum_level: int = 1
@export var requires_multiplayer: bool = false

# Strategic path - mutually exclusive upgrades
@export var mutually_exclusive_with: Array[String] = []

# Check if all prerequisites are met
func can_unlock(current_upgrades: Dictionary, player_level: int, is_multiplayer: bool) -> bool:
	# Check level requirement
	if player_level < minimum_level:
		return false
	
	# Check multiplayer requirement
	if requires_multiplayer and not is_multiplayer:
		return false
	
	# Check prerequisites
	for prereq_id in prerequisite_upgrades:
		if not current_upgrades.has(prereq_id):
			return false
	
	# Check mutually exclusive upgrades
	for exclusive_id in mutually_exclusive_with:
		if current_upgrades.has(exclusive_id):
			return false
	
	return true

func get_unlock_conditions_text(current_upgrades: Dictionary, player_level: int, is_multiplayer: bool) -> String:
	var conditions: Array[String] = []
	
	if player_level < minimum_level:
		conditions.append("Requires level %d" % minimum_level)
	
	if requires_multiplayer and not is_multiplayer:
		conditions.append("Multiplayer only")
	
	for prereq_id in prerequisite_upgrades:
		if not current_upgrades.has(prereq_id):
			conditions.append("Requires " + prereq_id.replace("_", " ").capitalize())
	
	for exclusive_id in mutually_exclusive_with:
		if current_upgrades.has(exclusive_id):
			conditions.append("Conflicts with " + exclusive_id.replace("_", " ").capitalize())
	
	if conditions.is_empty():
		return "Available"
	else:
		return "Missing: " + ", ".join(conditions)