extends Node2D
class_name Fireball

@onready var hitbox_component: HitboxComponent = $HitboxComponent
@onready var animation_player: AnimationPlayer = $AnimationPlayer

@export var aoe_radius: float = 80.0
var damage_amount: float = 6.0

func _ready() -> void:
	if animation_player:
		animation_player.play("explode")
		animation_player.animation_finished.connect(_on_animation_finished)
	
	# Set up hitbox damage
	if hitbox_component:
		hitbox_component.damage = damage_amount
	
	# Queue free as fallback if no animation
	if not animation_player:
		get_tree().create_timer(1.0).timeout.connect(queue_free)

func set_damage(new_damage: float) -> void:
	damage_amount = new_damage
	if hitbox_component:
		hitbox_component.damage = new_damage

func _on_animation_finished() -> void:
	queue_free()