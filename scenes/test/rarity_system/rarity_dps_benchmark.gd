extends Node
class_name RarityDPSBenchmark

"""
DPS Benchmark extension specifically for testing weapon rarity performance.
Integrates with the existing DPS benchmark system to validate rarity balance.
"""

signal rarity_benchmark_completed(results: Dictionary)

@export var dps_benchmark_manager: DPSBenchmarkManager
@export var test_duration: float = 10.0
@export var iterations_per_rarity: int = 5

var current_results: Dictionary = {}
var benchmark_data: Array[Dictionary] = []

func _ready() -> void:
	if dps_benchmark_manager == null:
		push_error("RarityDPSBenchmark: dps_benchmark_manager not assigned")
		return
	
	dps_benchmark_manager.benchmark_completed.connect(_on_benchmark_completed)

func run_rarity_benchmark_suite(base_weapon_stats: WeaponStats) -> void:
	"""Run comprehensive DPS benchmarks across all rarity grades"""
	print("Starting Rarity DPS Benchmark Suite...")
	benchmark_data.clear()
	current_results.clear()
	
	# Test each rarity grade
	for grade in range(10):
		await _benchmark_rarity_grade(base_weapon_stats, grade)
	
	_generate_final_report()
	rarity_benchmark_completed.emit(current_results)

func run_comparative_analysis(weapon_configs: Array[Dictionary]) -> void:
	"""Compare multiple weapon types across all rarities"""
	print("Starting Comparative Rarity Analysis...")
	
	var comparative_results: Dictionary = {}
	
	for config in weapon_configs:
		var weapon_name: String = config.get("name", "Unknown")
		var base_stats: WeaponStats = config.get("stats", null)
		
		if base_stats == null:
			print("Warning: No stats provided for weapon: %s" % weapon_name)
			continue
		
		print("Analyzing %s across all rarities..." % weapon_name)
		comparative_results[weapon_name] = {}
		
		for grade in range(10):
			var variant: WeaponStats = base_stats.create_rarity_variant(grade)
			var estimated_dps: float = variant.get_dps_estimate()
			
			comparative_results[weapon_name][grade] = {
				"rarity_name": variant.weapon_rarity.rarity_name,
				"estimated_dps": estimated_dps,
				"damage_modifier": variant.applied_damage_modifier,
				"cooldown_modifier": variant.applied_cooldown_modifier,
				"critical_chance": variant.current_critical_chance,
				"accuracy": variant.current_accuracy
			}
	
	_print_comparative_report(comparative_results)

func benchmark_specific_rarity_range(base_stats: WeaponStats, min_grade: int, max_grade: int) -> Dictionary:
	"""Benchmark a specific range of rarity grades"""
	var range_results: Dictionary = {}
	
	print("Benchmarking rarities %d-%d..." % [min_grade, max_grade])
	
	for grade in range(min_grade, max_grade + 1):
		var variant: WeaponStats = base_stats.create_rarity_variant(grade)
		var rarity_name: String = variant.weapon_rarity.rarity_name
		
		# Run multiple iterations for statistical accuracy
		var dps_samples: Array[float] = []
		
		for iteration in range(iterations_per_rarity):
			# Generate new variant for each iteration to account for RNG
			var test_variant: WeaponStats = base_stats.create_rarity_variant(grade)
			var estimated_dps: float = test_variant.get_dps_estimate()
			dps_samples.append(estimated_dps)
		
		# Calculate statistics
		var avg_dps: float = _calculate_average(dps_samples)
		var min_dps: float = dps_samples.min()
		var max_dps: float = dps_samples.max()
		var std_dev: float = _calculate_standard_deviation(dps_samples, avg_dps)
		
		range_results[grade] = {
			"rarity_name": rarity_name,
			"average_dps": avg_dps,
			"min_dps": min_dps,
			"max_dps": max_dps,
			"standard_deviation": std_dev,
			"samples": dps_samples.size()
		}
		
		print("Grade %d (%s): Avg=%.2f, Min=%.2f, Max=%.2f, StdDev=%.2f" % 
			[grade, rarity_name, avg_dps, min_dps, max_dps, std_dev])
	
	return range_results

