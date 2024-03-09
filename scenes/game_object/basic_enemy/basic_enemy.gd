extends CharacterBody2D

@onready var visuals = $Visuals
@onready var velocity_component: VelocityComponent = $VelocityComponent
@onready var hit_random_audio_player_component = $HitRandomAudioPlayerComponent

func _process(delta):
	velocity_component.accelerate_to_player()
	velocity_component.move(self)
	
	var move_sign = sign(velocity.x)
	if move_sign != 0:
		visuals.scale = Vector2(-move_sign, 1)

func _ready():
	$HurtBoxComponent.hit.connect(on_hit)

func on_hit():
	hit_random_audio_player_component.play_random()
