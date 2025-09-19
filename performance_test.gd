extends Node
# Performance testing script to validate optimizations

var frame_count: int = 0
var total_frame_time: float = 0.0
var max_frame_time: float = 0.0
var min_frame_time: float = 999.0

func _ready():
	print("Performance testing started...")
	print("Testing optimizations:")
	print("- Cached enemy tracking system")
	print("- Reduced get_tree() calls")
	print("- Optimized ability controllers")
	print("- Event-driven architecture improvements")

func _process(delta: float):
	# Track frame performance
	frame_count += 1
	total_frame_time += delta
	max_frame_time = max(max_frame_time, delta)
	min_frame_time = min(min_frame_time, delta)
	
	# Print stats every 5 seconds
	if frame_count % 300 == 0:  # ~60 FPS * 5 seconds
		var avg_frame_time = total_frame_time / frame_count
		var avg_fps = 1.0 / avg_frame_time
		print("=== Performance Stats (Frame %d) ===" % frame_count)
		print("Average FPS: %.2f" % avg_fps)
		print("Average frame time: %.4f ms" % (avg_frame_time * 1000))
		print("Min frame time: %.4f ms" % (min_frame_time * 1000))
		print("Max frame time: %.4f ms" % (max_frame_time * 1000))
		print("================================")

func get_performance_report() -> Dictionary:
	var avg_frame_time = total_frame_time / max(1, frame_count)
	return {
		"frames_measured": frame_count,
		"average_fps": 1.0 / avg_frame_time,
		"average_frame_time_ms": avg_frame_time * 1000,
		"min_frame_time_ms": min_frame_time * 1000,
		"max_frame_time_ms": max_frame_time * 1000
	}