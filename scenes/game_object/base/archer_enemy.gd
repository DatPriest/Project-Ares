extends BaseEnemy
class_name ArcherEnemy

@onready var timer: Timer = $Timer

var cached_player_position: Vector2 = Vector2.ZERO

func _ready():
	super._ready()
	
	# Connect to player position updates for cached access
	GameEvents.player_position_updated.connect(on_player_position_updated)
	
	# Setup timer based on enemy data
	if timer and enemy_data:
		timer.wait_time = enemy_data.shoot_interval
		timer.timeout.connect(_on_timer_timeout)
		timer.start()

func on_player_position_updated(player_position: Vector2):
	cached_player_position = player_position

# Override the base _process to implement archer behavior
func _process(delta):
	# Use cached player position instead of expensive tree lookup
	if cached_player_position == Vector2.ZERO:
		return

	if enemy_data == null:
		super._process(delta)
		return

	var direction_to_player = global_position.direction_to(cached_player_position)
	var distance_to_player = global_position.distance_to(cached_player_position)

	if distance_to_player < enemy_data.ideal_distance:
		# Run away if player is too close
		velocity_component.accelerate_in_direction(-direction_to_player)
	else:
		# Stop to aim and shoot
		velocity_component.decelerate()
		
	velocity_component.move(self)
	
	# Handle sprite flipping
	var move_sign = sign(velocity.x)
	if move_sign != 0:
		visuals.scale = Vector2(-move_sign, 1)

func _on_timer_timeout():
	# Timer has elapsed, shoot an arrow
	if cached_player_position != Vector2.ZERO and enemy_data != null and enemy_data.arrow_scene != null:
		# Calculate direction and velocity
		var direction = global_position.direction_to(cached_player_position)
		var arrow_velocity = direction * enemy_data.arrow_speed
		
		# Use event system for projectile spawning instead of direct layer access
		GameEvents.emit_projectile_spawn_requested(enemy_data.arrow_scene, global_position, arrow_velocity)