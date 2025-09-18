extends Node
class_name DamageComponent

signal damage_taken(amount: float)
signal died

@export var health_component: HealthComponent
@export var experience_reward: float = 1.0

var floating_text_scene = preload("res://scenes/ui/floating_text.tscn")

func _ready() -> void:
	if health_component == null:
		push_error("DamageComponent: health_component must be assigned!")
		return
	
	# Connect to health component's died signal to emit centralized events
	health_component.died.connect(_on_health_component_died)

func apply_damage(damage_amount: float, damage_position: Vector2 = Vector2.ZERO) -> void:
	if health_component == null:
		return
	
	# Apply damage to health component
	health_component.damage(damage_amount)
	
	# Show floating damage text
	_show_floating_text(damage_amount, damage_position)
	
	# Emit local damage signal
	damage_taken.emit(damage_amount)

func _show_floating_text(damage_amount: float, position: Vector2) -> void:
	var floating_text = floating_text_scene.instantiate() as Node2D
	var foreground_layer = get_tree().get_first_node_in_group("foreground_layer")
	
	if foreground_layer == null:
		return
	
	foreground_layer.add_child(floating_text)
	
	# Use provided position or fallback to owner's position
	var text_position = position
	if text_position == Vector2.ZERO and owner is Node2D:
		text_position = (owner as Node2D).global_position
	
	floating_text.global_position = text_position + (Vector2.UP * 16)
	
	var format_string = "%0.2f"
	floating_text.start(format_string % damage_amount)

func _on_health_component_died() -> void:
	# Emit standardized enemy death event via GameEvents
	GameEvents.emit_enemy_killed(experience_reward)
	
	# Emit local died signal for any components that need it
	died.emit()