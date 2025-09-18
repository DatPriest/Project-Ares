# Integrating DPS Benchmark into Project Ares

This document explains how to integrate the DPS benchmark system into the main game for easy developer access.

## Option 1: Add to Main Menu (Recommended)

Add a "Developer Tools" or "Testing" button to the main menu that opens the benchmark scene.

### In main_menu.gd:
```gdscript
# Add export variable for benchmark scene
@export var dps_benchmark_scene: PackedScene

# Add button handler
func _on_dps_benchmark_button_pressed():
    if dps_benchmark_scene:
        get_tree().change_scene_to_packed(dps_benchmark_scene)
```

### In main_menu.tscn:
1. Add a button labeled "DPS Benchmark" (only visible in debug builds)
2. Connect the button's pressed signal to the handler above
3. Set the benchmark scene export to `res://scenes/test/dps_benchmark/dps_test_scene.tscn`

## Option 2: Debug Key Binding

Add a debug key binding that can launch the benchmark from anywhere in the game.

### In project.godot Input Map:
Add a new input action: `debug_dps_benchmark` (e.g., Ctrl+Shift+D)

### In main game scenes:
```gdscript
func _unhandled_input(event):
    if OS.is_debug_build() and event.is_action_pressed("debug_dps_benchmark"):
        get_tree().change_scene_to_file("res://scenes/test/dps_benchmark/dps_test_scene.tscn")
```

## Option 3: Console Command

If you have a debug console system, add a command:

```gdscript
# In console system
register_command("dps_benchmark", _run_dps_benchmark)

func _run_dps_benchmark():
    get_tree().change_scene_to_file("res://scenes/test/dps_benchmark/dps_test_scene.tscn")
```

## Option 4: Standalone Launch

The benchmark can also be run independently:

1. Set `dps_test_scene.tscn` as the main scene temporarily in Project Settings
2. Run the project to execute benchmark tests
3. Restore the original main scene when done

## Recommended Setup

For development workflow, we recommend:

1. Add Option 2 (debug key binding) for quick access during development
2. Add Option 1 (main menu button) for organized testing sessions
3. Only show testing options in debug builds:

```gdscript
func _ready():
    if not OS.is_debug_build():
        $TestingButton.hide()
```

## CI/CD Integration

The benchmark system can be automated in CI/CD:

```yaml
# Example GitHub Action step
- name: Run DPS Benchmarks
  run: |
    godot --headless --main-pack game.pck --script-expr "
      get_tree().change_scene_to_file('res://scenes/test/dps_benchmark/dps_test_scene.tscn')
      await get_tree().create_timer(60).timeout
      get_tree().quit()
    "
```

This will run benchmarks and save results to user:// directory for analysis.