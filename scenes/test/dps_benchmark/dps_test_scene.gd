extends Node2D

@onready var dps_manager: DPSBenchmarkManager = $DPSBenchmarkManager
@onready var abilities_node: Node = $TestPlayer/Abilities

@export var dummy_target_scene: PackedScene
@export var test_duration: float = 10.0

# Ability scenes for testing
@export var axe_ability_controller_scene: PackedScene
@export var sword_ability_controller_scene: PackedScene 
@export var double_sword_ability_controller_scene: PackedScene

var test_results: Array[Dictionary] = []
var current_test_index: int = 0

func _ready() -> void:
	print("DPS Test Scene Initialized")
	
	# Set up the DPS manager
	dps_manager.dummy_target_scene = dummy_target_scene
	dps_manager.test_duration = test_duration
	dps_manager.benchmark_completed.connect(_on_benchmark_completed)
	
	# Start the test sequence after a brief delay
	await get_tree().create_timer(1.0).timeout
	start_test_sequence()

func _input(event: InputEvent) -> void:
	# Allow manual test triggering with spacebar
	if event.is_action_pressed("ui_accept"):
		if not dps_manager.is_testing:
			start_test_sequence()
		else:
			print("Test in progress, please wait...")

func start_test_sequence() -> void:
	"""Start the automated test sequence for all abilities"""
	print("Starting DPS benchmark test sequence...")
	test_results.clear()
	
	var ability_configs = _get_ability_test_configs()
	
	if ability_configs.is_empty():
		print("No abilities configured for testing!")
		return
	
	# Run all tests sequentially
	await dps_manager.run_all_ability_tests(ability_configs)
	
	# Generate final report
	_generate_final_report()

func _get_ability_test_configs() -> Array:
	"""Get configuration for all abilities to test"""
	var configs: Array = []
	
	# Add axe ability test
	if axe_ability_controller_scene != null:
		var axe_controller = axe_ability_controller_scene.instantiate()
		abilities_node.add_child(axe_controller)
		configs.append({
			"name": "Axe Ability",
			"controller": axe_controller
		})
	
	# Add sword ability test  
	if sword_ability_controller_scene != null:
		var sword_controller = sword_ability_controller_scene.instantiate()
		abilities_node.add_child(sword_controller)
		configs.append({
			"name": "Sword Ability", 
			"controller": sword_controller
		})
	
	# Add double sword ability test
	if double_sword_ability_controller_scene != null:
		var double_sword_controller = double_sword_ability_controller_scene.instantiate()
		abilities_node.add_child(double_sword_controller)
		configs.append({
			"name": "Double Sword Ability",
			"controller": double_sword_controller
		})
	
	return configs

func _on_benchmark_completed(results: Dictionary) -> void:
	"""Handle completion of a single ability test"""
	test_results.append(results)
	
	# Log to file for persistence
	_log_results_to_file(results)

func _generate_final_report() -> void:
	"""Generate and display the final test report"""
	print("\n" + "="*60)
	print("FINAL DPS BENCHMARK REPORT")
	print("="*60)
	print("Test Duration per Ability: %.2f seconds" % test_duration)
	print("Total Abilities Tested: %d" % test_results.size())
	print("-" * 60)
	
	# Sort results by DPS for ranking
	var sorted_results = test_results.duplicate()
	sorted_results.sort_custom(func(a, b): return a["dps"] > b["dps"])
	
	for i in range(sorted_results.size()):
		var result = sorted_results[i]
		print("Rank %d: %s" % [i + 1, result["ability_name"]])
		print("  DPS: %.2f" % result["dps"])
		print("  Total Damage: %.2f" % result["total_damage"])
		print("  Hits Per Second: %.2f" % result["hits_per_second"])
		print("  Avg Hit Damage: %.2f" % result["average_hit_damage"])
		print("-" * 40)
	
	print("="*60)
	
	# Also log the final report
	_log_final_report_to_file(sorted_results)

func _log_results_to_file(results: Dictionary) -> void:
	"""Log individual test results to file"""
	var file_path = "user://dps_test_results.txt"
	var file = FileAccess.open(file_path, FileAccess.WRITE)
	
	if file == null:
		print("Failed to open log file for writing")
		return
	
	# If file is empty, write header
	if file.get_position() == 0:
		file.store_line("DPS Test Results Log")
		file.store_line("Generated: %s" % Time.get_datetime_string_from_system())
		file.store_line("=" * 50)
	
	# Write individual test result
	file.store_line("\nTest: %s" % results["ability_name"])
	file.store_line("Date/Time: %s" % Time.get_datetime_string_from_system())
	file.store_line("Duration: %.2f seconds" % results["test_duration"])
	file.store_line("Total Damage: %.2f" % results["total_damage"])
	file.store_line("Hit Count: %d" % results["hit_count"])
	file.store_line("DPS: %.2f" % results["dps"])
	file.store_line("Hits Per Second: %.2f" % results["hits_per_second"])
	file.store_line("Average Hit Damage: %.2f" % results["average_hit_damage"])
	file.store_line("-" * 30)
	
	file.close()

func _log_final_report_to_file(sorted_results: Array) -> void:
	"""Log the final benchmark report to file"""
	var file_path = "user://dps_benchmark_report.txt"
	var file = FileAccess.open(file_path, FileAccess.WRITE)
	
	if file == null:
		print("Failed to create benchmark report file")
		return
	
	file.store_line("DPS BENCHMARK REPORT")
	file.store_line("Generated: %s" % Time.get_datetime_string_from_system())
	file.store_line("Test Duration: %.2f seconds per ability" % test_duration)
	file.store_line("Total Abilities Tested: %d" % sorted_results.size())
	file.store_line("=" * 60)
	
	for i in range(sorted_results.size()):
		var result = sorted_results[i]
		file.store_line("Rank %d: %s" % [i + 1, result["ability_name"]])
		file.store_line("  DPS: %.2f" % result["dps"])
		file.store_line("  Total Damage: %.2f" % result["total_damage"])
		file.store_line("  Hits Per Second: %.2f" % result["hits_per_second"])
		file.store_line("  Avg Hit Damage: %.2f" % result["average_hit_damage"])
		file.store_line("-" * 40)
	
	file.store_line("=" * 60)
	file.close()
	
	print("Benchmark report saved to: %s" % file_path)