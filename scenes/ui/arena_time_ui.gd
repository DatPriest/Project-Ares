extends CanvasLayer

@export var arena_time_manager: Node
@onready var label = $%Label

# UI update optimization
var update_timer: Timer
const UI_UPDATE_INTERVAL: float = 0.1  # Update UI 10 times per second instead of 60

func _ready():
	# Set up optimized UI update timer
	update_timer = Timer.new()
	update_timer.wait_time = UI_UPDATE_INTERVAL
	update_timer.timeout.connect(_update_time_display)
	update_timer.autostart = true
	add_child(update_timer)

func _update_time_display():
	if arena_time_manager == null:
		return
	
	var time_elapsed = arena_time_manager.get_time_elapsed()
	label.text = format_seconds_to_string(time_elapsed)

func format_seconds_to_string(seconds: float):
	var minutes = floor(seconds / 60)
	var remaining_seconds = seconds - (minutes * 60)
	return str(minutes) + ":" + ("%02d" % floor(remaining_seconds))
