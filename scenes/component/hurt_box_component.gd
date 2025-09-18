extends Area2D
class_name HurtboxComponent

signal hit

@export var health_component: HealthComponent

func _ready():
	area_entered.connect(on_area_entered)

func on_area_entered(other_area: Area2D):
	if not other_area is HitboxComponent:
		return
	
	if health_component == null:
		return
	
	var hitbox_component = other_area as HitboxComponent
	health_component.damage(hitbox_component.damage)
	
	# Use event system for floating text instead of direct layer access
	var format_string = "%0.2f"
	var damage_text = format_string % hitbox_component.damage
	GameEvents.emit_floating_text_requested(damage_text, global_position + (Vector2.UP * 16))
	
	hit.emit()
