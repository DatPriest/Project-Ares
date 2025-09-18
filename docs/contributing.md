# Contributing to Project Ares

Welcome to Project Ares! This guide will help you understand the project architecture, coding standards, and development workflow to contribute effectively.

## Table of Contents

1. [Project Overview](#project-overview)
2. [Architecture](#architecture)
3. [Component System](#component-system)
4. [Singleton Systems](#singleton-systems)
5. [Coding Standards](#coding-standards)
6. [Development Setup](#development-setup)
7. [Git Workflow](#git-workflow)
8. [Testing & Debugging](#testing--debugging)
9. [Directory Structure](#directory-structure)
10. [Resources](#resources)

## Project Overview

**Project Ares** is a 2D top-down action roguelike in the survivor style, developed with **Godot Engine 4** and **GDScript**. Players control a character that automatically attacks and must survive waves of enemies by collecting experience, leveling up, and selecting new abilities or upgrades.

### Core Features

- **Player Progression**: Collect experience points (XP) and level up
- **Ability System**: Automatic attacks through upgradeable abilities
- **Enemy Management**: Dynamic enemy spawning with increasing difficulty
- **Component Architecture**: Reusable nodes for functionality like health, movement, etc.

### Target Features

- **16-Player Multiplayer**: Planned cooperative multiplayer via Steam integration
- **Roguelike Elements**: Procedural upgrades and run-based progression
- **Meta Progression**: Persistent upgrades between runs

## Architecture

Project Ares follows a **component-based architecture** combined with Godot's scene system. Instead of creating monolithic classes, functionality is broken down into small, reusable components that can be combined to create complex game objects.

```
┌─────────────────────────────────────────────────────────┐
│                    Game Architecture                     │
├─────────────────────────────────────────────────────────┤
│  Autoload Singletons (Global Managers)                 │
│  ├── GameEvents (Event Bus)                            │
│  ├── MetaProgression (Persistent Upgrades)             │
│  ├── MusicPlayer (Audio Management)                    │
│  └── ScreenTransition (Scene Management)               │
├─────────────────────────────────────────────────────────┤
│  Scene Structure                                        │
│  ├── Main Scene                                        │
│  ├── Game Objects (Composed of Components)             │
│  │   ├── Player                                        │
│  │   ├── Enemies                                       │
│  │   └── Projectiles                                   │
│  └── UI Layers                                         │
├─────────────────────────────────────────────────────────┤
│  Component System (Reusable Functionality)             │
│  ├── HealthComponent (Health & Death)                  │
│  ├── VelocityComponent (Movement)                      │
│  ├── DamageComponent (Damage Handling)                 │
│  ├── HitboxComponent / HurtboxComponent (Collision)    │
│  └── DropComponent (Item Drops)                        │
├─────────────────────────────────────────────────────────┤
│  Resource System (Data Configuration)                  │
│  ├── AbilityUpgrade (Upgrade Definitions)              │
│  ├── MetaUpgrade (Persistent Upgrades)                 │
│  └── EnemyData (Enemy Configurations)                  │
└─────────────────────────────────────────────────────────┘
```

## Component System

Components are the building blocks of game objects. Each component handles a specific aspect of functionality and can be easily combined to create complex behaviors.

### Core Components

#### HealthComponent
Manages health, damage, and death for any entity.

```gdscript
# Usage Example
@export var health_component: HealthComponent

func _ready() -> void:
    health_component.died.connect(_on_died)

func _on_died() -> void:
    # Handle death logic
```

**Signals:**
- `died`: Emitted when health reaches zero
- `health_changed`: Emitted when health value changes

**Key Methods:**
- `damage(amount: float)`: Apply damage
- `get_health_percent()`: Get health as percentage

#### VelocityComponent
Handles movement and acceleration for entities.

```gdscript
# Usage Example
@export var velocity_component: VelocityComponent

func _physics_process(delta: float) -> void:
    velocity_component.accelerate_to_player()
    velocity = velocity_component.velocity
    move_and_slide()
```

**Key Methods:**
- `accelerate_to_player()`: Move toward player
- `accelerate_in_direction(direction: Vector2)`: Move in specific direction

#### DamageComponent
Centralizes damage handling with floating text and event emission.

```gdscript
# Usage Example  
@export var damage_component: DamageComponent

func _ready() -> void:
    damage_component.damage_taken.connect(_on_damage_taken)
    damage_component.died.connect(_on_died)
```

**Features:**
- Automatic floating damage text
- GameEvents integration for kill rewards
- Centralized damage processing

#### HitboxComponent & HurtboxComponent
Handle collision detection for damage dealing and receiving.

- **HitboxComponent**: Deals damage (attached to weapons, projectiles)
- **HurtboxComponent**: Receives damage (attached to enemies, player)

### Creating New Components

1. Create a new scene inheriting from `Node`
2. Add the component script extending `Node`
3. Use `class_name` to make it accessible in the editor
4. Export necessary references and configuration
5. Use signals for communication with parent objects

```gdscript
extends Node
class_name MyComponent

signal my_event_happened

@export var my_property: float = 1.0
@export var referenced_component: OtherComponent

func _ready() -> void:
    # Initialize component
    
func do_something() -> void:
    # Component functionality
    my_event_happened.emit()
```

## Singleton Systems

Global managers are implemented as Godot Autoloads (Singletons) to provide system-wide functionality.

### GameEvents (Event Bus)

Central communication hub for decoupled system interaction. Instead of direct references, systems communicate through GameEvents signals.

```gdscript
# Emitting events
GameEvents.emit_enemy_killed(experience_amount)
GameEvents.emit_player_damaged()

# Listening to events
func _ready() -> void:
    GameEvents.enemy_killed.connect(_on_enemy_killed)
    GameEvents.player_damaged.connect(_on_player_damaged)
```

**Key Signals:**
- `experience_vial_collected(number: float)`
- `ability_upgrade_added(upgrade: AbilityUpgrade, current_upgrades: Dictionary)`
- `enemy_killed(experience_amount: float)`
- `player_damaged`
- `player_position_updated(player_position: Vector2)`

### MetaProgression

Manages persistent upgrades between game runs.

### MusicPlayer

Controls background music and audio management.

### ScreenTransition

Handles scene transitions and screen effects.

## Coding Standards

Project Ares follows strict GDScript coding standards. For complete details, refer to [`.github/copilot-instructions.md`](../.github/copilot-instructions.md).

### Key Standards

#### 1. Static Typing (Required)
Always use explicit types for variables, parameters, and return values.

```gdscript
# ✅ Good
var health: int = 100
var speed: float = 80.0
var player_node: CharacterBody2D

func apply_damage(amount: int) -> void:
    health -= amount

# ❌ Bad
var health = 100
var player_node

func apply_damage(amount):
    health -= amount
```

#### 2. Naming Conventions

- **Classes/Nodes**: `PascalCase` (e.g., `PlayerController`, `HealthComponent`)
- **Files (scripts & scenes)**: `snake_case` (e.g., `player_controller.gd`, `health_component.tscn`)
- **Variables & Functions**: `snake_case` (e.g., `max_health`, `apply_damage`)
- **Signals**: `past_tense`, `snake_case` (e.g., `died`, `health_updated`)
- **Constants**: `UPPER_SNAKE_CASE` (e.g., `MAX_SPEED`)

#### 3. Node References

Use `@onready` for safe node referencing:

```gdscript
# ✅ Good
@onready var animation_player: AnimationPlayer = $AnimationPlayer

func _ready() -> void:
    animation_player.play("run")
```

#### 4. Exports

Make variables configurable in the editor with explicit typing:

```gdscript
@export var move_speed: float = 100.0
@export var bullet_scene: PackedScene
```

## Development Setup

### Prerequisites

- **Godot Engine 4.2+** ([Download](https://godotengine.org/download))
- **Git** for version control

### Setup Steps

1. **Clone the Repository**
   ```bash
   git clone https://github.com/DatPriest/Project-Ares.git
   cd Project-Ares
   ```

2. **Open in Godot**
   - Launch Godot Engine
   - Click "Import" and select the `project.godot` file
   - Wait for initial import to complete

3. **Test the Setup**
   - Run the project (F5)
   - The main menu should appear
   - Test basic gameplay functionality

### Development Environment

- **Main Scene**: `scenes/ui/main_menu/main_menu.tscn`
- **Player Scene**: `scenes/game_object/player/player.tscn`
- **Test Scenes**: `scenes/test/` directory for testing components

## Git Workflow

### Commit Message Format

Use conventional commit messages with descriptive prefixes:

```
feat: Implement Goblin Archer enemy
fix: Prevent player from moving outside the map  
refactor: Centralize audio playback in AudioManager
docs: Update component documentation
```

### Branching Strategy

1. Create a new branch for each feature/fix:
   ```bash
   git checkout -b feature/new-enemy-type
   ```

2. Make focused commits with clear messages

3. Reference issues in commits:
   ```bash
   git commit -m "feat: Implement Goblin Archer (fixes #1)"
   ```

4. Submit Pull Request when ready for review

## Testing & Debugging

### DPS Benchmark System

Project Ares includes a comprehensive testing system for ability balancing located in `scenes/test/dps_benchmark/`.

**Usage:**
1. Open `scenes/test/dps_benchmark/dps_test_scene.tscn`
2. Run the scene to automatically test all configured abilities
3. Results are logged to console and files

**Adding New Abilities to Test:**
1. Add ability controller scene to test exports
2. Update `_get_ability_test_configs()` in `dps_test_scene.gd`
3. Configure the new ability parameters

### Debug Workflow

1. **Console Logging**: Use `print()` and `push_error()` for debug output
2. **Godot Debugger**: Set breakpoints and inspect variables
3. **Scene Tree**: Monitor node structure and component relationships
4. **Performance Monitoring**: Use Godot's profiler for optimization

## Directory Structure

```
Project-Ares/
├── .github/                    # GitHub configuration
│   ├── copilot-instructions.md # AI coding standards
│   └── copilot/               # Additional AI instructions
├── addons/                    # Godot plugins
├── assets/                    # Game assets (sprites, audio)
├── docs/                      # Documentation
│   └── contributing.md        # This file
├── resources/                 # Data resources
│   ├── enemy_data/           # Enemy configurations
│   ├── meta_upgrades/        # Persistent upgrade data
│   ├── upgrades/             # Ability upgrade definitions
│   └── wave_resources/       # Wave spawn configurations
├── scenes/                    # All Godot scenes
│   ├── ability/              # Ability controllers
│   ├── autoload/             # Singleton managers
│   ├── component/            # Reusable components
│   ├── game_object/          # Game entities (player, enemies)
│   ├── manager/              # Game system managers
│   ├── test/                 # Testing scenes and tools
│   └── ui/                   # User interface
├── scripts/                   # Standalone scripts
├── project.godot             # Godot project file
└── README.md                 # Project overview
```

### Key Directories

- **`scenes/component/`**: Reusable component implementations
- **`scenes/autoload/`**: Global singleton systems
- **`scenes/game_object/`**: Player, enemies, projectiles
- **`resources/upgrades/`**: Ability and upgrade definitions
- **`scenes/test/`**: Testing and debugging tools

## Resources

### Helpful Files

- **[README.md](../README.md)**: Project overview and setup
- **[.github/copilot-instructions.md](../.github/copilot-instructions.md)**: Complete coding standards
- **[DAMAGE_COMPONENT_INTEGRATION.md](../DAMAGE_COMPONENT_INTEGRATION.md)**: Component integration guide
- **[scenes/test/dps_benchmark/README.md](../scenes/test/dps_benchmark/README.md)**: Testing system documentation

### Learning Resources

- **[Godot Documentation](https://docs.godotengine.org/)**: Official Godot docs
- **[GDScript Reference](https://docs.godotengine.org/en/stable/tutorials/scripting/gdscript/gdscript_basics.html)**: GDScript language guide
- **[Component Pattern](https://gameprogrammingpatterns.com/component.html)**: Component architecture explanation

### Getting Help

1. **Issues**: Check existing [GitHub Issues](https://github.com/DatPriest/Project-Ares/issues) or create a new one
2. **Discussions**: Use GitHub Discussions for questions and ideas
3. **Code Review**: Submit PRs for code review and feedback

---

**Happy coding! 🚀**

*This guide is maintained by the Project Ares development team. Please keep it updated as the project evolves.*