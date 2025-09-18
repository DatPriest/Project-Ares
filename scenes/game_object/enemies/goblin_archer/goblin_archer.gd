extends BaseEnemy

@export var arrow_scene: PackedScene
@onready var timer = $Timer

# Distance the archer wants to maintain from player
var ideal_distance = 200.0 
# Speed of the arrows
var arrow_speed = 300.0 

var player: Node2D

func _ready():
	super._ready()
	# Get reference to player
	player = get_tree().get_first_node_in_group("player")
	
	# Connect timer signal
	timer.timeout.connect(_on_timer_timeout)
	timer.start()

func _physics_process(delta):
	if player == null:
		player = get_tree().get_first_node_in_group("player")
		return

	var direction_to_player = global_position.direction_to(player.global_position)
	var distance_to_player = global_position.distance_to(player.global_position)

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
	if player != null and arrow_scene != null:
		var arrow_instance = arrow_scene.instantiate()
		arrow_instance.global_position = global_position
		
		# Calculate direction and set arrow velocity
		var direction = global_position.direction_to(player.global_position)
		arrow_instance.velocity = direction * arrow_speed
		
		# Add arrow to the entities layer
		var entities_layer = get_tree().get_first_node_in_group("entities_layer")
		if entities_layer:
			entities_layer.add_child(arrow_instance)
		else:
			# Fallback to adding to parent
			get_parent().add_child(arrow_instance)