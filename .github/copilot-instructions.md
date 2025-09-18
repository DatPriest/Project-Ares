# Project: Ares - Godot Game Development

Project: Ares is a 2D survival/roguelike game built with Godot 4.2.1 and C#. The game features player progression, enemy management, experience collection, ability upgrades, and resource drops in a top-down survival format.

**ALWAYS reference these instructions first and fallback to search or bash commands only when you encounter unexpected information that does not match the info here.**

## Working Effectively

### Initial Setup and Build Process

Bootstrap the development environment in this exact order:

1. **Install Godot 4.2.1:**
   ```bash
   cd /tmp
   wget https://github.com/godotengine/godot/releases/download/4.2.1-stable/Godot_v4.2.1-stable_linux.x86_64.zip
   unzip Godot_v4.2.1-stable_linux.x86_64.zip
   sudo mv Godot_v4.2.1-stable_linux.x86_64 /usr/local/bin/godot
   sudo chmod +x /usr/local/bin/godot
   ```

2. **Install .NET SDK (8.0 or compatible):**
   ```bash
   sudo apt update
   sudo apt install -y dotnet-sdk-8.0
   ```

3. **Build the C# project:**
   ```bash
   dotnet build
   ```
   - **TIMING:** Takes 4-6 seconds. Use timeout of 60+ seconds to be safe.
   - The project uses Godot.NET.Sdk/4.2.1 and targets .NET 6.0

4. **Import all game assets (CRITICAL STEP):**
   ```bash
   godot --headless --import --quit --audio-driver Dummy
   ```
   - **TIMING:** Takes 15-30 seconds for full import. NEVER CANCEL before completion.
   - **CRITICAL:** Assets MUST be imported before project can run properly
   - This step imports textures, audio files, fonts, and other resources
   - **NOTE:** The import process may show errors but will still import many assets
   - You can verify partial import worked if the process completes without hanging

### Running the Game

**Local Development:**
```bash
# Run in headless mode for testing
godot --headless --audio-driver Dummy res://scenes/ui/main_menu/main_menu.tscn

# For debugging with minimal display (if supported)
godot res://scenes/ui/main_menu/main_menu.tscn
```

**Export Templates (for building executables):**
```bash
cd /tmp
wget https://github.com/godotengine/godot/releases/download/4.2.1-stable/Godot_v4.2.1-stable_export_templates.tpz
unzip Godot_v4.2.1-stable_export_templates.tpz
mkdir -p ~/.local/share/godot/export_templates/4.2.1.stable
cp -r templates/* ~/.local/share/godot/export_templates/4.2.1.stable/
```

## Project Structure

### Key Directories and Files

```
Project-Ares/
├── project.godot                 # Main Godot project file
├── 2d Surviors Course.csproj     # C# project configuration
├── 2d Surviors Course.sln       # Visual Studio solution
├── export_presets.cfg           # Export configurations (Windows Desktop)
├── scenes/                      # All game scenes
│   ├── main/main.tscn          # Main game scene
│   ├── ui/main_menu/           # Main menu and UI
│   ├── autoload/               # Global singletons
│   ├── manager/                # Game system managers
│   └── component/              # Reusable components
├── assets/                     # Game assets (textures, audio)
│   ├── ui/                    # UI textures and sprites
│   ├── audio/                 # Sound effects and music
│   └── environment/           # Environment textures
├── resources/                  # Game data resources
│   ├── upgrades/              # Ability upgrade definitions
│   ├── drop_resources/        # Item drop definitions
│   ├── meta_upgrades/         # Meta progression upgrades
│   └── theme/                 # UI theme resources
└── scripts/                   # Standalone script files
```

### Critical Game Systems

**Autoloads (Global Singletons):**
- `GameEvents` - Central event system for game communication
- `MusicPlayer` - Background music management
- `ScreenTransition` - Screen transition effects
- `MetaProgression` - Persistent progression system

**Core Game Managers:**
- `ExperienceManager` - Handles XP collection and leveling
- `UpgradeManager` - Manages ability upgrades and selection
- `EnemyManager` - Spawns and manages enemies
- `ResourceManager` - Handles resource collection and inventory
- `ArenaTimeManager` - Game timer and wave management

## Validation and Testing

### Manual Validation Steps

**ALWAYS perform these validation steps after making changes:**

1. **Build Validation:**
   ```bash
   dotnet build
   ```
   - Must complete without errors
   - Warnings are acceptable but note them

2. **Asset Import Verification:**
   ```bash
   godot --headless --import --quit --audio-driver Dummy
   ```
   - NEVER CANCEL: Takes 15-30 seconds, set timeout to 120+ seconds
   - All assets must import without fatal errors

