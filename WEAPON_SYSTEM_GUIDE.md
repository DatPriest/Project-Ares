# Weapon & Upgrade System Guide

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