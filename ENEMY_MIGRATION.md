# Enemy System Migration Guide

## Before vs After Comparison

### Old System (Scene-Based)
- **4 separate enemy scenes** (basic_enemy.tscn, wizard_enemy.tscn, goblin_enemy.tscn, goblin_archer.tscn)
- **4 separate enemy scripts** with hardcoded behaviors
- **Stats embedded in scenes** - difficult to balance
- **Duplicate component configurations** across scenes
- **Hard to add new enemy types** - requires new scene + script

### New System (Resource-Based)
- **1 generic enemy scene** (generic_enemy.tscn)
- **1 generic enemy script** that handles all behaviors
- **Stats in resource files** - easy to balance and modify
- **Consistent component configuration** - all enemies use same scene structure
- **Easy to add new enemy types** - just create new .tres resource file

## Migration Benefits

| Aspect | Old System | New System |
|--------|------------|------------|
| Files needed for new enemy | 2 files (.tscn + .gd) | 1 file (.tres) |
| Balancing enemy stats | Edit scene files | Edit resource files |
| Code duplication | High (4 separate scripts) | Low (1 shared script) |
| Component consistency | Manual sync required | Automatic |
| Behavior customization | Hardcoded in scripts | Data-driven configuration |

## Example: Adding a "Fast Enemy"

### Old System
1. Duplicate basic_enemy.tscn → fast_enemy.tscn  
2. Create fast_enemy.gd script
3. Configure health/velocity components in scene
4. Update enemy_manager.gd to reference new scene
5. Export new scene reference in enemy manager

### New System  
1. Create fast_enemy_data.tres resource
2. Set max_speed = 80, max_health = 5
3. Reference in enemy_manager.gd

```gdscript
# Just add one line in enemy_manager!
@export var fast_enemy_data: EnemyData

func _ready():
    enemy_table.add_item(fast_enemy_data, 15)
```

## Backwards Compatibility

The old enemy scenes will still work because:
- BaseEnemy now provides default behavior 
- All component interfaces remain the same
- GenericEnemy extends BaseEnemy with additional data-driven features

## Testing the Migration

To verify the new system works:
1. Replace enemy scene references with generic_enemy.tscn
2. Assign appropriate EnemyData resources
3. Verify all enemy types spawn and behave correctly
4. Confirm XP rewards and stats match expected values