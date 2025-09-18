extends Node
# Simple validation script for DPS benchmark system
# Can be run as a tool script or attached to a test node

func validate_dummy_target() -> bool:
	"""Validate that DummyTarget class is properly defined"""
	print("Validating DummyTarget...")
	
	# Check if we can create a dummy target instance
	var dummy_target_script = load("res://scenes/test/dps_benchmark/dummy_target.gd")
	if dummy_target_script == null:
		print("✗ Failed to load dummy_target.gd")
		return false
	
	print("✓ DummyTarget script loaded successfully")
	
	# Basic method validation
	var required_methods = [
		"reset_damage_counter",
		"get_total_damage",
		"_on_area_entered_override"
	]
	
	for method_name in required_methods:
		if not dummy_target_script.has_method(method_name):
			print("✗ Missing required method: %s" % method_name)
			return false
		print("✓ Method found: %s" % method_name)
	
	return true

func validate_benchmark_manager() -> bool:
	"""Validate that DPSBenchmarkManager class is properly defined"""
	print("\nValidating DPSBenchmarkManager...")
	
	var manager_script = load("res://scenes/test/dps_benchmark/dps_benchmark_manager.gd")
	if manager_script == null:
		print("✗ Failed to load dps_benchmark_manager.gd")
		return false
	
	print("✓ DPSBenchmarkManager script loaded successfully")
	
	# Basic method validation
	var required_methods = [
		"start_ability_test",
		"run_all_ability_tests", 
		"_spawn_dummy_target",
		"_finalize_test_results"
	]
	
	for method_name in required_methods:
		if not manager_script.has_method(method_name):
			print("✗ Missing required method: %s" % method_name)
			return false
		print("✓ Method found: %s" % method_name)
	
	return true

func validate_test_scene() -> bool:
	"""Validate that the test scene script is properly defined"""
	print("\nValidating DPS Test Scene...")
	
	var scene_script = load("res://scenes/test/dps_benchmark/dps_test_scene.gd")
	if scene_script == null:
		print("✗ Failed to load dps_test_scene.gd")
		return false
	
	print("✓ DPS Test Scene script loaded successfully")
	
	# Basic method validation
	var required_methods = [
		"start_test_sequence",
		"_get_ability_test_configs",
		"_generate_final_report",
		"_log_results_to_file"
	]
	
	for method_name in required_methods:
		if not scene_script.has_method(method_name):
			print("✗ Missing required method: %s" % method_name)
			return false
		print("✓ Method found: %s" % method_name)
	
	return true

func validate_scene_files() -> bool:
	"""Check that scene files exist and are valid"""
	print("\nValidating scene files...")
	
	var scene_files = [
		"res://scenes/test/dps_benchmark/dummy_target.tscn",
		"res://scenes/test/dps_benchmark/dps_test_scene.tscn"
	]
	
	for scene_path in scene_files:
		if not ResourceLoader.exists(scene_path):
			print("✗ Scene file not found: %s" % scene_path)
			return false
		
		var scene = load(scene_path)
		if scene == null:
			print("✗ Failed to load scene: %s" % scene_path)
			return false
		
		print("✓ Scene loaded successfully: %s" % scene_path)
	
	return true

func run_validation() -> bool:
	"""Run all validation checks"""
	print("Starting DPS Benchmark Validation...")
	print("=" * 50)
	
	var checks = [
		validate_dummy_target(),
		validate_benchmark_manager(),
		validate_test_scene(),
		validate_scene_files()
	]
	
	var all_passed = true
	for check in checks:
		if not check:
			all_passed = false
	
	print("\n" + "=" * 50)
	if all_passed:
		print("✓ All validation checks PASSED")
		print("DPS Benchmark system is ready for use!")
	else:
		print("✗ Some validation checks FAILED")
		print("Please fix the issues above before using the system.")
	
	return all_passed

# Auto-run validation when script is loaded as a tool
func _ready():
	if Engine.is_editor_hint():
		call_deferred("run_validation")