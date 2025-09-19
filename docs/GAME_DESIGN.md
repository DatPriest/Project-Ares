# Game Design Documentation

This document contains comprehensive information about the game design systems in Project Ares, including weapon systems, upgrades, and loot mechanics.

## Table of Contents
- [Weapon & Upgrade System](#weapon--upgrade-system)
- [Weapon Rarity, Condition, and Stat System](#weapon-rarity-condition-and-stat-system)

---

# Weapon & Upgrade System

## Overview
Project Ares features an expanded weapon and upgrade system with multiple weapon types, synergies, strategic progression paths, and multiplayer cooperative abilities.

## Weapon Types

### 1. Melee Weapons (Existing)
- **Sword**: Basic melee with close-range targeting
- **Axe**: Area melee attack around player
- **Double Sword**: Enhanced melee version

### 2. Ranged Weapons (NEW)
- **Bow**: Fires arrows at closest enemies
  - Projectile-based with collision detection
  - Upgrades: damage, fire rate, multishot, arrow speed
  - Range-limited for balance

### 3. Magic Weapons (NEW) 
- **Magic Staff**: AOE spellcaster
  - Intelligent cluster targeting for optimal AOE placement
  - Explosive fireballs with area damage
  - Upgrades: damage, casting rate, explosion radius, multicast

### 4. Defensive Weapons (NEW)
- **Shield Orbs**: Orbital defensive system
  - Orbs rotate around player automatically
  - Damage enemies on contact while protecting player
  - Upgrades: damage, orb count, rotation speed

## Synergy System

### Two-Weapon Synergies
- **Flaming Arrows** (Bow + Magic Staff): Arrows explode on impact

### Ultimate Synergy
- **Elemental Mastery** (All 3 weapon types): +25% damage to all abilities

### How Synergies Work
1. Player acquires required base weapons
2. Synergy becomes available in upgrade pool with higher weight
3. Synergy upgrades modify existing weapon behavior
4. Multiple synergies can be active simultaneously

## Strategic Progression Paths

### Specialization Paths (Mutually Exclusive)
- **Berserker Path**: Melee specialization (+50% melee damage, -20% health)
  - Requires: Axe + Sword Damage + Level 5
- **Archer Path**: Ranged specialization (+30% projectile speed, piercing)  
  - Requires: Bow + Multishot + Level 5

### Weapon Evolution (High Level)
- **Storm Bow** (Level 8): Evolved bow with lightning chains and piercing
- **Inferno Staff** (Level 8): Evolved staff with burning ground effects

## Multiplayer Cooperative Abilities

### Team Buffs
- **Team Aura**: Damage buff for nearby teammates
- **Experience Share**: 15% XP sharing with nearby allies
- **Team Fortress**: Protective barrier when near teammates (requires Shield)

### Multiplayer Requirements  
- Automatically detected via `multiplayer.get_peers().size() > 0`
- Some abilities are multiplayer-exclusive
- Team abilities use proximity detection

## Technical Implementation

### File Structure
```
resources/upgrades/
├── [weapon].tres                    # Base weapons
├── [weapon]_[upgrade].tres          # Weapon upgrades  
├── strategic_upgrade.gd             # Strategic upgrade class
├── multiplayer/                     # Team abilities
└── synergies/                       # Synergy definitions

scenes/ability/
├── [weapon]_ability_controller/     # Weapon logic
├── [weapon]_ability/               # Weapon effects/projectiles
└── team_abilities/                 # Multiplayer abilities
```

### Key Classes

#### `StrategicUpgrade`
Extends `AbilityUpgrade` with advanced requirements:
- `prerequisite_upgrades`: Required abilities
- `minimum_level`: Level gate
- `requires_multiplayer`: Multiplayer requirement
- `mutually_exclusive_with`: Conflicting upgrades

#### `WeaponSynergy` 
Defines weapon combination requirements and effects.

### Integration Points

#### `UpgradeManager`
- Manages upgrade pool and weights
- Handles synergy detection via `_check_and_add_synergies()`
- Validates strategic upgrade prerequisites
- Detects multiplayer state for exclusive abilities

#### `GameEvents`
- `ability_upgrade_added`: Notifies all systems of new upgrades
- `ability_spawn_requested`: Spawns weapon effects
- `projectile_spawn_requested`: Spawns projectiles

## Adding New Weapons

### 1. Create Ability Controller
```gdscript
extends Node
# Handle weapon timing, targeting, and upgrade effects
```

### 2. Create Weapon Effect/Projectile  
```gdscript  
extends Node2D
# Handle damage, movement, and collision
```

### 3. Create Upgrade Resources
```gdscript
# Base weapon (.tres file using Ability class)
# Upgrade variants (.tres files using AbilityUpgrade class)
```

### 4. Update UpgradeManager
```gdscript
# Add weapon variables
# Add to upgrade pool in _ready()
# Add upgrade unlocks in update_upgrade_pool()
```

### 5. Create Scene Files (.tscn)
- Weapon controller scene with Timer node
- Weapon effect scene with HitboxComponent

## Balancing Guidelines

### Damage Values
- Melee: 3-6 base damage (close range risk)
- Ranged: 4-5 base damage (safer, limited range)  
- Magic: 5-7 base damage (AOE but slower)
- Defensive: 2-4 base damage (persistent)

### Upgrade Scaling
- Damage upgrades: +15% per level
- Rate upgrades: +10% per level  
- Utility upgrades: Varies by effect

### Weight Distribution  
- Base weapons: 10 weight
- Common upgrades: 8-10 weight
- Synergies: 15-20 weight (prioritized)
- Strategic paths: 12 weight
- Multiplayer abilities: 8 weight

This system creates meaningful progression choices while maintaining balance and encouraging experimentation with different weapon combinations.

---

# Weapon Rarity, Condition, and Stat System

## Overview

The Weapon Rarity System introduces a comprehensive loot and progression system to Project Ares, featuring 10 rarity grades, weapon conditions, dynamic stats with positive/negative values, and deep upgrade progression.

## System Components

### 1. Weapon Rarity (10 Grades)

| Grade | Name | Max Level | Stat Range | Drop Weight | Color |
|-------|------|-----------|------------|-------------|--------|
| 1 | Common | 10 | ±30 | 100 | White |
| 2 | Uncommon | 20 | ±60 | 70 | Green |
| 3 | Rare | 30 | ±90 | 50 | Blue |
| 4 | Epic | 40 | ±120 | 30 | Purple |
| 5 | Legendary | 50 | ±150 | 20 | Orange |
| 6 | Mythic | 60 | ±180 | 15 | Red |
| 7 | Divine | 70 | ±210 | 10 | Gold |
| 8 | Cosmic | 80 | ±240 | 7 | Cyan |
| 9 | Transcendent | 90 | ±270 | 5 | Magenta |
| 10 | Omnipotent | 100 | ±300 | 2 | Yellow |

### 2. Weapon Conditions

| Condition | Damage Mod | Speed Mod | Value Mod | Drop Weight |
|-----------|------------|-----------|-----------|-------------|
| Worn | 80% | 90% | 60% | 25 |
| Used | 90% | 95% | 80% | 35 |
| Good | 100% | 100% | 100% | 30 |
| New | 110% | 105% | 130% | 8 |
| Pristine | 120% | 110% | 180% | 2 |

### 3. Weapon Stats (12 Types)

- **Damage**: Flat damage bonus/penalty
- **Fire Rate**: Attack speed modifier (%)
- **Range**: Attack range modifier
- **Critical Chance**: Crit probability (%)
- **Critical Damage**: Crit damage multiplier (%)
- **Penetration**: Armor penetration
- **Projectile Count**: Number of projectiles
- **Projectile Speed**: Projectile velocity
- **Area of Effect**: AoE radius
- **Life Steal**: HP recovery on hit (%)
- **Status Chance**: Status effect probability (%)
- **Reload Speed**: Reload speed modifier (%)

Each stat has ±3 random variance for unique weapon drops.

## Key Features

### Dynamic Stat System
- **Positive Stats**: Enhance weapon performance
- **Negative Stats**: Create meaningful trade-offs
- **Random Variance**: ±3 on all stats ensures every weapon is unique
- **Condition Effects**: Weapon condition modifies stats

### Upgrade Progression
- **Level-Based**: Each rarity grade supports 10 additional upgrade levels
- **Scaling Bonuses**: Stats improve with upgrade level
- **DPS Calculation**: Comprehensive damage-per-second calculation
- **Trade Value**: Calculated based on rarity, condition, stats, and level

### Integration Points

#### With Existing Systems
- **UpgradeManager**: Seamlessly integrates with current upgrade flow
- **GameEvents**: Uses event system for weapon notifications
- **Resource System**: Follows existing .tres resource patterns
- **Ability Controllers**: Compatible with current weapon controllers

#### GameEvents Added
```gdscript
signal weapon_instance_created(weapon_instance: WeaponInstance)
signal weapon_instance_upgraded(weapon_instance: WeaponInstance, new_level: int)
signal weapon_rarity_discovered(rarity: WeaponRarity)
```

## Usage Examples

### Basic Weapon Generation
```gdscript
var factory = WeaponFactory.new()
var weapon = factory.generate_weapon_instance("bow")
print(weapon.get_description())
```

### Forced Rarity/Condition
```gdscript
var epic_rarity = factory.get_rarity_by_id("epic")
var pristine_condition = factory.get_condition_by_id("pristine")
var weapon = factory.generate_weapon_instance("sword", epic_rarity, pristine_condition)
```

### Level-Based Drops
```gdscript
var player_level = 25
var weapon = factory.generate_weapon_drop("magic_staff", player_level)
```

### Integration with UpgradeManager
```gdscript
var weapon_system_manager = WeaponSystemManager.new()
weapon_system_manager.upgrade_manager = upgrade_manager

# Automatically handles weapon upgrades from existing system
# Connects to GameEvents.ability_upgrade_added
```

## File Structure

```
resources/weapon_system/
├── weapon_rarity.gd          # Rarity grade definition
├── weapon_condition.gd       # Condition effects
├── weapon_stat.gd           # Individual stat management
├── weapon_instance.gd       # Complete weapon instance
├── weapon_factory.gd        # Weapon generation
└── rarities/               # Rarity resource files (.tres)
    └── conditions/         # Condition resource files (.tres)

scenes/manager/
└── weapon_system_manager.gd # Integration with existing systems

test_weapon_system.gd       # Comprehensive test suite
test_weapon_integration.gd  # Integration tests
weapon_system_demo.gd      # Demo showcase
```

## Testing

### Unit Tests
- Stat range validation per rarity grade
- Random variance application
- Condition modifier effects
- Upgrade level progression
- DPS calculation accuracy
- Edge case handling

### Integration Tests
- UpgradeManager integration
- GameEvents integration
- Weapon drop generation
- Save/load functionality

### Test Commands
```gdscript
# Run comprehensive tests
var test_runner = preload("res://test_weapon_system.gd").new()
add_child(test_runner)

# Run integration tests
var integration_test = preload("res://test_weapon_integration.gd").new()
add_child(integration_test)

# See demo
var demo = preload("res://weapon_system_demo.gd").new()
add_child(demo)
```

## Performance Considerations

- **Memory Efficient**: Resource-based approach minimizes memory usage
- **Fast Generation**: Weighted tables for O(1) random selection
- **Lazy Loading**: Resources loaded on-demand
- **Event-Driven**: Decoupled architecture for performance

## Future Extensions

- **Weapon Durability**: Using condition system
- **Special Effects**: Status effect system integration
- **Crafting System**: Combine weapons/modify stats
- **Legendary Effects**: Unique properties for high-tier weapons
- **Set Bonuses**: Multiple weapon synergies
- **Player Trading**: Using trade value calculations

## Migration from Existing System

The weapon system is designed to integrate seamlessly with the existing upgrade system:

1. **Existing Weapons**: Automatically get Common rarity, Good condition instances
2. **Upgrade Compatibility**: All existing upgrades work through WeaponSystemManager
3. **Event Compatibility**: Uses existing GameEvents pattern
4. **Zero Breaking Changes**: Existing code continues to work

## Configuration

All weapon properties are configurable through the WeaponFactory resource definitions. To add new rarities or conditions, simply modify the factory's data arrays or create new .tres resource files.

## Validation

The system includes comprehensive validation:
- Stat range validation per rarity
- Upgrade level bounds checking
- DPS calculation verification
- Resource integrity checks

Use `WeaponFactory.validate_weapon_instance()` to verify weapon instances meet all system requirements.