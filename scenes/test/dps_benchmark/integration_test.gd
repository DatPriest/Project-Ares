extends Node
# Integration test for DPS benchmark system
# Tests the actual functionality with a mock ability

class_name DPSBenchmarkIntegrationTest

var dummy_target_scene = preload("res://scenes/test/dps_benchmark/dummy_target.tscn")
var test_results: Array = []

func _ready():
	print("Starting DPS Benchmark Integration Test...")
	run_integration_test()

func run_integration_test():
	"""Run a complete integration test of the benchmark system"""
	
	# Test 1: Create and verify dummy target
	print("\n=== Test 1: Dummy Target Creation ===")
	var dummy_target = dummy_target_scene.instantiate()
	add_child(dummy_target)
	
	# Position the dummy target
	dummy_target.global_position = Vector2(100, 100)
	
	# Connect to damage signal
	dummy_target.damage_taken.connect(_on_damage_taken)
	
	print("✓ Dummy target created and positioned")
	
	# Test 2: Simulate damage
	print("\n=== Test 2: Damage Simulation ===")
	await simulate_damage_hits(dummy_target)
	
	# Test 3: Verify damage tracking
	print("\n=== Test 3: Damage Tracking Verification ===")
	var total_damage = dummy_target.get_total_damage()
	print("Total damage tracked: %.2f" % total_damage)
	
	if total_damage > 0:
		print("✓ Damage tracking working correctly")
	else:
		print("✗ Damage tracking failed")
	
	# Test 4: Reset functionality
	print("\n=== Test 4: Reset Functionality ===")
	dummy_target.reset_damage_counter()
	if dummy_target.get_total_damage() == 0:
		print("✓ Reset functionality working")
	else:
		print("✗ Reset functionality failed")
	
	# Test 5: Benchmark Manager Test
	print("\n=== Test 5: Benchmark Manager Test ===")
	await test_benchmark_manager(dummy_target)
	
	# Cleanup
	dummy_target.queue_free()
	
	print("\n=== Integration Test Complete ===")
	print("Results: %d damage events tracked" % test_results.size())

func simulate_damage_hits(target: DummyTarget):
	"""Simulate ability hits on the dummy target"""
	print("Simulating damage hits...")
	
	# Create a mock hitbox to simulate ability damage
	var mock_hitbox = HitboxComponent.new()
	
	# Simulate 5 hits with different damage amounts
	var damage_amounts = [10.0, 15.0, 8.0, 12.0, 20.0]
	
	for damage in damage_amounts:
		mock_hitbox.damage = damage
		
		# Directly call the override method to simulate area_entered
		target._on_area_entered_override(mock_hitbox)
		
		print("  Simulated hit for %.1f damage" % damage)
		
		# Small delay between hits
		await get_tree().create_timer(0.1).timeout
	
	mock_hitbox.queue_free()
	print("Simulation complete")

func test_benchmark_manager(target: DummyTarget):
	"""Test the benchmark manager functionality"""
	print("Testing benchmark manager...")
	
	# Create benchmark manager
	var manager = preload("res://scenes/test/dps_benchmark/dps_benchmark_manager.gd").new()
	add_child(manager)
	
	# Set up dummy target scene
	manager.dummy_target_scene = dummy_target_scene
	manager.test_duration = 2.0  # Short test for integration
	
	# Connect to completion signal
	manager.benchmark_completed.connect(_on_benchmark_completed)
	
	# Create a mock ability controller
	var mock_ability = Node.new()
	mock_ability.name = "MockAbility"
	
	print("Starting benchmark test...")
	manager.start_ability_test("Mock Test Ability", mock_ability)
	
	# Simulate some damage during the test
	await get_tree().create_timer(0.5).timeout
	if manager.current_dummy_target != null:
		await simulate_damage_hits(manager.current_dummy_target)
	
	# Wait for test completion
	await manager.benchmark_completed
	
	manager.queue_free()
	mock_ability.queue_free()

func _on_damage_taken(amount: float):
	"""Handle damage taken by dummy target"""
	test_results.append({
		"damage": amount,
		"timestamp": Time.get_ticks_msec()
	})
	print("  Damage taken: %.2f" % amount)

func _on_benchmark_completed(results: Dictionary):
	"""Handle benchmark completion"""
	print("Benchmark test completed!")
	print("Results: DPS=%.2f, Hits=%d, Avg=%.2f" % [
		results.get("dps", 0),
		results.get("hit_count", 0), 
		results.get("average_hit_damage", 0)
	])
	
	if results.get("dps", 0) > 0:
		print("✓ Benchmark manager working correctly")
	else:
		print("✗ Benchmark manager test failed")