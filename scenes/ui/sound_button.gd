extends Button

@export var streams: Array[AudioStream] = []

func _ready():
	pressed.connect(on_pressed)
	
func on_pressed():
	if streams.size() > 0:
		AudioManager.play_sfx_random(streams, global_position)
