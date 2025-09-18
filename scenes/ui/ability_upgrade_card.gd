extends PanelContainer

signal selected

@onready var name_label: Label = $%NameLabel
@onready var description_label: Label = $%DescriptionLabel
@onready var animation_player = $AnimationPlayer
@onready var hover_animation_player = $HoverAnimationPlayer

var disabled = false


func play_in(delay: float = 0):
	modulate = Color.TRANSPARENT
	await get_tree().create_timer(delay).timeout
	animation_player.play("in")
	
func play_discard():
	animation_player.play("discard")
	
func select_card():
	disabled = true
	
	for other_card in get_tree().get_nodes_in_group("upgrade_card"):
		if other_card == self:
			continue
		other_card.play_discard()
	
	animation_player.play("selected")
	await animation_player.animation_finished
	selected.emit()	
	
func _ready():
	gui_input.connect(on_gui_input)
	mouse_entered.connect(on_mouse_entered)

func set_ability_upgrade(upgrade: AbilityUpgrade):
	name_label.text = upgrade.name
	
	# Get current upgrades from the upgrade manager
	var upgrade_manager = get_tree().get_first_node_in_group("upgrade_manager")
	var current_upgrades = {}
	if upgrade_manager != null:
		current_upgrades = upgrade_manager.current_upgrades
	
	# Calculate before/after values based on upgrade type
	var enhanced_description = upgrade.description
	
	if upgrade.id.contains("damage"):
		var current_quantity = 0
		if current_upgrades.has(upgrade.id):
			current_quantity = current_upgrades[upgrade.id]["quantity"]
		
		# Different damage calculation for different abilities
		var damage_increase_per_level = 0.1  # Default 10%
		if upgrade.id == "sword_damage":
			damage_increase_per_level = 0.15  # Sword damage increases by 15%
		# axe_damage, double_sword_damage use default 10%
		
		var current_multiplier = 1 + (current_quantity * damage_increase_per_level)
		var new_multiplier = 1 + ((current_quantity + 1) * damage_increase_per_level)
		
		# Convert to percentage for display
		var current_percent = int((current_multiplier - 1) * 100)
		var new_percent = int((new_multiplier - 1) * 100)
		
		enhanced_description += "\n[color=#00ff00]%d%% -> %d%%[/color]" % [current_percent, new_percent]
		
	elif upgrade.id.contains("rate"):
		var current_quantity = 0
		if current_upgrades.has(upgrade.id):
			current_quantity = current_upgrades[upgrade.id]["quantity"]
		
		# Rate upgrades reduce wait time by 10% per level
		var current_reduction = current_quantity * 0.1
		var new_reduction = (current_quantity + 1) * 0.1
		
		# Convert to percentage for display (showing speed increase)
		var current_speed_increase = int(current_reduction * 100)
		var new_speed_increase = int(new_reduction * 100)
		
		enhanced_description += "\n[color=#00ff00]+%d%% -> +%d%% Speed[/color]" % [current_speed_increase, new_speed_increase]
		
	elif upgrade.id == "player_speed":
		var current_quantity = 0
		if current_upgrades.has(upgrade.id):
			current_quantity = current_upgrades[upgrade.id]["quantity"]
		
		# Player speed increases by 10% per level
		var current_speed_increase = current_quantity * 10
		var new_speed_increase = (current_quantity + 1) * 10
		
		enhanced_description += "\n[color=#00ff00]+%d%% -> +%d%% Speed[/color]" % [current_speed_increase, new_speed_increase]
	
	# For any other upgrade types, just show the original description
	# This handles new ability unlocks and any unknown upgrade types gracefully
	
	description_label.text = enhanced_description


func on_gui_input(event: InputEvent):
	if disabled: 
		return
	if event.is_action_pressed("left_click"):
		select_card()

func on_mouse_entered():
	if disabled:
		return
	hover_animation_player.play("hover")
