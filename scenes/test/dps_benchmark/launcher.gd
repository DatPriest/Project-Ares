extends Node
# Launcher script for DPS Benchmark system
# Provides examples of how to use the benchmark system programmatically

func _ready():
	print("DPS Benchmark Launcher")
	print("Available commands:")
	print("  1 - Run full benchmark test")
	print("  2 - Run single ability test")  
	print("  3 - Run validation")
	print("  4 - Run integration test")
	print("")
	print("Press number key to execute command...")

func _input(event):
	if event is InputEventKey and event.pressed:
		match event.keycode:
			KEY_1:
				run_full_benchmark()
			KEY_2:
				run_single_ability_test()
			KEY_3:
				run_validation()
			KEY_4:
				run_integration_test()
			KEY_ESCAPE:
				get_tree().quit()

func run_full_benchmark():
	"""Load and run the full benchmark scene"""
	print("Loading full benchmark scene...")
	var benchmark_scene = load("res://scenes/test/dps_benchmark/dps_test_scene.tscn")
	if benchmark_scene:
		get_tree().change_scene_to_packed(benchmark_scene)
	else:
		print("Error: Could not load benchmark scene")

func run_single_ability_test():
	"""Example of running a single ability test programmatically"""
	print("Running single ability test example...")
	
	# Create benchmark manager
	var manager = preload("res://scenes/test/dps_benchmark/dps_benchmark_manager.gd").new()
	add_child(manager)
	
	# Set up the manager
	manager.dummy_target_scene = load("res://scenes/test/dps_benchmark/dummy_target.tscn")
	manager.test_duration = 5.0
	
	# Load and instantiate an ability controller
	var axe_controller_scene = load("res://scenes/ability/axe_ability_controller/axe_ability_controller.tscn")
	if axe_controller_scene:
		var axe_controller = axe_controller_scene.instantiate()
		add_child(axe_controller)
		
		# Connect to results
		manager.benchmark_completed.connect(_on_single_test_completed)
		
		# Start the test
		manager.start_ability_test("Axe Ability (Single Test)", axe_controller)
		print("Single ability test started...")
	else:
		print("Error: Could not load axe controller scene")

func run_validation():
	"""Run the validation script"""
	print("Running validation...")
	var validator = preload("res://scenes/test/dps_benchmark/validate_benchmark.gd").new()
	add_child(validator)
	validator.run_validation()

func run_integration_test():
	"""Run the integration test"""
	print("Running integration test...")
	var integration_test = preload("res://scenes/test/dps_benchmark/integration_test.gd").new()
	add_child(integration_test)

func _on_single_test_completed(results: Dictionary):
	"""Handle single test completion"""
	print("\n=== Single Test Results ===")
	print("Ability: %s" % results.get("ability_name", "Unknown"))
	print("DPS: %.2f" % results.get("dps", 0))
	print("Total Damage: %.2f" % results.get("total_damage", 0))
	print("Hit Count: %d" % results.get("hit_count", 0))
	print("===========================")
	
	# Return to launcher
	await get_tree().create_timer(2.0).timeout
	print("\nReturning to launcher...")
	print("Press number key for next command or ESC to quit")