# Weapon Rarity System Concept

## Overview

Project Ares implements a comprehensive 10-tier weapon rarity system that introduces significant depth to weapon progression, stats variation, and player strategy. This system allows for both positive and negative stat modifiers, extended level progression, and sophisticated balancing mechanics.

## Rarity Grades

### The 10 Rarity Tiers

| Grade | Name | Color | Max Level | Drop Rate | Description |
|-------|------|--------|-----------|-----------|-------------|
| 0 | Broken | Dark Brown | 5 | 5% | Severely damaged weapons with negative stats |
| 1 | Poor | Gray | 10 | 15% | Low-quality weapons with mostly negative modifiers |
| 2 | Common | White | 20 | 40% | Standard weapons with balanced stat ranges |
| 3 | Uncommon | Green | 30 | 25% | Above-average weapons with positive bias |
| 4 | Rare | Blue | 40 | 10% | High-quality weapons with significant bonuses |
| 5 | Epic | Purple | 50 | 4% | Exceptional weapons with powerful modifiers |
| 6 | Legendary | Orange | 60 | 0.8% | Legendary weapons with extreme bonuses |
| 7 | Mythic | Red | 70 | 0.1% | Mythical weapons with game-changing stats |
| 8 | Divine | Gold | 80 | 0.05% | Divine weapons with overwhelming power |
| 9 | Transcendent | Brilliant White | 90 | 0.01% | Ultimate weapons that transcend normal limits |

### Level Progression System

Each rarity grade allows 10 additional maximum levels beyond the previous tier:
- **Broken (0)**: Levels 0-5 (limited upgrade potential)
- **Poor (1)**: Levels 0-10
- **Common (2)**: Levels 0-20
- **Uncommon (3)**: Levels 0-30
- **Rare (4)**: Levels 0-40
- **Epic (5)**: Levels 0-50
- **Legendary (6)**: Levels 0-60
- **Mythic (7)**: Levels 0-70
- **Divine (8)**: Levels 0-80
- **Transcendent (9)**: Levels 0-90

## Stat System

### Core Stats with Rarity Modifiers

Each weapon has base stats that are modified by randomly generated values within rarity-specific ranges:

#### Primary Combat Stats
- **Damage Modifier**: Affects base weapon damage
- **Cooldown Modifier**: Affects attack speed (negative = faster)
- **Range Modifier**: Affects weapon reach/projectile distance
- **Critical Chance**: Percentage chance for critical hits
- **Critical Multiplier**: Damage multiplier for critical hits

#### Extended Stats
- **Durability**: Weapon condition and longevity
- **Mana Cost**: Resource cost for magical weapons
- **Accuracy**: Hit chance percentage

### Stat Ranges by Rarity

#### Broken Weapons (Grade 0)
- Damage: -50% to -20% (always negative)
- Cooldown: +20% to +50% (always slower)
- Range: -30% to -10% (reduced range)
- Critical: 0% to 1% chance, 1.0x to 1.1x multiplier
- Durability: -50% to -30% (fragile)
- Accuracy: -30% to -15% (poor aim)

#### Poor Weapons (Grade 1)
- Damage: -30% to 0% (mostly negative)
- Cooldown: 0% to +30% (slower to normal)
- Range: -20% to 0% (reduced to normal)
- Critical: 0% to 2% chance, 1.0x to 1.2x multiplier
- Durability: -30% to -10% (below average)
- Accuracy: -20% to -5% (reduced accuracy)

#### Common Weapons (Grade 2)
- Damage: -10% to +10% (balanced)
- Cooldown: -10% to +10% (balanced)
- Range: -10% to +10% (balanced)
- Critical: 0% to 5% chance, 1.0x to 1.5x multiplier
- Durability: -20% to +20% (variable)
- Accuracy: -15% to +15% (variable)

#### Transcendent Weapons (Grade 9)
- Damage: +150% to +250% (extreme power)
- Cooldown: -80% to -50% (incredibly fast)
- Range: +150% to +200% (massive reach)
- Critical: 60% to 90% chance, 5.0x to 8.0x multiplier
- Durability: +180% to +300% (nearly indestructible)
- Accuracy: +70% to +120% (supernatural precision)

## Negative Stats Implementation

### Philosophy
Lower rarity weapons (Broken, Poor) intentionally have negative stat modifiers to create meaningful progression and risk/reward decisions. Players may choose to use a broken legendary weapon over a perfect common weapon due to the underlying base power difference.

### Functional Limits
- **Minimum Damage**: Weapons can never deal 0 or negative damage
- **Maximum Cooldown**: Cooldowns are clamped to prevent weapons from becoming unusable
- **Accuracy Bounds**: Accuracy is limited to 0-100% range (with exceptions for Divine+ weapons)
- **Mana Cost Floor**: Mana costs cannot go below 0

## Level-Based Progression

### Upgrade Costs
- **Base Cost**: 100 experience points
- **Level Scaling**: Cost increases by 20% per level (exponential growth)
- **Rarity Multiplier**: Higher rarities cost 10% more per grade

Formula: `Cost = 100 * (1.2^level) * (1 + rarity_grade * 0.1)`

