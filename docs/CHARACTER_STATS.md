# Character Stats System

The Character Stats System provides deep character customization and build variety through a comprehensive stat system that supports both positive and negative modifiers.

## Overview

The system follows the established component-based architecture and integrates seamlessly with existing game systems like weapons, upgrades, and experience.

## Core Components

### CharacterStat Resource
- **File**: `resources/character_stats/character_stat.gd`
- **Purpose**: Represents individual stats with type, value, and display properties
- **Features**: 
  - Positive/negative values
  - Random variance (±2)
  - Proper formatting and colors
  - Min/max constraints

### CharacterStatsComponent
- **File**: `scenes/component/character_stats_component.gd`
- **Purpose**: Manages all character stats for a character
- **Features**:
  - Stat initialization and modification
  - Integration with existing systems
  - Event-driven updates

### CharacterStatsDisplay UI
- **File**: `scenes/ui/character_stats_display.gd`
- **Purpose**: Displays character stats in the UI
- **Features**:
  - Automatic updates
  - Color-coded values
  - Scrollable display

## Available Stats (20 Types)

### Core Stats
- **Health**: Maximum health points
- **Stamina**: Energy for special abilities
- **Speed**: Movement speed modifier (%)

### Combat Stats
- **Damage**: Flat damage bonus
- **Critical Chance**: Critical hit probability (%)
- **Critical Damage**: Critical hit damage multiplier (%)
- **Attack Speed**: Attack speed modifier (%)

### Defensive Stats
- **Armor Rating**: Physical damage reduction
- **Magic Resistance**: Magic damage reduction (%)
- **Fire Resistance**: Fire damage reduction (%)
- **Ice Resistance**: Ice damage reduction (%)
- **Poison Resistance**: Poison damage reduction (%)

### Utility Stats
- **Luck**: Affects drops and critical hits
- **Experience Gain**: Experience bonus (%)
- **Drop Rate**: Item drop rate bonus (%)
- **Pickup Range**: Item pickup range bonus (pixels)

### Advanced Stats
- **Agility**: Affects dodge and movement
- **Intelligence**: Affects magic abilities
- **Skill Proficiency**: Skill effectiveness (%)
- **Regeneration**: Health regeneration rate (%)

## Usage Examples

### Adding Stats to a Character

```gdscript
# Get the character's stats component
var stats_component = player.get_character_stats_component()

# Modify stats
stats_component.modify_stat(CharacterStat.StatType.HEALTH, 25.0)     # +25 health
stats_component.modify_stat(CharacterStat.StatType.SPEED, 15.0)      # +15% speed
stats_component.modify_stat(CharacterStat.StatType.DAMAGE, -5.0)     # -5 damage (trade-off)
```

### Creating Upgrade Resources

```gdscript
# In upgrade resource (.tres file)
id = "health_boost"
max_quantity = 5
name = "Health Boost"
description = "Increases maximum health by 25 points."
```

### Integration with Upgrade Manager

```gdscript
# In upgrade_manager.gd
func _apply_character_stat_upgrade(upgrade: AbilityUpgrade) -> void:
    match upgrade.id:
        "health_boost":
            stats_component.modify_stat(CharacterStat.StatType.HEALTH, 25.0)
```

## Integration Points

### Player Integration
- Speed affects velocity component
- Health affects health component
- Experience affects experience manager

### Weapon System Integration
- Damage bonuses stack with weapon damage
- Critical stats affect weapon criticals
- Ready for future weapon stat interactions

### UI Integration
- Stats display automatically updates
- Color-coded positive/negative values
- Proper formatting for percentages

## Build Archetypes

The system supports various character builds:

### Glass Cannon
- High damage and critical stats
- Lower health and armor (trade-offs)
- High risk, high reward

### Tank
- High health, armor, and resistances
- Lower speed and damage (trade-offs)
- Survivability focused

### Speed Build
- High speed and critical chance
- Lower defensive stats
- Hit-and-run tactics

### Scholar
- High experience gain and luck
- Balanced combat stats
- Progression focused

## Testing

Run the test files to verify functionality:
- `test_character_stats.gd` - Core functionality tests
- `test_character_stats_integration.gd` - System integration tests
- `character_stats_demo.gd` - Basic demonstration
- `character_stats_visual_test.gd` - Visual demonstration

## Expansion

The system is designed for easy expansion:

1. **New Stats**: Add to `StatType` enum and `_setup_display_properties()`
2. **New Upgrades**: Create upgrade resources and add to upgrade manager
3. **New Integrations**: Connect stats to new game systems via component methods

## Best Practices

1. **Use Trade-offs**: Balance powerful positive stats with negative ones
2. **Respect Constraints**: Stats have min/max values for balance
3. **Event-Driven**: Use signals for loose coupling
4. **Component-Based**: Follow established architecture patterns
5. **Test Integration**: Verify new stats work with existing systems