# Enemy Data Resource System

This directory contains the resource-based enemy definition system that replaces hardcoded enemy scenes with configurable data resources.

## Benefits

- **Easy Balancing**: Enemy stats are in resource files that can be edited without touching scenes
- **Modular Design**: Single generic enemy scene supports all enemy types  
- **Data-Driven**: New enemy types can be added by creating new EnemyData resources
- **Better Organization**: Clear separation between enemy behavior and enemy configuration

## Usage

### Creating a New Enemy Type

1. Create a new `.tres` resource file in this directory
2. Set the script to `EnemyData`
3. Configure the stats, sprite, and behavior type
4. Reference it in the enemy manager

### Enemy Behavior Types

- **Basic**: Moves directly toward player
- **Wizard**: Alternates between moving and pausing
- **Goblin**: Same as wizard (could be customized differently)
- **Archer**: Maintains distance and shoots arrows

### Example Configuration

```gdscript
# In enemy_manager.gd
@export var new_enemy_data: EnemyData

func _ready():
    enemy_table.add_item(new_enemy_data, 15)
```

## Migration Guide

The old system used individual enemy scenes:
- `basic_enemy.tscn` + `basic_enemy.gd`
- `wizard_enemy.tscn` + `wizard_enemy.gd`  
- etc.

The new system uses:
- `generic_enemy.tscn` + `generic_enemy.gd`
- `basic_enemy_data.tres`
- `wizard_enemy_data.tres`
- etc.

All enemy behaviors are now handled by the `GenericEnemy` class based on the `behavior_type` field in the `EnemyData` resource.