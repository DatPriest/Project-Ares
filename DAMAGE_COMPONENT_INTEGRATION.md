# DamageComponent Integration Guide

This document explains how to integrate the new centralized `DamageComponent` into existing enemy scenes and scripts.

## Overview

The `DamageComponent` centralizes all damage handling and provides standardized event emission for death and damage events. It automatically:

- Applies damage through the `HealthComponent`
- Shows floating damage text
- Emits `GameEvents.enemy_killed` with experience rewards
- Provides local `damage_taken` and `died` signals

## Integration Steps

### 1. Add DamageComponent to Enemy Scenes

In each enemy scene (`.tscn` file), add the DamageComponent as a child node:

```
[node name="DamageComponent" parent="." node_paths=PackedStringArray("health_component") instance=ExtResource("path_to_damage_component.tscn")]
health_component = NodePath("../HealthComponent")
experience_reward = 1.0
```

### 2. Update HurtBoxComponent References

Update the HurtBoxComponent to reference the DamageComponent:

```
[node name="HurtBoxComponent" parent="." node_paths=PackedStringArray("health_component", "damage_component") instance=ExtResource("path_to_hurtbox_component.tscn")]
health_component = NodePath("../HealthComponent")
damage_component = NodePath("../DamageComponent")
```

### 3. Update Drop Components

Update VialDropComponent and DropComponent references:

```
[node name="VialDropComponent" parent="." node_paths=PackedStringArray("health_component", "damage_component") instance=ExtResource("path_to_vial_drop_component.tscn")]
health_component = NodePath("../HealthComponent")
damage_component = NodePath("../DamageComponent")
```

```
[node name="DropComponent" parent="." node_paths=PackedStringArray("health_component", "damage_component") instance=ExtResource("path_to_drop_component.tscn")]
health_component = NodePath("../HealthComponent")
damage_component = NodePath("../DamageComponent")
```

### 4. Update DeathComponent

Update the DeathComponent to reference the DamageComponent:

```
[node name="DeathComponent" parent="." node_paths=PackedStringArray("health_component", "damage_component", "sprite") instance=ExtResource("path_to_death_component.tscn")]
health_component = NodePath("../HealthComponent")
damage_component = NodePath("../DamageComponent")
sprite = NodePath("../Visuals/Sprite2D")
```

## Configuration

### Experience Rewards

Each enemy can configure its experience reward by setting the `experience_reward` property on the DamageComponent:

- Basic enemies: 1.0
- Goblin enemies: 2.0  
- Wizard enemies: 3.0
- Goblin archers: 2.5

### Backward Compatibility

The system is designed to be backward compatible. All components will work with or without the DamageComponent:

- If `damage_component` is set, it will be used for damage handling
- If not set, the component falls back to direct `health_component` usage

## Benefits

1. **Centralized Logic**: All damage flows through one component
2. **Consistent Events**: `GameEvents.enemy_killed` is always emitted
3. **Standardized Experience**: Experience rewards are configurable per enemy
4. **Floating Text**: Damage numbers are consistently displayed
5. **Easy Debugging**: All damage logic is in one place

## Testing

After integration, verify that:

1. Enemies take damage and die as expected
2. Experience vials drop correctly
3. `GameEvents.enemy_killed` events are emitted
4. Floating damage numbers appear
5. Death effects and audio play correctly