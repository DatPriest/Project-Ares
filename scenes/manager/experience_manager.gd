extends Node

signal experience_updated(current_expereince: float, target_experience: float)
signal level_up(new_level: int)

const TARGET_EXPERIENCE_GROWTH = 5

var current_experience: float = 0
var current_level: int = 1
var target_experience: float = 1

func _ready() -> void:
	GameEvents.experience_vial_collected.connect(on_experience_vial_collected)
	
	
func increment_experience(number: float) -> void:
	# Apply character stats experience multiplier if available
	var experience_multiplier = _get_experience_multiplier()
	var modified_experience = number * experience_multiplier
	
	current_experience = min(current_experience + modified_experience, target_experience)
	experience_updated.emit(current_experience, target_experience)
	if current_experience == target_experience:
		current_level += 1
		target_experience += TARGET_EXPERIENCE_GROWTH
		current_experience = 0
		experience_updated.emit(current_experience, target_experience)
		level_up.emit(current_level)

func _get_experience_multiplier() -> float:
	"""Get experience multiplier from player's character stats"""
	var player = get_tree().get_first_node_in_group("player")
	if player and player.has_method("get_character_stats_component"):
		var stats_component = player.get_character_stats_component()
		if stats_component:
			return stats_component.get_experience_multiplier()
	return 1.0  # Default multiplier
		

func on_experience_vial_collected(number: float) -> void:
	increment_experience(number)

func on_kill(number: float) -> void:
	increment_experience(number)
