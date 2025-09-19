extends Control
class_name WeaponDisplayCard

## UI component for displaying weapon instance information
## Shows rarity, condition, stats, and upgrade level

@export var weapon_instance: WeaponInstance : set = set_weapon_instance
@onready var name_label: Label = $VBoxContainer/NameLabel
@onready var rarity_label: Label = $VBoxContainer/RarityLabel
@onready var condition_label: Label = $VBoxContainer/ConditionLabel
@onready var level_label: Label = $VBoxContainer/LevelLabel
@onready var stats_container: VBoxContainer = $VBoxContainer/StatsContainer
@onready var dps_label: Label = $VBoxContainer/DPSLabel
@onready var value_label: Label = $VBoxContainer/ValueLabel

func set_weapon_instance(value: WeaponInstance) -> void:
	weapon_instance = value
	if is_node_ready():
		_update_display()

func _ready() -> void:
	if weapon_instance:
		_update_display()

func _update_display() -> void:
	"""Update all display elements with weapon instance data"""
	if not weapon_instance:
		return
	
	_update_name_and_rarity()
	_update_condition()
	_update_level()
	_update_stats()
	_update_performance()

func _update_name_and_rarity() -> void:
	"""Update weapon name and rarity display"""
	if name_label:
		name_label.text = weapon_instance.base_weapon_id.capitalize()
		name_label.modulate = weapon_instance.rarity.color
	
	if rarity_label:
		rarity_label.text = "Rarity: " + weapon_instance.rarity.name + " (Grade " + str(weapon_instance.rarity.grade) + ")"
		rarity_label.modulate = weapon_instance.rarity.color

func _update_condition() -> void:
	"""Update condition display"""
	if condition_label:
		condition_label.text = "Condition: " + weapon_instance.condition.name
		
		# Color based on condition quality
		match weapon_instance.condition.id:
			"worn":
				condition_label.modulate = Color.GRAY
			"used":
				condition_label.modulate = Color.LIGHT_GRAY
			"good":
				condition_label.modulate = Color.WHITE
			"new":
				condition_label.modulate = Color.LIGHT_GREEN
			"pristine":
				condition_label.modulate = Color.GREEN

func _update_level() -> void:
	"""Update upgrade level display"""
	if level_label:
		var level_text = "Level: %d / %d" % [weapon_instance.current_upgrade_level, weapon_instance.get_max_upgrade_level()]
		level_label.text = level_text

func _update_stats() -> void:
	"""Update stats display"""
	if not stats_container:
		return
	
	# Clear existing stat labels
	for child in stats_container.get_children():
		child.queue_free()
	
	# Add stat labels
	for stat in weapon_instance.stats:
		var stat_label = Label.new()
		stat_label.text = stat.display_name + ": " + stat.get_display_value()
		stat_label.modulate = stat.get_display_color()
		stats_container.add_child(stat_label)

func _update_performance() -> void:
	"""Update DPS and trade value display"""
	if dps_label:
		dps_label.text = "DPS: %.1f" % weapon_instance.get_total_dps()
	
	if value_label:
		value_label.text = "Value: %.0f" % weapon_instance.get_trade_value()

func create_tooltip() -> String:
	"""Create detailed tooltip text"""
	if not weapon_instance:
		return ""
	
	return weapon_instance.get_description()

# Optional: Add hover effects
func _on_mouse_entered() -> void:
	"""Handle mouse enter for hover effects"""
	modulate = Color(1.1, 1.1, 1.1, 1.0)

func _on_mouse_exited() -> void:
	"""Handle mouse exit for hover effects"""
	modulate = Color.WHITE