func validate_rarity_balance() -> Dictionary:
	"""Validate that rarity progression feels balanced"""
	var validation_results: Dictionary = {"passed": 0, "failed": 0, "warnings": 0, "details": []}
	
	# Create test weapon
	var base_weapon: WeaponStats = WeaponStats.new(10.0, 1.0, 0.1, 0.1, 100.0, 2)
	
	# Get DPS for each rarity
	var dps_by_grade: Array[float] = []
	for grade in range(10):
		var variant: WeaponStats = base_weapon.create_rarity_variant(grade)
		dps_by_grade.append(variant.get_dps_estimate())
	
	# Validate progression from Common to Divine
	for i in range(2, 9):
		var current_dps: float = dps_by_grade[i]
		var previous_dps: float = dps_by_grade[i-1]
		var improvement: float = (current_dps - previous_dps) / previous_dps * 100.0
		
		var rarity_name: String = WeaponRarity.new(i).rarity_name
		var prev_rarity_name: String = WeaponRarity.new(i-1).rarity_name
		
		# Expected minimum improvement per grade
		var expected_min_improvement: float = 15.0  # 15% minimum
		if i >= 6:  # Legendary and above
			expected_min_improvement = 30.0  # 30% minimum
		
		if improvement >= expected_min_improvement:
			validation_results.passed += 1
			validation_results.details.append("✓ %s→%s: %.1f%% improvement (good)" % 
				[prev_rarity_name, rarity_name, improvement])
		elif improvement >= 5.0:
			validation_results.warnings += 1
			validation_results.details.append("⚠ %s→%s: %.1f%% improvement (low)" % 
				[prev_rarity_name, rarity_name, improvement])
		else:
			validation_results.failed += 1
			validation_results.details.append("❌ %s→%s: %.1f%% improvement (insufficient)" % 
				[prev_rarity_name, rarity_name, improvement])
	
	# Validate that broken/poor are appropriately weak
	var broken_dps: float = dps_by_grade[0]
	var common_dps: float = dps_by_grade[2]
	if broken_dps < common_dps * 0.7:  # Broken should be <70% of Common
		validation_results.passed += 1
		validation_results.details.append("✓ Broken weapons appropriately weak: %.1f%% of Common" % 
			(broken_dps / common_dps * 100.0))
	else:
		validation_results.failed += 1
		validation_results.details.append("❌ Broken weapons too strong: %.1f%% of Common" % 
			(broken_dps / common_dps * 100.0))
	
	# Validate transcendent power
	var transcendent_dps: float = dps_by_grade[9]
	if transcendent_dps > common_dps * 3.0:  # Should be >3x Common
		validation_results.passed += 1
		validation_results.details.append("✓ Transcendent appropriately powerful: %.1fx Common" % 
			(transcendent_dps / common_dps))
	else:
		validation_results.warnings += 1
		validation_results.details.append("⚠ Transcendent may be underpowered: %.1fx Common" % 
			(transcendent_dps / common_dps))
	
	return validation_results

func _benchmark_rarity_grade(base_stats: WeaponStats, grade: int) -> void:
	"""Benchmark a specific rarity grade"""
	var rarity: WeaponRarity = WeaponRarity.new(grade)
	print("Benchmarking Grade %d (%s)..." % [grade, rarity.rarity_name])
	
	# Generate weapon variant
	var weapon_variant: WeaponStats = base_stats.create_rarity_variant(grade)
	
	# Record estimated DPS
	var estimated_dps: float = weapon_variant.get_dps_estimate()
	
	var grade_result: Dictionary = {
		"grade": grade,
		"rarity_name": rarity.rarity_name,
		"estimated_dps": estimated_dps,
		"damage_modifier": weapon_variant.applied_damage_modifier,
		"cooldown_modifier": weapon_variant.applied_cooldown_modifier,
		"range_modifier": weapon_variant.applied_range_modifier,
		"critical_chance": weapon_variant.current_critical_chance,
		"critical_multiplier": weapon_variant.current_critical_multiplier,
		"accuracy": weapon_variant.current_accuracy,
		"max_level": weapon_variant.current_max_level
	}
	
	benchmark_data.append(grade_result)
	current_results[grade] = grade_result

func _on_benchmark_completed(results: Dictionary) -> void:
	"""Handle completion of individual DPS benchmark"""
	print("Individual benchmark completed: %s" % str(results))

func _generate_final_report() -> void:
	"""Generate comprehensive rarity benchmark report"""
	print("\n=== RARITY BENCHMARK REPORT ===")
	
	# Sort by grade
	benchmark_data.sort_custom(func(a, b): return a.grade < b.grade)
	
	# Print summary table
	print("Grade | Rarity        | Est.DPS | Dmg% | Speed% | Crit% | Acc%  | MaxLvl")
	print("------|---------------|---------|------|--------|-------|-------|-------")
	
	for result in benchmark_data:
		print("%5d | %-13s | %7.2f | %+4.0f | %+5.0f | %5.1f | %5.1f | %6d" % [
			result.grade,
			result.rarity_name,
			result.estimated_dps,
			result.damage_modifier,
			result.cooldown_modifier,
			result.critical_chance,
			result.accuracy,
			result.max_level
		])
	
	# Calculate power scaling
	if benchmark_data.size() >= 10:
		var common_dps: float = benchmark_data[2].estimated_dps  # Grade 2 = Common
		print("\nPower Scaling (relative to Common):")
		for result in benchmark_data:
			var scale: float = result.estimated_dps / common_dps
			print("  %s: %.2fx" % [result.rarity_name, scale])

func _print_comparative_report(results: Dictionary) -> void:
	"""Print comparative analysis report"""
	print("\n=== COMPARATIVE RARITY ANALYSIS ===")
	
	for weapon_name in results.keys():
		print("\n%s:" % weapon_name)
		var weapon_data: Dictionary = results[weapon_name]
		
		for grade in range(10):
			if weapon_data.has(grade):
				var data: Dictionary = weapon_data[grade]
				print("  Grade %d (%s): DPS %.2f (Dmg: %+.0f%%, Crit: %.1f%%)" % [
					grade, data.rarity_name, data.estimated_dps,
					data.damage_modifier, data.critical_chance
				])

func _calculate_average(values: Array[float]) -> float:
	"""Calculate average of float array"""
	if values.is_empty():
		return 0.0
	
	var sum: float = 0.0
	for value in values:
		sum += value
	return sum / float(values.size())

func _calculate_standard_deviation(values: Array[float], mean: float) -> float:
	"""Calculate standard deviation"""
	if values.size() <= 1:
		return 0.0
	
	var variance_sum: float = 0.0
	for value in values:
		var diff: float = value - mean
		variance_sum += diff * diff
	
	var variance: float = variance_sum / float(values.size() - 1)
	return sqrt(variance)