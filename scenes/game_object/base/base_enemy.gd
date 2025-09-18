extends CharacterBody2D
class_name BaseEnemy

@export var enemy_data: EnemyData

@onready var visuals = $Visuals
@onready var velocity_component: VelocityComponent = $VelocityComponent
@onready var hit_random_audio_player_component: AudioStreamPlayer2D = $HitRandomAudioPlayerComponent
@onready var hurt_box_component: HurtboxComponent = $HurtBoxComponent
@onready var health_component: HealthComponent = $HealthComponent
@onready var sprite_2d: Sprite2D = $Visuals/Sprite2D

var enemy_type: String = "BaseEnemy"
var enemy_id: String = "BaseEnemy"

func _ready():
	hurt_box_component.hit.connect(on_hit)
	health_component.died.connect(on_died)
	apply_enemy_data()

func on_died():
	# Emit experience gained signal with XP from enemy data
	if enemy_data:
		GameEvents.emit_enemy_killed(enemy_data.xp_reward)

func apply_enemy_data():
	if enemy_data == null:
		return
		
	# Apply basic stats to components
	if health_component:
		health_component.max_health = enemy_data.max_health
		health_component.current_health = enemy_data.max_health
		
	if velocity_component:
		velocity_component.max_speed = enemy_data.max_speed
		velocity_component.acceleration = enemy_data.acceleration
		
	# Apply visual
	if sprite_2d && enemy_data.sprite_texture:
		sprite_2d.texture = enemy_data.sprite_texture
		
	# Set identification
	enemy_type = enemy_data.behavior_type
	enemy_id = enemy_data.id

func _process(delta):
	# Default basic movement behavior
	velocity_component.accelerate_to_player()
	velocity_component.move(self)
	
	var move_sign = sign(velocity.x)
	if move_sign != 0:
		visuals.scale = Vector2(-move_sign, 1)

func on_hit():
	hit_random_audio_player_component.play_random()
