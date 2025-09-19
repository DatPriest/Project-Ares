extends Node2D

const MAX_RADIUS = 100

@onready var hitbox_component = $HitboxComponent

var base_rotation = Vector2.RIGHT
var cached_player_position = Vector2.ZERO



	
	
func _ready():
	base_rotation = Vector2.RIGHT.rotated(randf_range(0, TAU))
	
	# Connect to player position updates for cached access
	GameEvents.player_position_updated.connect(on_player_position_updated)
	
	var tween = create_tween()
	tween.tween_method(tween_method, 0.0, 2.0, 3)
	tween.tween_callback(queue_free)

func on_player_position_updated(player_position: Vector2):
	cached_player_position = player_position
	
func tween_method(rotations: float):
	var percent = rotations / 2
	var current_radius = percent * MAX_RADIUS
	var current_direction = base_rotation.rotated(rotations * TAU)
	
	# Use cached player position instead of expensive tree lookup
	if cached_player_position == Vector2.ZERO:
		return
	
	global_position = cached_player_position + (current_direction * current_radius)
