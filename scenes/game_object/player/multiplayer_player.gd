extends CharacterBody2D

@export var hit_sounds: Array[AudioStream] = []

@onready var damage_interval_timer = $DamageIntervalTimer 
@onready var health_component = $HealthComponent
@onready var health_bar = $HealthBar 
@onready var abilities = $Abilities
@onready var animation_player = $AnimationPlayer
@onready var visuals = $Visuals
@onready var velocity_component = $VelocityComponent
@onready var multiplayer_synchronizer = $MultiplayerSynchronizer
@onready var name_label = $UI/NameLabel

# Multiplayer-specific properties
@export var player_id: int = 0
@export var player_name: String = ""
@export var steam_id: int = 0

# Synchronized variables
var synced_position: Vector2
var synced_velocity: Vector2
var synced_health: float
var synced_animation_state: String = "RESET"

var number_colliding_bodies = 0
var base_speed = 0
var is_local_player: bool = false

func _ready():
	base_speed = velocity_component.max_speed
	
	# Set up collision detection
	$CollisionArea2D.body_entered.connect(on_body_entered)
	$CollisionArea2D.body_exited.connect(on_body_exited)
	$CollisionArea2D.area_entered.connect(on_area_entered)
	$CollisionArea2D.area_exited.connect(on_area_exited)
	damage_interval_timer.timeout.connect(on_damage_interval_timer_timeout)
	health_component.health_changed.connect(on_health_changed)
	health_component.died.connect(on_player_died)
	
	# Connect multiplayer events
	GameEvents.ability_upgrade_added.connect(on_ability_upgrade_added)
	GameEvents.resource_collected.connect(on_resource_collected)
	
	# Set up multiplayer authority
	var peer_id = multiplayer.get_remote_sender_id()
	if peer_id == 0:
		peer_id = 1  # Server/host
	
	is_local_player = multiplayer.get_unique_id() == player_id
	set_multiplayer_authority(peer_id)
	
	# Set player name
	if name_label:
		name_label.text = player_name
	
	# Initialize synchronized values
	synced_position = global_position
	synced_health = health_component.current_health
	
	update_health_display()
	
	# Only local player processes input
	if is_local_player:
		print("Local player initialized: ", player_name)
	else:
		print("Remote player initialized: ", player_name)

func _process(delta):
	if is_local_player:
		# Local player processes input and updates position
		var movement_vector = get_movement_vector()
		var direction = movement_vector.normalized()
		velocity_component.accelerate_in_direction(direction)
		velocity_component.move(self)
		
		# Update synchronized values
		synced_position = global_position
		synced_velocity = velocity
		
		# Handle animation
		if movement_vector.x != 0 || movement_vector.y != 0:
			animation_player.play("walk")
			synced_animation_state = "walk"
		else:
			animation_player.play("RESET")
			synced_animation_state = "RESET"
			
		var move_sign = sign(movement_vector.x)
		if move_sign != 0:
			visuals.scale = Vector2(move_sign, 1)
		
		# Emit position updates for other systems that need player position
		GameEvents.emit_player_position_updated(global_position)
	else:
		# Remote players interpolate to synchronized position
		global_position = global_position.lerp(synced_position, delta * 10.0)
		velocity = velocity.lerp(synced_velocity, delta * 5.0)
		
		# Update animation state
		if synced_animation_state != animation_player.current_animation:
			animation_player.play(synced_animation_state)

func get_movement_vector():
	if not is_local_player:
		return Vector2.ZERO
	
	var x_movement = Input.get_action_strength("move_right") - Input.get_action_strength("move_left")
	var y_movement = Input.get_action_strength("move_down") - Input.get_action_strength("move_up")
	
	return Vector2(x_movement, y_movement)

func check_deal_damage():
	if number_colliding_bodies == 0 || !damage_interval_timer.is_stopped():
		return
	
	# Only local player takes damage directly, then sync to others
	if is_local_player:
		health_component.damage(1)
		damage_interval_timer.start()

func update_health_display():
	health_bar.value = health_component.get_health_percent()

func on_body_entered(other_body: Node2D):
	if is_local_player:
		number_colliding_bodies += 1
		check_deal_damage()

func on_body_exited(other_body: Node2D):
	if is_local_player:
		number_colliding_bodies -= 1

func on_damage_interval_timer_timeout():
	if is_local_player:
		check_deal_damage()

func on_health_changed():
	synced_health = health_component.current_health
	update_health_display()
	
	if is_local_player:
		GameEvents.emit_player_damaged()
		if hit_sounds.size() > 0:
			AudioManager.play_sfx_random(hit_sounds, global_position)

func on_player_died():
	if is_local_player:
		# Handle player death in multiplayer context
		print("Player died: ", player_name)
		# Could implement respawning or spectator mode here
		
func on_ability_upgrade_added(ability_upgrade: AbilityUpgrade, current_upgrades: Dictionary):
	if not is_local_player:
		return
		
	if ability_upgrade is Ability:
		var ability = ability_upgrade as Ability
		abilities.add_child(ability.ability_controller_scene.instantiate())
	elif ability_upgrade.id == "player_speed":
		velocity_component.max_speed = base_speed + (base_speed * current_upgrades["player_speed"]["quantity"] * .1)

func on_resource_collected(resource: DropResource):
	if is_local_player:
		print(resource.title)

func on_area_entered(area: Area2D):
	if not is_local_player:
		return
		
	# Handle projectile damage (immediate, not over time)
	if area is Arrow:
		var arrow = area as Arrow
		health_component.damage(arrow.damage)
		arrow.queue_free()

func on_area_exited(area: Area2D):
	# Projectiles don't need exit handling since they deal immediate damage
	pass

# RPC methods for synchronization
@rpc("unreliable", "call_remote")
func sync_player_state(pos: Vector2, vel: Vector2, health: float, anim_state: String):
	if is_local_player:
		return  # Don't sync to ourselves
	
	synced_position = pos
	synced_velocity = vel
	synced_health = health
	synced_animation_state = anim_state
	
	# Update health component
	if abs(health_component.current_health - synced_health) > 0.1:
		health_component.current_health = synced_health
		health_component.health_changed.emit()

@rpc("reliable", "call_remote")
func sync_player_death():
	if is_local_player:
		return
		
	on_player_died()

# Called by MultiplayerSynchronizer
func _sync_to_peers():
	if is_local_player and multiplayer.is_server():
		sync_player_state.rpc(global_position, velocity, health_component.current_health, synced_animation_state)