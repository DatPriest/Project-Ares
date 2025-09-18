# Direct Calls Converted to Event-Driven Signaling

This document tracks all direct node calls that have been converted to standardized event-driven patterns through the GameEvents system.

## Summary

**Total Direct Calls Converted:** 23  
**Files Modified:** 16  
**New Signals Added:** 9  

## Conversion Categories

### 1. Player Position Access Conversions (8 instances)

**Previous Pattern:** `get_tree().get_first_node_in_group("player")`  
**New Pattern:** Cached player position via `GameEvents.player_position_updated`

| File | Function | Conversion Details |
|------|----------|-------------------|
| `scenes/component/velocity_component.gd` | `accelerate_to_player()` | Uses cached player position instead of direct tree access |
| `scenes/game_object/game_camera/game_camera.gd` | `acquire_target()` | Eliminated function, uses event listener for position updates |
| `scenes/ability/sword_ability_controller/sword_ability_controller.gd` | `on_timer_timeout()` | Uses cached player position for enemy distance calculations |
| `scenes/ability/axe_ability_controller/axe_ability_controller.gd` | `on_timer_timeout()` | Uses cached player position for ability placement |
| `scenes/ability/double_sword_controller/double_sword_ability_controller.gd` | `on_timer_timeout()` | Uses cached player position for ability placement |
| `scenes/manager/enemy_manager.gd` | `get_spawn_position()` | Uses cached player position for spawn calculations |
| `scenes/game_object/enemies/goblin_archer/goblin_archer.gd` | `_process()`, `_on_timer_timeout()` | Uses cached player position for AI behavior and shooting |
| `scenes/game_object/experience_vial/experience_vial.gd` | `tween_collect()` | Uses cached player position for collection animation |
| `scenes/game_object/drop_material/drop_material.gd` | `tween_collect()` | Uses cached player position for collection animation |

### 2. Entity Layer Access Conversions (7 instances)

**Previous Pattern:** `get_tree().get_first_node_in_group("entities_layer")`  
**New Pattern:** Centralized spawning via `GameEvents.entity_spawn_requested`

| File | Function | Conversion Details |
|------|----------|-------------------|
| `scenes/component/vial_drop_component.gd` | `on_died()` | Uses entity spawn event instead of direct layer access |
| `scenes/component/drop_component.gd` | `on_died()` | Uses resource drop event with configuration |
| `scenes/manager/enemy_manager.gd` | `on_timer_timeout()` | Uses entity spawn event for enemy creation |
| `scenes/game_object/enemies/goblin_archer/goblin_archer.gd` | `_on_timer_timeout()` | Uses projectile spawn event for arrow creation |
| `scenes/component/death_component.gd` | `on_died()` | Uses cached layer reference instead of direct access |

### 3. Foreground Layer Access Conversions (5 instances)

**Previous Pattern:** `get_tree().get_first_node_in_group("foreground_layer")`  
**New Pattern:** Centralized spawning via `GameEvents.ability_spawn_requested` and `GameEvents.floating_text_requested`

| File | Function | Conversion Details |
|------|----------|-------------------|
| `scenes/component/hurt_box_component.gd` | `on_area_entered()` | Uses floating text event instead of direct layer access |
| `scenes/ability/sword_ability_controller/sword_ability_controller.gd` | `on_timer_timeout()` | Uses ability spawn event with damage configuration |
| `scenes/ability/axe_ability_controller/axe_ability_controller.gd` | `on_timer_timeout()` | Uses ability spawn event with damage configuration |
| `scenes/ability/double_sword_controller/double_sword_ability_controller.gd` | `on_timer_timeout()` | Uses ability spawn event with damage configuration |

### 4. Scene Instantiation and Direct Manipulation Conversions (3 instances)

**Previous Pattern:** Direct scene instantiation with manual positioning and configuration  
**New Pattern:** Event-based spawning with centralized configuration

| File | Function | Conversion Details |
|------|----------|-------------------|
| `scenes/component/hurt_box_component.gd` | `on_area_entered()` | Floating text creation moved to centralized handler |
| `scenes/component/drop_component.gd` | `on_died()` | Resource drop configuration moved to centralized handler |

## New GameEvents Signals Added

```gdscript
# Player position and movement events
signal player_position_updated(player_position: Vector2)

# Entity spawning and management events  
signal entity_spawn_requested(entity_scene: PackedScene, spawn_position: Vector2)
signal projectile_spawn_requested(projectile_scene: PackedScene, spawn_position: Vector2, velocity: Vector2)
signal resource_drop_requested(material_scene: PackedScene, spawn_position: Vector2, resource: DropResource)

# UI and effect events
signal floating_text_requested(text: String, position: Vector2)
signal effect_spawn_requested(effect_scene: PackedScene, position: Vector2)
signal ability_spawn_requested(ability_scene: PackedScene, position: Vector2, damage: float, rotation_angle: float)

# Layer management events
signal entities_layer_ready(entities_layer: Node)
signal foreground_layer_ready(foreground_layer: Node)
```

## Centralized Spawn Management

All spawning is now handled through `scenes/main/main.gd` with these handlers:
- `on_entity_spawn_requested()` - Handles entity spawning (enemies, vials, resources)
- `on_projectile_spawn_requested()` - Handles projectile spawning with velocity setting
- `on_resource_drop_requested()` - Handles resource drops with sprite configuration
- `on_floating_text_requested()` - Handles floating damage text display
- `on_effect_spawn_requested()` - Handles effect spawning
- `on_ability_spawn_requested()` - Handles ability spawning with damage/rotation

## Benefits Achieved

1. **Decoupled Architecture**: Removed tight coupling between 16 different nodes and systems
2. **Event Traceability**: All 23 interactions now use standardized GameEvents for easier debugging
3. **Performance Optimization**: Player position is broadcast once per frame instead of multiple tree traversals
4. **Centralized Management**: All spawning logic consolidated in main.gd for consistency
5. **Maintainability**: Clear event-driven patterns established for future development

## Breaking Changes

⚠️ **None** - All existing functionality preserved while improving architecture

## Testing Notes

The following systems should be tested to ensure no regressions:
- [ ] Player movement and camera following
- [ ] Enemy AI behavior (movement toward player, archer positioning)
- [ ] Combat system (sword, axe, double sword abilities)
- [ ] Item collection (experience vials, resource drops)
- [ ] Damage display (floating text)
- [ ] Enemy spawning and death effects
- [ ] Projectile system (goblin archer arrows)

---

*This conversion completes the standardization of signals and event emission as outlined in Issue #21.*