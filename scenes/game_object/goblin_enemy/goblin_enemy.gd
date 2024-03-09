extends CharacterBody2D

@onready var velocity_component: VelocityComponent = $VelocityComponent
@onready var vial_drop_component = $VialDropComponent
@onready var health_component = $HealthComponent
@onready var hit_random_audio_player_component = $HitRandomAudioPlayerComponent

@onready var visuals = $Visuals

var is_moving = false

func _process(delta):
	if is_moving:
		velocity_component.accelerate_to_player()
	else:
		velocity_component.decelerate()
	
	velocity_component.move(self)
	
	var move_sign = sign(velocity.x)
	if move_sign != 0:
		visuals.scale = Vector2(-move_sign, 1)


func set_is_moving(moving: bool):
	is_moving = moving
	
func _ready():
	$HurtBoxComponent.hit.connect(on_hit)

func on_hit():
	hit_random_audio_player_component.play_random()
