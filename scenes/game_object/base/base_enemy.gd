extends CharacterBody2D
class_name BaseEnemy

@onready var visuals = $Visuals
@onready var velocity_component: VelocityComponent = $VelocityComponent
@onready var hit_random_audio_player_component: AudioStreamPlayer2D = $HitRandomAudioPlayerComponent
@onready var hurt_box_component: HurtboxComponent = $HurtBoxComponent
@onready var enemy_type: String = "BaseEnemy"
@onready var enemy_id: String = "BaseEnemy"

func _process(delta):
	velocity_component.accelerate_to_player()
	velocity_component.move(self)
	
	var move_sign = sign(velocity.x)
	if move_sign != 0:
		visuals.scale = Vector2(-move_sign, 1)

func _ready():
	hurt_box_component.hit.connect(on_hit)

func on_hit():
	hit_random_audio_player_component.play_random()
