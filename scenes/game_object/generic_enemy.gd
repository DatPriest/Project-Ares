extends BaseEnemy
class_name GenericEnemy

# This class selects the appropriate behavior based on the enemy_data
var behavior_instance: BaseEnemy

func _ready():
	super._ready()
	setup_behavior()

func setup_behavior():
	if enemy_data == null:
		return
		
	match enemy_data.behavior_type:
		"Wizard", "Goblin":
			# Use wizard-like behavior (start/stop movement)
			if has_node("Timer"):
				var timer = get_node("Timer") as Timer
				timer.wait_time = enemy_data.movement_active_duration
				timer.timeout.connect(_on_wizard_timer_timeout)
				timer.start()
				set_meta("is_moving", true)
		"Archer":
			# Use archer behavior (maintain distance and shoot)
			if has_node("Timer"):
				var timer = get_node("Timer") as Timer
				timer.wait_time = enemy_data.shoot_interval
				timer.timeout.connect(_on_archer_timer_timeout)
				timer.start()
		_:
			# Default basic behavior - no additional setup needed
			pass

func _process(delta):
	if enemy_data == null:
		# Default basic behavior when no data is provided
		velocity_component.accelerate_to_player()
		velocity_component.move(self)
		
		var move_sign = sign(velocity.x)
		if move_sign != 0:
			visuals.scale = Vector2(-move_sign, 1)
		return
		
	match enemy_data.behavior_type:
		"Wizard", "Goblin":
			_process_wizard_behavior(delta)
		"Archer":
			_process_archer_behavior(delta)
		_:
			# Default basic behavior
			velocity_component.accelerate_to_player()
			velocity_component.move(self)
			
			var move_sign = sign(velocity.x)
			if move_sign != 0:
				visuals.scale = Vector2(-move_sign, 1)

func _process_wizard_behavior(delta):
	var is_moving = get_meta("is_moving", true)
	
	if is_moving:
		velocity_component.accelerate_to_player()
	else:
		velocity_component.decelerate()
	
	velocity_component.move(self)
	
	var move_sign = sign(velocity.x)
	if move_sign != 0:
		visuals.scale = Vector2(move_sign, 1)

func _process_archer_behavior(delta):
	var player = get_tree().get_first_node_in_group("player") as Node2D
	if player == null:
		return

	var direction_to_player = global_position.direction_to(player.global_position)
	var distance_to_player = global_position.distance_to(player.global_position)

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

func _on_wizard_timer_timeout():
	var is_moving = get_meta("is_moving", true)
	is_moving = !is_moving
	set_meta("is_moving", is_moving)
	
	var timer = get_node("Timer") as Timer
	if is_moving:
		timer.wait_time = enemy_data.movement_active_duration
	else:
		timer.wait_time = enemy_data.movement_pause_duration
		
	timer.start()

func _on_archer_timer_timeout():
	var player = get_tree().get_first_node_in_group("player") as Node2D
	if player != null && enemy_data != null && enemy_data.arrow_scene != null:
		var arrow_instance = enemy_data.arrow_scene.instantiate()
		arrow_instance.global_position = global_position
		
		# Calculate direction and set arrow velocity
		var direction = global_position.direction_to(player.global_position)
		arrow_instance.velocity = direction * enemy_data.arrow_speed
		
		# Add arrow to the entities layer
		var entities_layer = get_tree().get_first_node_in_group("entities_layer")
		if entities_layer:
			entities_layer.add_child(arrow_instance)
		else:
			# Fallback to adding to parent
			get_parent().add_child(arrow_instance)