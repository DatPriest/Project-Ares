extends BaseEnemy
class_name GenericEnemy

# This class selects the appropriate behavior based on the enemy_data
var behavior_instance: BaseEnemy

# Boss-specific variables
var current_phase_index: int = 0
var current_phase: BossPhase
var phase_transition_active: bool = false
var boss_health_component: HealthComponent
var boss_network_sync: BossNetworkSyncComponent

func _ready():
	super._ready()
	setup_behavior()
	
	# Connect to death events for boss-specific handling
	if has_node("DamageComponent"):
		var damage_component = get_node("DamageComponent") as DamageComponent
		if damage_component != null:
			damage_component.died.connect(_on_enemy_died)

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
		"Boss":
			# Use boss behavior (phases, special attacks)
			_setup_boss_behavior()
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
		"Boss":
			_process_boss_behavior(delta)
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
	if player != null and enemy_data != null and enemy_data.arrow_scene != null:
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

# Boss-specific behavior functions
func _setup_boss_behavior():
	if not enemy_data.is_boss:
		return
	
	# Get health component reference for phase tracking
	boss_health_component = get_node_or_null("HealthComponent") as HealthComponent
	if boss_health_component == null:
		push_error("Boss enemy requires HealthComponent")
		return
	
	# Set up network synchronization if needed
	if enemy_data.network_sync_required:
		boss_network_sync = get_node_or_null("BossNetworkSyncComponent") as BossNetworkSyncComponent
		if boss_network_sync != null:
			boss_network_sync.boss_data = enemy_data
	
	# Connect to health changes for phase transitions
	boss_health_component.health_changed.connect(_on_boss_health_changed)
	
	# Initialize first phase
	if enemy_data.boss_phases.size() > 0:
		current_phase = enemy_data.boss_phases[0]
		current_phase_index = 0
	
	# Emit boss spawned event
	GameEvents.emit_boss_spawned(enemy_data, self)
	
	# Set up boss-specific timer for attacks
	if has_node("Timer"):
		var timer = get_node("Timer") as Timer
		timer.wait_time = 3.0  # Boss attack interval
		timer.timeout.connect(_on_boss_attack_timer_timeout)
		timer.start()

func _process_boss_behavior(delta: float):
	if phase_transition_active:
		# During phase transition, boss might be invulnerable or have different behavior
		velocity_component.decelerate()
		velocity_component.move(self)
		return
	
	# Apply phase-specific movement speed
	var speed_multiplier = 1.0
	if current_phase != null:
		speed_multiplier = current_phase.movement_speed_multiplier
	
	# Temporarily modify velocity component speed
	var original_max_speed = velocity_component.max_speed
	velocity_component.max_speed = int(original_max_speed * speed_multiplier)
	
	# Boss follows player but with more sophisticated patterns
	velocity_component.accelerate_to_player()
	velocity_component.move(self)
	
	# Restore original speed
	velocity_component.max_speed = original_max_speed
	
	# Handle sprite flipping
	var move_sign = sign(velocity.x)
	if move_sign != 0:
		visuals.scale = Vector2(-move_sign, 1)

func _on_boss_health_changed():
	if boss_health_component == null or enemy_data == null or not enemy_data.is_boss:
		return
	
	var health_percent = boss_health_component.get_health_percent()
	
	# Emit boss health changed event
	GameEvents.emit_boss_health_changed(enemy_data, boss_health_component.current_health, boss_health_component.max_health)
	
	# Check for phase transitions
	_check_phase_transition(health_percent)

func _check_phase_transition(health_percent: float):
	if enemy_data.boss_phases.size() <= current_phase_index + 1:
		return  # No more phases
	
	var next_phase = enemy_data.boss_phases[current_phase_index + 1]
	if health_percent <= next_phase.health_threshold:
		_trigger_phase_transition(current_phase_index + 1)

func _trigger_phase_transition(new_phase_index: int):
	if new_phase_index >= enemy_data.boss_phases.size():
		return
	
	phase_transition_active = true
	current_phase_index = new_phase_index
	current_phase = enemy_data.boss_phases[new_phase_index]
	
	# Emit phase change event
	GameEvents.emit_boss_phase_changed(enemy_data, current_phase, current_phase_index)
	
	# Notify network sync component
	if boss_network_sync != null:
		boss_network_sync.notify_phase_change(current_phase_index)
	
	# Handle invulnerability during transition
	if current_phase.invulnerable_during_transition:
		var damage_component = get_node_or_null("DamageComponent") as DamageComponent
		if damage_component != null:
			# Temporarily disable damage (simplified approach)
			damage_component.set_process_mode(Node.PROCESS_MODE_DISABLED)
			
			# Re-enable after a short delay
			get_tree().create_timer(1.0).timeout.connect(func():
				if damage_component != null:
					damage_component.set_process_mode(Node.PROCESS_MODE_INHERIT)
				phase_transition_active = false
			)
	else:
		phase_transition_active = false

func _on_boss_attack_timer_timeout():
	if phase_transition_active or enemy_data == null or not enemy_data.is_boss:
		return
	
	# Execute special attacks based on current phase
	_execute_boss_special_attack()

func _execute_boss_special_attack():
	var attacks_to_use: Array[PackedScene] = []
	
	# Add global boss attacks
	attacks_to_use.append_array(enemy_data.special_attacks)
	
	# Add phase-specific attacks
	if current_phase != null:
		attacks_to_use.append_array(current_phase.special_abilities)
	
	if attacks_to_use.size() == 0:
		return
	
	# Mark as attacking for network sync
	set_meta("is_attacking", true)
	
	# Pick a random attack
	var attack_scene = attacks_to_use[randi() % attacks_to_use.size()]
	if attack_scene == null:
		set_meta("is_attacking", false)
		return
	
	# Emit special attack event
	var attack_name = attack_scene.resource_path.get_file().get_basename()
	GameEvents.emit_boss_special_attack_started(enemy_data, attack_name)
	
	# Notify network sync component
	if boss_network_sync != null:
		boss_network_sync.notify_special_attack(attack_name, global_position)
	
	# Instantiate and position the attack
	var attack_instance = attack_scene.instantiate()
	attack_instance.global_position = global_position
	
	# Add to entities layer
	var entities_layer = get_tree().get_first_node_in_group("entities_layer")
	if entities_layer:
		entities_layer.add_child(attack_instance)
	else:
		get_parent().add_child(attack_instance)
	
	# Clear attacking flag after a delay
	get_tree().create_timer(1.0).timeout.connect(func():
		set_meta("is_attacking", false)
	)

func _on_enemy_died():
	# Handle boss-specific death events
	if enemy_data != null and enemy_data.is_boss and enemy_data.behavior_type == "Boss":
		GameEvents.emit_boss_defeated(enemy_data, enemy_data.xp_reward)

# Network synchronization helper methods for multiplayer
func get_current_phase_index() -> int:
	return current_phase_index

func set_current_phase_index(new_phase_index: int):
	if new_phase_index < enemy_data.boss_phases.size():
		current_phase_index = new_phase_index
		current_phase = enemy_data.boss_phases[current_phase_index]

func is_attacking() -> bool:
	# Returns true if boss is currently executing a special attack
	return get_meta("is_attacking", false)

func execute_special_attack_client(attack_name: String, position: Vector2):
	# Execute special attack on client side (called via RPC)
	print("Client executing boss attack: ", attack_name, " at ", position)