3. **Basic Functionality Test:**
   ```bash
   timeout 10 godot --headless --audio-driver Dummy res://scenes/ui/main_menu/main_menu.tscn
   ```
   - Should start and run for several seconds
   - Will show asset loading errors but should not crash immediately
   - Game systems initialization can be tested even with missing assets

4. **Key Script Dependencies Check:**
   - Ensure `AbilityUpgrade` class is available to `GameEvents`
   - Ensure `DropResource` class is available to `GameEvents`
   - Check autoload scripts can find their dependencies

### Critical Validation Scenarios

**After modifying game systems:**
1. Test the main menu loads without errors
2. Verify autoload systems initialize correctly
3. Check that upgrade system can access ability definitions
4. Ensure resource/drop system can access drop resource definitions

**After modifying UI/scenes:**
1. Ensure scenes can load their required assets
2. Test that UI theme resources are accessible
3. Verify button interactions and scene transitions work

**After modifying C# code:**
1. Run `dotnet build` to check compilation
2. Test that GDScript can access C# class types
3. Verify autoload scripts can initialize properly

## Build and Export Information

### Build Timing Expectations
- **C# Build:** 4-6 seconds (NEVER CANCEL - set timeout 60+ seconds)
- **Asset Import:** 15-30 seconds (NEVER CANCEL - set timeout 120+ seconds)  
- **Project Validation:** 5-10 seconds

### Known Project Limitations

**Asset Import Issues:**
- The project has asset import challenges in headless mode
- Some textures, fonts, and audio files may not import correctly via command line
- The project requires the full Godot editor to properly import all assets
- This means builds and testing have limitations in automated environments

**Export Configuration:**
The project is currently configured for **Windows Desktop** export only.

**Other Known Limitations:**
- Windows export requires export templates to be installed
- No Linux/Web export presets are configured
- rcedit tool needed for Windows icon/metadata changes
- Full asset functionality requires Godot editor GUI (not headless mode)

### Common Issues and Solutions

**"Could not find type 'AbilityUpgrade'" Error:**
- Ensure `resources/upgrades/ability_upgrade.gd` exists and defines the class
- Run `dotnet build` to ensure C# compilation is current
- Check that the script uses `class_name AbilityUpgrade`

**"Could not find type 'DropResource'" Error:**
- Ensure `resources/drop_resources/drop_resource.gd` exists and defines the class  
- Check that the script uses `class_name DropResource`

**Asset Import Errors:**
- Always run the full asset import process: `godot --headless --import --quit --audio-driver Dummy`
- NEVER CANCEL the import process even if it seems slow
- Some errors during import are normal, but the process must complete

**Build Failures:**
- Ensure .NET SDK 8.0 is installed
- Run `dotnet restore` if build fails with missing dependencies
- Check that Godot 4.2.1 is properly installed

## Development Workflow

### Making Changes

1. **Always build and test first** to establish baseline
2. Make minimal, focused changes
3. **Immediately test** after each change:
   ```bash
   dotnet build && godot --headless --import --quit --audio-driver Dummy
   ```
4. Run validation scenarios relevant to your changes
5. Test game initialization to ensure autoloads work

### File Modification Guidelines

**When modifying GDScript files:**
- Pay attention to `class_name` declarations  
- Ensure exported variables maintain their types
- Test that dependent scripts can still access classes

**When modifying scene files:**
- Verify all external resource references are valid
- Test that autoload references work correctly
- Ensure UI themes and assets load properly

**When modifying C# project:**
- Always run `dotnet build` after changes
- Check that GDScript can access any new C# types
- Verify export configurations are still valid

### Key Files to Monitor

Always check these files when making systemic changes:
- `scenes/autoload/game_events.gd` - Central event system
- `project.godot` - Project configuration and autoloads
- `resources/upgrades/ability_upgrade.gd` - Ability system base class
- `resources/drop_resources/drop_resource.gd` - Resource drop base class

## Quick Reference Commands

```bash
# Complete setup from fresh clone
dotnet build && godot --headless --import --quit --audio-driver Dummy

# Validate after changes  
dotnet build && timeout 10 godot --headless --audio-driver Dummy res://scenes/ui/main_menu/main_menu.tscn

# Force reimport all assets
rm -rf .godot/imported && godot --headless --import --quit --audio-driver Dummy

# Check project structure
find scenes -name "*.tscn" | grep -E "(main|menu|manager)" | head -10
```

**REMEMBER:** This is a Godot 4.2.1 project with C# support. Always import assets before testing, and never cancel long-running import operations. The game's architecture relies heavily on autoload systems and proper class name definitions.