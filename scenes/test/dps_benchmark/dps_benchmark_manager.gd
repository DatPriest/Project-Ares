extends Node
class_name DPSBenchmarkManager

signal benchmark_completed(results: Dictionary)

@export var test_duration: float = 10.0
@export var dummy_target_scene: PackedScene

var current_test_results: Dictionary = {}
var current_dummy_target: DummyTarget
var test_timer: Timer
var current_ability_name: String = ""
var is_testing: bool = false

func _ready() -> void:
	# Create test timer
	test_timer = Timer.new()
	add_child(test_timer)
	test_timer.wait_time = test_duration
	test_timer.one_shot = true
	test_timer.timeout.connect(_on_test_timeout)

func start_ability_test(ability_name: String, ability_controller: Node) -> void:
	"""Start a DPS test for a specific ability"""
	if is_testing:
		print("Test already in progress, please wait...")
		return
	
	print("Starting DPS test for ability: %s" % ability_name)
	current_ability_name = ability_name
	is_testing = true
	
	# Spawn dummy target
	_spawn_dummy_target()
	
	# Connect to damage tracking
	current_dummy_target.damage_taken.connect(_on_damage_taken)
	
	# Reset results for this test
	current_test_results = {
		"ability_name": ability_name,
		"total_damage": 0.0,
		"hit_count": 0,
		"test_duration": test_duration,
		"dps": 0.0,
		"average_hit_damage": 0.0,
		"hits_per_second": 0.0
	}
	
	# Start the test timer
	test_timer.start()
	print("Test started - Duration: %s seconds" % test_duration)

func _spawn_dummy_target() -> void:
	"""Spawn a dummy target for testing"""
	if current_dummy_target != null:
		current_dummy_target.queue_free()
	
	# Get the foreground layer or create one if needed
	var foreground_layer = get_tree().get_first_node_in_group("foreground_layer")
	if foreground_layer == null:
		# Create a simple foreground node if none exists
		foreground_layer = Node2D.new()
		foreground_layer.name = "ForegroundLayer"
		foreground_layer.add_to_group("foreground_layer")
		get_tree().current_scene.add_child(foreground_layer)
	
	# Instantiate dummy target
	current_dummy_target = dummy_target_scene.instantiate() as DummyTarget
	foreground_layer.add_child(current_dummy_target)
	
	# Position the dummy target near the player
	var player = get_tree().get_first_node_in_group("player")
	if player != null:
		current_dummy_target.global_position = player.global_position + Vector2(50, 0)
	else:
		current_dummy_target.global_position = Vector2(100, 100)

func _on_damage_taken(damage_amount: float) -> void:
	"""Track damage dealt to the dummy target"""
	current_test_results["total_damage"] += damage_amount
	current_test_results["hit_count"] += 1

func _on_test_timeout() -> void:
	"""Called when the test duration expires"""
	_finalize_test_results()
	_cleanup_test()

func _finalize_test_results() -> void:
	"""Calculate final DPS and other metrics"""
	var total_damage: float = current_test_results["total_damage"]
	var hit_count: int = current_test_results["hit_count"]
	
	# Calculate DPS
	current_test_results["dps"] = total_damage / test_duration
	
	# Calculate average hit damage
	if hit_count > 0:
		current_test_results["average_hit_damage"] = total_damage / hit_count
		current_test_results["hits_per_second"] = float(hit_count) / test_duration
	
	# Print results
	print("=== DPS Test Results for %s ===" % current_ability_name)
	print("Test Duration: %.2f seconds" % test_duration)
	print("Total Damage: %.2f" % total_damage)
	print("Hit Count: %d" % hit_count)
	print("DPS: %.2f" % current_test_results["dps"])
	print("Average Hit Damage: %.2f" % current_test_results["average_hit_damage"])
	print("Hits Per Second: %.2f" % current_test_results["hits_per_second"])
	print("============================")
	
	# Emit completion signal
	benchmark_completed.emit(current_test_results.duplicate())

func _cleanup_test() -> void:
	"""Clean up after test completion"""
	if current_dummy_target != null:
		current_dummy_target.damage_taken.disconnect(_on_damage_taken)
		current_dummy_target.queue_free()
		current_dummy_target = null
	
	is_testing = false
	current_ability_name = ""

func run_all_ability_tests(ability_configs: Array) -> void:
	"""Run DPS tests for multiple abilities in sequence"""
	print("Starting batch DPS testing for %d abilities..." % ability_configs.size())
	
	for config in ability_configs:
		var ability_name: String = config.get("name", "Unknown")
		var ability_controller: Node = config.get("controller", null)
		
		if ability_controller == null:
			print("Warning: No controller provided for ability: %s" % ability_name)
			continue
		
		# Wait for any current test to finish
		while is_testing:
			await get_tree().process_frame
		
		start_ability_test(ability_name, ability_controller)
		
		# Wait for this test to complete
		await benchmark_completed
		
		# Brief pause between tests
		await get_tree().create_timer(1.0).timeout
	
	print("All DPS tests completed!")

func get_test_results() -> Dictionary:
	"""Get the results of the last completed test"""
	return current_test_results.duplicate()