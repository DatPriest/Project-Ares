extends CharacterBody2D
class_name DummyTarget

signal damage_taken(amount: float)

@onready var health_component: HealthComponent = $HealthComponent
@onready var hurt_box_component: HurtboxComponent = $HurtBoxComponent
@onready var collision_shape: CollisionShape2D = $CollisionShape2D
@onready var visuals: Node2D = $Visuals

@export var max_health: float = 1000.0
@export var regenerate_health: bool = true

var total_damage_taken: float = 0.0
var last_hitbox_damage: float = 0.0

func _ready() -> void:
	# Set up health component with very high health for testing
	health_component.max_health = max_health
	health_component.current_health = max_health
	
	# Connect to damage events - we'll override the HurtboxComponent behavior
	hurt_box_component.area_entered.connect(_on_area_entered_override)
	
	# Add to enemy group so abilities can target it
	add_to_group("enemy")

func _on_area_entered_override(other_area: Area2D) -> void:
	"""Override the default hurtbox behavior to track damage better"""
	if not other_area is HitboxComponent:
		return
	
	var hitbox_component = other_area as HitboxComponent
	var damage_amount = hitbox_component.damage
	
	# Track the damage
	total_damage_taken += damage_amount
	damage_taken.emit(damage_amount)
	
	# Apply damage to health component for visual feedback if needed
	if not regenerate_health:
		health_component.damage(damage_amount)
	
	print("Dummy target hit for %.2f damage (Total: %.2f)" % [damage_amount, total_damage_taken])

func reset_damage_counter() -> void:
	"""Reset the damage counter for a new test run"""
	total_damage_taken = 0.0
	health_component.current_health = max_health

func get_total_damage() -> float:
	"""Get the total damage taken since last reset"""
	return total_damage_taken