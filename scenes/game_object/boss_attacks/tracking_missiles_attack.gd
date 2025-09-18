extends Node2D
class_name TrackingMissilesAttack

@export var projectile_scene: PackedScene
@export var missile_count: int = 3
@export var launch_delay: float = 0.5  # Delay between missiles
@export var projectile_speed: float = 150.0
@export var damage: float = 20.0

var missiles_launched: int = 0

func _ready():
	# Start launching missiles with delay
	_launch_next_missile()

func _launch_next_missile():
	if missiles_launched >= missile_count:
		# All missiles launched, clean up
		queue_free()
		return
	
	var player = get_tree().get_first_node_in_group("player") as Node2D
	if player == null:
		queue_free()
		return
	
	# Calculate direction to player
	var direction = global_position.direction_to(player.global_position)
	_spawn_projectile(direction)
	
	missiles_launched += 1
	
	# Schedule next missile
	if missiles_launched < missile_count:
		get_tree().create_timer(launch_delay).timeout.connect(_launch_next_missile)

func _spawn_projectile(direction: Vector2):
	if projectile_scene == null:
		projectile_scene = preload("res://scenes/game_object/projectiles/arrow.tscn")
	
	var projectile = projectile_scene.instantiate()
	
	# Set projectile position
	projectile.global_position = global_position
	
	# Set projectile velocity
	if projectile.has_method("set_velocity"):
		projectile.set_velocity(direction * projectile_speed)
	elif "velocity" in projectile:
		projectile.velocity = direction * projectile_speed
	
	# Set damage if projectile supports it
	if "damage" in projectile:
		projectile.damage = damage
	
	# Add to entities layer
	var entities_layer = get_tree().get_first_node_in_group("entities_layer")
	if entities_layer:
		entities_layer.add_child(projectile)
	else:
		get_parent().add_child(projectile)