### Upgrade Benefits
Each level provides:
- +10% damage increase (modified by rarity)
- +10% attack speed improvement (modified by rarity)
- Potential unlocking of new abilities at certain milestones

## Testing Framework

### Comprehensive Test Coverage

The rarity system includes extensive testing for:

#### Functional Tests
- **Rarity Grade Validation**: All 10 grades work correctly
- **Stat Range Verification**: Modifiers stay within expected bounds
- **Level Progression**: Weapons can upgrade to their maximum levels
- **Negative Stat Handling**: Lower rarities function with negative modifiers

#### Edge Case Tests
- **Invalid Inputs**: Graceful handling of invalid rarity grades
- **Extreme Values**: System behavior with edge-case stat values
- **Null Safety**: Proper handling of missing or null data
- **Performance**: System performance under load

#### DPS Benchmark Integration
- **Comparative Analysis**: DPS comparison across rarities
- **Balance Validation**: Ensuring progression feels meaningful
- **Regression Detection**: Automated detection of balance changes

### False and Negative Scenarios

The test suite specifically validates:
- **Broken Weapon Functionality**: Even severely damaged weapons remain playable
- **Statistical Distribution**: Random generation follows expected patterns  
- **Upgrade Cost Scaling**: Costs increase appropriately with level and rarity
- **Critical Hit Accuracy**: Critical hit rates match theoretical expectations
- **Durability System**: Weapons break and repair correctly
- **Performance Benchmarks**: System maintains acceptable performance

## Balancing Guidelines

### DPS Progression
- **Common to Rare**: ~15-25% DPS increase per rarity grade
- **Epic to Legendary**: ~30-50% DPS increase per grade
- **Mythic and Above**: ~75-100% DPS increase per grade

### Accessibility vs. Power
- **Common Rarities (0-3)**: 85% of all drops, accessible progression
- **Rare Rarities (4-6)**: 14.8% of drops, significant power spikes
- **Legendary+ (7-9)**: 0.2% of drops, game-changing power

### Stat Weighting
Different stats have different impact weights:
- **Damage**: Primary stat, direct DPS impact
- **Attack Speed**: High impact, multiplicative with damage
- **Critical Stats**: Moderate impact, RNG-dependent
- **Utility Stats**: Low combat impact, quality-of-life improvements

## Integration with Existing Systems

### Upgrade Manager Integration
```gdscript
# Enhanced upgrade pool weighting based on rarity
func update_upgrade_pool_with_rarity(player_level: int) -> void:
    for rarity_grade in range(10):
        var rarity_weight: float = WeaponRarity.new(rarity_grade).get_rarity_probability()
        upgrade_pool.add_rarity_weighted_items(rarity_grade, rarity_weight)
```

### DPS Benchmark Integration
```gdscript
# Extended benchmark testing with rarity variants
func benchmark_weapon_rarities(base_weapon: AbilityUpgrade) -> Dictionary:
    var rarity_results: Dictionary = {}
    for grade in range(10):
        var variant: WeaponStats = create_weapon_with_rarity(base_weapon, grade)
        var dps: float = run_dps_test(variant)
        rarity_results[grade] = dps
    return rarity_results
```

### Save System Considerations
```gdscript
# Weapon data serialization with rarity
func serialize_weapon(weapon: WeaponStats) -> Dictionary:
    return {
        "base_stats": weapon.get_base_stats(),
        "rarity_grade": weapon.weapon_rarity.rarity_grade,
        "applied_modifiers": weapon.get_applied_modifiers(),
        "current_level": weapon.current_weapon_level,
        "durability": weapon.current_durability
    }
```

## Future Expansion Possibilities

### Advanced Features
- **Set Bonuses**: Bonuses for using multiple weapons of the same rarity
- **Reforge System**: Ability to reroll rarity modifiers
- **Corruption System**: Temporary negative modifiers for extra power
- **Masterwork Variants**: Ultra-rare perfect-stat versions

### Multiplayer Considerations
- **Rarity Synchronization**: Ensure consistent rarity generation across clients
- **Trade System**: Allow players to trade rare weapons
- **Raid Rewards**: Special high-rarity drops from multiplayer content

### Progression Systems
- **Rarity Mastery**: Unlock bonuses for using specific rarity tiers
- **Collection Goals**: Achievements for collecting weapons of each rarity
- **Crafting Integration**: Use materials to influence rarity outcomes

## Implementation Checklist

- [x] Core `WeaponRarity` resource class with 10 tiers
- [x] Extended `WeaponStats` class with rarity integration  
- [x] Comprehensive stat modifier system with positive/negative ranges
- [x] Level progression system with rarity-based limits
- [x] Durability, critical hit, and accuracy systems
- [x] Extensive test suite covering all scenarios
- [x] Performance optimization and edge case handling
- [ ] Integration with existing upgrade manager
- [ ] Visual rarity indicators in UI
- [ ] Sound effects for different rarity tiers
- [ ] Weapon tooltips showing rarity information
- [ ] Save/load system integration
- [ ] Balance testing and iteration

This rarity system provides a robust foundation for weapon progression that scales from early game accessibility to endgame chase items, while maintaining meaningful choices at every rarity tier.