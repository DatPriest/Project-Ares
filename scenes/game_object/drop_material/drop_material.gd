extends Node2D

@onready var collision_shape_2d = $Area2D/CollisionShape2D
@onready var sprite_2d = $Sprite2D

@export var drop_resource: DropResource

var cached_player_position = Vector2.ZERO

func _ready():
	$Area2D.area_entered.connect(on_area_entered)
	sprite_2d.texture = drop_resource.sprite 
	GameEvents.player_position_updated.connect(on_player_position_updated)

func on_player_position_updated(player_position: Vector2):
	cached_player_position = player_position
	
func tween_collect(percent: float, start_position: Vector2):
	if cached_player_position == Vector2.ZERO:
		return
	
	global_position = start_position.lerp(cached_player_position, percent)
	var direction_from_start = cached_player_position - start_position
	
	var target_rotation = direction_from_start.angle() + deg_to_rad(90)
	rotation = lerp_angle(rotation, target_rotation, 1 - exp(-2 * get_process_delta_time()))
	
func collect():
	#GameEvents.emit_experience_vial_collected(experience_amount)

	GameEvents.emit_resource_collected(drop_resource)
	print("collected")
	queue_free()
	
	
func disable_collision():
	collision_shape_2d.disabled = true
	
func on_area_entered(other_area: Area2D):
	Callable(disable_collision).call_deferred()
	
	var tween = create_tween()
	tween.set_parallel()
	tween.tween_method(tween_collect.bind(global_position), 0.0, 1.0, .5)\
		.set_ease(Tween.EASE_IN)\
		.set_trans(Tween.TRANS_BACK)
	tween.tween_property(sprite_2d, "scale", Vector2.ZERO, .05).set_delay(.45)
	tween.chain()
	tween.tween_callback(collect)
	$RandomStreamPlayer2DComponent.play_random()
