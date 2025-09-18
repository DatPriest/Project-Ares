extends BaseEnemy

@export var arrow_scene: PackedScene
@onready var timer = $Timer

# Distance the archer wants to maintain from player
var ideal_distance = 200.0 
# Speed of the arrows
var arrow_speed = 300.0 

var cached_player_position = Vector2.ZERO

func _ready():
	super._ready()
	
	# Connect to player position updates instead of direct access
	GameEvents.player_position_updated.connect(on_player_position_updated)
	
	# Connect timer signal
	timer.timeout.connect(_on_timer_timeout)
	timer.start()

func on_player_position_updated(player_position: Vector2):
	cached_player_position = player_position

# Override the base _process to implement archer behavior
func _process(delta):
	if cached_player_position == Vector2.ZERO:
		return

	var direction_to_player = global_position.direction_to(cached_player_position)
	var distance_to_player = global_position.distance_to(cached_player_position)

	if distance_to_player < ideal_distance:
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
	if cached_player_position != Vector2.ZERO and arrow_scene != null:
		# Calculate direction and velocity
		var direction = global_position.direction_to(cached_player_position)
		var arrow_velocity = direction * arrow_speed
		
		# Use event system for projectile spawning instead of direct layer access
		GameEvents.emit_projectile_spawn_requested(arrow_scene, global_position, arrow_velocity)