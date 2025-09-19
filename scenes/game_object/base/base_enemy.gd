extends CharacterBody2D
class_name BaseEnemy

@export var hit_sounds: Array[AudioStream] = []

@onready var visuals = $Visuals
@onready var velocity_component: VelocityComponent = $VelocityComponent
@onready var hurt_box_component: HurtboxComponent = $HurtBoxComponent
@onready var enemy_type: String = "BaseEnemy"
@onready var enemy_id: String = "BaseEnemy"

# Enemy data resource - set by enemy manager or scene
@export var enemy_data: EnemyData

func _process(delta):
	velocity_component.accelerate_to_player()
	velocity_component.move(self)
	
	var move_sign = sign(velocity.x)
	if move_sign != 0:
		visuals.scale = Vector2(-move_sign, 1)

func _ready():
	hurt_box_component.hit.connect(on_hit)

func on_hit():
	if hit_sounds.size() > 0:
		AudioManager.play_sfx_random(hit_sounds, global_position)
