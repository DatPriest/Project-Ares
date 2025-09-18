extends Node2D
class_name ShieldOrb

@onready var hitbox_component: HitboxComponent = $HitboxComponent
@onready var sprite: Sprite2D = $Sprite2D

var damage_amount: float = 3.0
var target_position: Vector2 = Vector2.ZERO
var lifespan: float = 30.0  # Orbs last 30 seconds before auto-refreshing

func _ready() -> void:
	if hitbox_component:
		hitbox_component.damage = damage_amount
		hitbox_component.hit_hurtbox.connect(_on_hit_hurtbox)
	
	# Auto-destroy after lifespan
	get_tree().create_timer(lifespan).timeout.connect(queue_free)

func set_damage(new_damage: float) -> void:
	damage_amount = new_damage
	if hitbox_component:
		hitbox_component.damage = new_damage

func update_position(new_position: Vector2) -> void:
	target_position = new_position
	
	# Smoothly move towards target position
	var tween = create_tween()
	tween.tween_property(self, "global_position", target_position, 0.1)

func _on_hit_hurtbox(hurtbox_component: HurtboxComponent, attack: Attack) -> void:
	# Shield orbs persist after hitting enemies (unlike arrows)
	# Could add visual effect here
	if sprite:
		var tween = create_tween()
		tween.tween_property(sprite, "modulate", Color.WHITE, 0.1)
		tween.tween_property(sprite, "modulate", Color(0.7, 0.9, 1.0, 1.0), 0.1)