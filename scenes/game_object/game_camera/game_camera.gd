extends Camera2D

var target_position = Vector2.ZERO

func _ready():
	make_current()
	GameEvents.player_position_updated.connect(on_player_position_updated)

func _process(delta):
	global_position = global_position.lerp(target_position, 1 - exp(-delta * 20))

func on_player_position_updated(player_position: Vector2):
	target_position = player_position
		
