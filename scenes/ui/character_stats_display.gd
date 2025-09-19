extends Control
class_name CharacterStatsDisplay

## UI component for displaying character stats
## Shows current stat values with proper formatting and colors

@onready var stats_container: VBoxContainer = $ScrollContainer/VBoxContainer
@export var character_stats_component: CharacterStatsComponent : set = set_character_stats_component

func set_character_stats_component(value: CharacterStatsComponent) -> void:
	if character_stats_component:
		character_stats_component.stat_changed.disconnect(_on_stat_changed)
		character_stats_component.stats_recalculated.disconnect(_update_display)
	
	character_stats_component = value
	
	if character_stats_component:
		character_stats_component.stat_changed.connect(_on_stat_changed)
		character_stats_component.stats_recalculated.connect(_update_display)
		if is_node_ready():
			_update_display()

func _ready() -> void:
	if character_stats_component:
		_update_display()

func _update_display() -> void:
	"""Update the complete stats display"""
	if not character_stats_component or not stats_container:
		return
	
	# Clear existing stat labels
	for child in stats_container.get_children():
		child.queue_free()
	
	# Add stat labels for display-worthy stats
	var display_stats = character_stats_component.get_stats_for_display()
	for stat in display_stats:
		_create_stat_label(stat)

func _create_stat_label(stat: CharacterStat) -> void:
	"""Create a label for a single stat"""
	var stat_label = Label.new()
	stat_label.text = stat.display_name + ": " + stat.get_display_value()
	stat_label.modulate = stat.get_display_color()
	stat_label.add_theme_font_size_override("font_size", 12)
	stats_container.add_child(stat_label)

func _on_stat_changed(stat: CharacterStat) -> void:
	"""Handle individual stat changes for efficient updates"""
	# For now, just refresh the whole display
	# Could be optimized to update only the changed stat label
	_update_display()