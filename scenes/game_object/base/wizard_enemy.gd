extends BaseEnemy
class_name WizardEnemy

@onready var timer: Timer = $Timer

var is_moving: bool = false

func _ready():
	super._ready()
	
	# Setup timer based on enemy data
	if timer && enemy_data:
		timer.wait_time = enemy_data.movement_active_duration
		timer.timeout.connect(_on_timer_timeout)
		timer.start()
		is_moving = true

func _process(delta):
	if is_moving:
		velocity_component.accelerate_to_player()
	else:
		velocity_component.decelerate()
	
	velocity_component.move(self)
	
	var move_sign = sign(velocity.x)
	if move_sign != 0:
		visuals.scale = Vector2(move_sign, 1)

func set_is_moving(moving: bool):
	is_moving = moving

func _on_timer_timeout():
	if enemy_data == null:
		return
		
	is_moving = !is_moving
	
	if is_moving:
		timer.wait_time = enemy_data.movement_active_duration
	else:
		timer.wait_time = enemy_data.movement_pause_duration
		
	timer.start()