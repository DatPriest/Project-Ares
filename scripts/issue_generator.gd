extends RefCounted
class_name IssueGenerator

# This script contains the structured data for generating GitHub issues
# Based on comprehensive code analysis of Project Ares

static func get_issues_data() -> Array[Dictionary]:
	var issues = []
	
	# Issue 1: Code Duplication
	issues.append({
		"title": "Refactor Enemy Movement Logic to Reduce Code Duplication",
		"labels": ["refactoring", "code-quality", "maintenance"],
		"body": """**Was?**
The movement logic with visual scaling is duplicated across multiple enemy classes (basic_enemy.gd, goblin_enemy.gd, and partially in base_enemy.gd).

**Warum?**  
- Violates DRY (Don't Repeat Yourself) principle
- Makes maintenance harder when movement logic needs to change
- Increases risk of bugs when updating one class but not others

**Aufgaben / Akzeptanzkriterien:**
- [ ] Move common movement logic to BaseEnemy class
- [ ] Create unified handle_movement_visuals() method
- [ ] Update all enemy subclasses to call parent methods
- [ ] Ensure wizard_enemy.gd extends BaseEnemy for consistency
- [ ] Test that all enemies still move and animate correctly

**Code-Beispiele:**
```gdscript
# In BaseEnemy.gd - proposed solution
func handle_movement_visuals():
    var move_sign = sign(velocity.x)
    if move_sign != 0:
        visuals.scale = Vector2(-move_sign, 1)
```"""
	})
	
	# Issue 2: Magic Numbers
	issues.append({
		"title": "Replace Magic Numbers with Named Constants",
		"labels": ["refactoring", "code-quality", "maintainability"],
		"body": """**Was?**
Multiple files contain magic numbers: MAX_RANGE = 150, SPAWN_RADIUS = 380, hardcoded percentages in upgrades.

**Warum?**
- Reduces code readability and maintainability
- Makes gameplay balancing difficult
- Violates clean code principles

**Aufgaben / Akzeptanzkriterien:**
- [ ] Create GameConstants.gd autoload script
- [ ] Move all magic numbers to named constants
- [ ] Group constants logically (COMBAT, SPAWNING, UI, etc.)
- [ ] Update all references to use constants
- [ ] Add documentation for each constant

**Code-Beispiele:**
```gdscript
# GameConstants.gd
const SWORD_MAX_RANGE = 150
const ENEMY_SPAWN_RADIUS = 380
const UPGRADE_DAMAGE_PERCENT = 0.1
```"""
	})
	
	# Issue 3: Signal Connection Bug
	issues.append({
		"title": "Fix Missing Signal Connection for Enemy Kill Experience",
		"labels": ["bug", "gameplay", "signals"],
		"body": """**Was?**
The experience_manager.gd defines on_kill() method but GameEvents.enemy_killed signal is never connected. Players don't gain XP from killing enemies.

**Warum?**
- Breaks expected gameplay progression
- Reduces player engagement
- Creates unused dead code

**Aufgaben / Akzeptanzkriterien:**
- [ ] Connect GameEvents.enemy_killed signal to on_kill method
- [ ] Ensure enemies emit signal when killed  
- [ ] Test XP gain from enemy kills
- [ ] Verify experience bar updates correctly
- [ ] Maintain existing vial functionality

**Code-Beispiele:**
```gdscript
# In experience_manager.gd _ready():
GameEvents.enemy_killed.connect(on_kill)
```"""
	})
	
	# Issue 4: WeightedTable Bug
	issues.append({
		"title": "Fix WeightedTable Crash When No Items Available",
		"labels": ["bug", "performance", "error-handling"],
		"body": """**Was?**
WeightedTable.pick_item() can crash when adjusted_weight_sum becomes 0, causing invalid randi_range(1, 0).

**Warum?**
- Can cause runtime crashes
- Poor error handling for edge cases
- Could break upgrade selection system

**Aufgaben / Akzeptanzkriterien:**
- [ ] Add null/empty checks in pick_item()
- [ ] Return null when no items available
- [ ] Add error logging for debugging
- [ ] Update callers to handle null returns
- [ ] Add unit tests for edge cases

**Code-Beispiele:**
```gdscript
func pick_item(exclude: Array = []):
    if adjusted_weight_sum <= 0 or adjusted_items.is_empty():
        return null
    # ... rest of method
```"""
	})
	
	# Issue 5: Wizard Enemy Hierarchy
	issues.append({
		"title": "Fix Wizard Enemy Class Hierarchy Inconsistency", 
		"labels": ["bug", "refactoring", "architecture"],
		"body": """**Was?**
wizard_enemy.gd extends CharacterBody2D instead of BaseEnemy, breaking established inheritance pattern.

**Warum?**
- Duplicates health, hurt box, and audio logic
- Makes universal enemy changes harder
- Reduces code consistency

**Aufgaben / Akzeptanzkriterien:**
- [ ] Change wizard_enemy.gd to extend BaseEnemy
- [ ] Remove duplicated component references
- [ ] Test all wizard-specific behavior
- [ ] Verify movement, health, hit detection work
- [ ] Update any wizard-specific references"""
	})
	
	# Issue 6: New Ability Feature
	issues.append({
		"title": "Feature: Add Poison Cloud Ability with Area Damage",
		"labels": ["feature", "gameplay", "abilities"],
		"body": """**Was?**
Add poison cloud ability to introduce area denial and damage-over-time mechanics.

**Warum?**
- Increases gameplay depth and strategy
- Provides crowd control options  
- Adds visual variety to combat
- Creates synergy opportunities

**Aufgaben / Akzeptanzkriterien:**
- [ ] Create poison_cloud_ability.gd and .tscn
- [ ] Create poison_cloud_ability_controller.gd
- [ ] Add poison status effect system
- [ ] Implement area damage over time
- [ ] Add visual effects (particles)
- [ ] Create upgrade resources
- [ ] Add to upgrade pool
- [ ] Add sound effects"""
	})
	
	# Issue 7: Ranged Enemy Feature  
	issues.append({
		"title": "Feature: Add Archer Enemy with Ranged Attacks",
		"labels": ["feature", "gameplay", "enemies"],
		"body": """**Was?**
Add ranged enemy to create more tactical gameplay requiring positioning and dodging.

**Warum?**
- Increases combat variety and challenge
- Forces strategic movement
- Adds mechanical diversity
- Creates upgrade synergy opportunities

**Aufgaben / Akzeptanzkriterien:**
- [ ] Create archer_enemy.gd extending BaseEnemy
- [ ] Implement projectile system
- [ ] Add aiming logic toward player
- [ ] Create shooting cooldown mechanics
- [ ] Add attack telegraphing visuals
- [ ] Add to enemy spawning table
- [ ] Balance damage, range, fire rate"""
	})
	
	# Issue 8: Audio Feedback
	issues.append({
		"title": "Add Audio Feedback for Ability Activation",
		"labels": ["ui", "audio", "player-feedback"],
		"body": """**Was?**
Abilities lack audio feedback, making combat feel less impactful.

**Warum?**
- Reduces player engagement
- Poor accessibility
- Misses game feel opportunities

**Aufgaben / Akzeptanzkriterien:**
- [ ] Add audio components to ability controllers
- [ ] Create distinct sounds for each ability
- [ ] Add cooldown ready notifications
- [ ] Implement audio pooling for performance
- [ ] Add volume controls in options
- [ ] Test audio balance with music"""
	})
	
	# Issue 9: Tooltip System
	issues.append({
		"title": "Implement Tooltip System for Abilities and Upgrades", 
		"labels": ["ui", "accessibility", "new-player-experience"],
		"body": """**Was?**
Game lacks tooltips and help text for abilities and upgrades.

**Warum?**
- Improves new player onboarding
- Better accessibility and UX
- Allows more complex mechanics

**Aufgaben / Akzeptanzkriterien:**
- [ ] Create tooltip UI component
- [ ] Add hover detection for upgrade cards
- [ ] Include damage numbers and cooldowns
- [ ] Add keyboard accessibility support
- [ ] Create help screen with controls
- [ ] Test on different resolutions"""
	})
	
	# Issue 10: Performance Optimization
	issues.append({
		"title": "Optimize Enemy Targeting Performance in Ability Controllers",
		"labels": ["performance", "optimization"],
		"body": """**Was?**
Sword ability controller calls distance_squared_to() for every enemy on timeout, inefficient with many enemies.

**Warum?**
- Can cause frame drops with large enemy counts
- Poor algorithm complexity
- Reduces scalability

**Aufgaben / Akzeptanzkriterien:**
- [ ] Implement spatial partitioning or caching
- [ ] Cache enemy positions between updates  
- [ ] Add early rejection based on rough distance
- [ ] Profile performance improvements
- [ ] Test with 100+ enemies
- [ ] Apply to other ability controllers

**Code-Beispiele:**
```gdscript
# Proposed optimization:
var cached_nearby_enemies: Array = []
var cache_timer = 0.0
const CACHE_INTERVAL = 0.1
```"""
	})
	
	return issues

# Helper function to format issue for GitHub API
static func format_issue_for_github(issue_data: Dictionary) -> String:
	var formatted = "## " + issue_data.title + "\n\n"
	formatted += "**Labels:** " + ", ".join(issue_data.labels) + "\n\n"
	formatted += issue_data.body + "\n\n"
	return formatted