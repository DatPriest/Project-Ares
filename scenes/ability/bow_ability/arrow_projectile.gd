extends Node2D
class_name ArrowProjectile

@onready var hitbox_component: HitboxComponent = $HitboxComponent
@onready var visible_on_screen_notifier: VisibleOnScreenNotifier2D = $VisibleOnScreenNotifier2D

@export var speed: float = 400.0
@export var max_range: float = 500.0
@export var explosion_scene: PackedScene  # For flaming arrows synergy

var direction: Vector2 = Vector2.RIGHT
var traveled_distance: float = 0.0
var is_explosive: bool = false

func _ready() -> void:
	visible_on_screen_notifier.screen_exited.connect(_on_screen_exited)
	if hitbox_component:
		hitbox_component.hit_hurtbox.connect(_on_hit_hurtbox)

func _physics_process(delta: float) -> void:
	var velocity = direction * speed * delta
	global_position += velocity
	traveled_distance += velocity.length()
	
	# Remove arrow if it has traveled too far
	if traveled_distance > max_range:
		queue_free()

func set_direction_and_damage(new_direction: Vector2, damage: float) -> void:
	direction = new_direction.normalized()
	rotation = direction.angle()
	
	if hitbox_component:
		hitbox_component.damage = damage

func set_explosive(explosive: bool) -> void:
	is_explosive = explosive

func _on_hit_hurtbox(hurtbox_component: HurtboxComponent, attack: Attack) -> void:
	# Create explosion if arrow is explosive (flaming arrows synergy)
	if is_explosive and explosion_scene != null:
		var explosion = explosion_scene.instantiate()
		explosion.global_position = global_position
		# Add explosion to main scene tree through proper parent reference
		var main_scene = get_tree().root.get_child(-1)
		main_scene.add_child(explosion)
	
	# Arrow disappears after hitting a target
	queue_free()

func _on_screen_exited() -> void:
	queue_free()