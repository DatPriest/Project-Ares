extends Node2D
class_name ProjectileBurstAttack

@export var projectile_scene: PackedScene
@export var projectile_count: int = 8
@export var burst_radius: float = 300.0
@export var projectile_speed: float = 200.0
@export var damage: float = 15.0
@export var spread_angle: float = 360.0  # Full circle by default

func _ready():
	# Execute the attack immediately when instantiated
	execute_attack()

func execute_attack():
	if projectile_scene == null:
		# Fallback to arrow if no projectile specified
		projectile_scene = preload("res://scenes/game_object/projectiles/arrow.tscn")
	
	var player = get_tree().get_first_node_in_group("player") as Node2D
	if player == null:
		queue_free()
		return
	
	var angle_step = spread_angle / projectile_count
	var start_angle = -spread_angle / 2
	
	for i in projectile_count:
		var angle = start_angle + (i * angle_step)
		var direction = Vector2.RIGHT.rotated(deg_to_rad(angle))
		
		_spawn_projectile(direction)
	
	# Clean up the attack node after spawning projectiles
	queue_free()

func _spawn_projectile(direction: Vector2):
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