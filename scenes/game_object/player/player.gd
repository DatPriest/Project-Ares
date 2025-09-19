extends CharacterBody2D
# consts

@export var hit_sounds: Array[AudioStream] = []

@onready var damage_interval_timer = $DamageIntervalTimer 
@onready var health_component = $HealthComponent
@onready var health_bar = $HealthBar 
@onready var abilities = $Abilities
@onready var animation_player = $AnimationPlayer
@onready var visuals = $Visuals
@onready var velocity_component = $VelocityComponent
@onready var character_stats_component = $CharacterStatsComponent

var number_colliding_bodies = 0
var base_speed = 0


func _ready():
	# Add player to group for easy access by managers
	add_to_group("player")
	
	base_speed = velocity_component.max_speed
	$CollisionArea2D.body_entered.connect(on_body_entered)
	$CollisionArea2D.body_exited.connect(on_body_exited)
	$CollisionArea2D.area_entered.connect(on_area_entered)
	$CollisionArea2D.area_exited.connect(on_area_exited)
	damage_interval_timer.timeout.connect(on_damage_interval_timer_timeout)
	health_component.health_changed.connect(on_health_changed)
	GameEvents.ability_upgrade_added.connect(on_ability_upgrade_added)
	GameEvents.resource_collected.connect(on_resource_collected)
	update_health_display()
	
	# Initialize character stats integration
	if character_stats_component:
		character_stats_component.stat_changed.connect(_on_character_stat_changed)

func _process(delta):
	var movement_vector = get_movement_vector()
	var direction = movement_vector.normalized()
	velocity_component.accelerate_in_direction(direction)
	velocity_component.move(self)
	
	# Emit position updates for other systems that need player position
	GameEvents.emit_player_position_updated(global_position)
	
	if movement_vector.x != 0 || movement_vector.y != 0:
		animation_player.play("walk")
	else:
		animation_player.play("RESET")
		
	var move_sign = sign(movement_vector.x)
	if move_sign != 0:
		visuals.scale = Vector2(move_sign, 1)
		
func get_movement_vector():
	
	var x_movement = Input.get_action_strength("move_right") - Input.get_action_strength("move_left")
	var y_movement = Input.get_action_strength("move_down") - Input.get_action_strength("move_up")
	
	
	return Vector2(x_movement, y_movement)

func check_deal_damage():
	if number_colliding_bodies == 0 || !damage_interval_timer.is_stopped():
		return
	
	health_component.damage(1)
	damage_interval_timer.start()
	
func update_health_display():
	health_bar.value = health_component.get_health_percent()

func on_body_entered(other_body: Node2D):
	number_colliding_bodies += 1
	check_deal_damage()
	
func on_body_exited(other_body: Node2D):
	number_colliding_bodies -= 1

func on_damage_interval_timer_timeout():
	check_deal_damage()
	
func on_health_changed():
	GameEvents.emit_player_damaged()
	update_health_display()
	if hit_sounds.size() > 0:
		AudioManager.play_sfx_random(hit_sounds, global_position)
	
func on_ability_upgrade_added(ability_upgrade: AbilityUpgrade, current_upgrades: Dictionary):
	if ability_upgrade is Ability:
		var ability = ability_upgrade as Ability
		abilities.add_child(ability.ability_controller_scene.instantiate())
	elif ability_upgrade.id == "player_speed":
		# Update both legacy system and new character stats
		velocity_component.max_speed = base_speed + (base_speed * current_upgrades["player_speed"]["quantity"] * .1)
		if character_stats_component:
			var speed_bonus = current_upgrades["player_speed"]["quantity"] * 10.0  # 10% per level
			character_stats_component.modify_stat(CharacterStat.StatType.SPEED, speed_bonus, true, false)

func on_resource_collected(resource: DropResource):
	print(resource.title)

func on_area_entered(area: Area2D):
	# Handle projectile damage (immediate, not over time)
	if area is Arrow:
		var arrow = area as Arrow
		health_component.damage(arrow.damage)
		arrow.queue_free()

func on_area_exited(area: Area2D):
	# Projectiles don't need exit handling since they deal immediate damage
	pass

func _on_character_stat_changed(stat: CharacterStat) -> void:
	"""Handle character stat changes and apply them to relevant systems"""
	if not character_stats_component:
		return
	
	match stat.stat_type:
		CharacterStat.StatType.SPEED:
			# Update velocity component with new speed multiplier
			var speed_multiplier = character_stats_component.get_speed_multiplier()
			velocity_component.max_speed = base_speed * speed_multiplier
		CharacterStat.StatType.HEALTH:
			# Update health component if we have a health bonus
			var health_bonus = character_stats_component.get_health_bonus()
			if health_component.has_method("add_max_health_bonus"):
				health_component.add_max_health_bonus(health_bonus)

func get_character_stats_component() -> CharacterStatsComponent:
	"""Get the character stats component for external access"""
	return character_stats_component
