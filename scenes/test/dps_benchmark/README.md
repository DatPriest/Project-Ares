# DPS Benchmark Test Scene

This directory contains an automated testing system for benchmarking ability damage per second (DPS) in Project Ares.

## Files

- **`dps_test_scene.tscn`** - Main test scene that can be run independently
- **`dps_test_scene.gd`** - Main controller for orchestrating tests
- **`dps_benchmark_manager.gd`** - Core benchmarking logic and timing
- **`dummy_target.gd`** - Damage tracking target
- **`dummy_target.tscn`** - Target scene with proper collision setup

## How to Use

### Running Tests

1. **In Godot Editor**: Open `dps_test_scene.tscn` and run the scene
2. **Automatic Mode**: Tests will start automatically after 1 second
3. **Manual Mode**: Press SPACE to start tests manually

### Test Sequence

The benchmark runs through these steps for each ability:
1. Spawns a dummy target near the test player
2. Instantiates the ability controller
3. Runs for the configured duration (default: 10 seconds)
4. Tracks all damage dealt during the test period
5. Calculates DPS, hits per second, and average damage
6. Logs results to console and files
7. Moves to next ability

### Results

Results are logged in multiple formats:
- **Console Output**: Real-time results during testing
- **`user://dps_test_results.txt`**: Individual test results log
- **`user://dps_benchmark_report.txt`**: Final ranked comparison report

### Configuration

You can modify test parameters in `dps_test_scene.tscn`:
- **Test Duration**: How long each ability test runs (default: 10 seconds)
- **Ability Controllers**: Which abilities to include in testing
- **Dummy Target**: Health and regeneration settings

## Architecture

### DummyTarget
- Tracks all incoming damage from HitboxComponents
- Regenerates health automatically to allow continuous testing
- Emits damage_taken signals for real-time tracking
- Positioned in "enemy" group so abilities can target it

### DPSBenchmarkManager
- Manages test timing and coordination
- Spawns and cleans up dummy targets
- Calculates DPS metrics and statistics
- Handles sequential testing of multiple abilities

### Test Scene Controller
- Sets up test environment with player and abilities
- Configures which abilities to test
- Generates final reports and file logging
- Provides UI feedback during testing

## Adding New Abilities

To test a new ability:
1. Add the ability controller scene to the test scene exports
2. Update `_get_ability_test_configs()` in `dps_test_scene.gd`
3. Add configuration for the new ability

## Metrics Tracked

For each ability, the benchmark measures:
- **Total Damage**: Sum of all damage dealt
- **Hit Count**: Number of successful hits
- **DPS**: Damage per second (Total Damage / Test Duration)
- **Hits Per Second**: Hit frequency
- **Average Hit Damage**: Mean damage per hit

## Use Cases

This system is designed for:
- **Balance Testing**: Compare abilities for game balance
- **Performance Verification**: Ensure abilities work as intended
- **Regression Testing**: Detect when changes affect ability performance
- **Tuning Support**: Provide data for ability adjustments