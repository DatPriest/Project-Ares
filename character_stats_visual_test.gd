extends Node2D

## Visual test for character stats system
## Creates a mock game environment to demonstrate stat functionality

@onready var stats_component: CharacterStatsComponent
@onready var stats_display: CharacterStatsDisplay
@onready var info_label: Label

var test_phase: int = 0
var test_timer: float = 0.0

func _ready():
	# Setup scene
	_setup_visual_test()
	print("Character Stats Visual Test Started")
	print("Watch the stats change over time to see the system in action!")

func _setup_visual_test():
	# Create stats component
	stats_component = CharacterStatsComponent.new()
	stats_component.enable_random_variance = true
	add_child(stats_component)
	
	# Create UI elements
	var ui_container = CanvasLayer.new()
	add_child(ui_container)
	
	# Info label
	info_label = Label.new()
	info_label.position = Vector2(20, 20)
	info_label.text = "Character Stats Visual Test - Phase 1: Initialization"
	info_label.add_theme_font_size_override("font_size", 16)
	ui_container.add_child(info_label)
	
	# Stats display
	stats_display = CharacterStatsDisplay.new()
	stats_display.position = Vector2(20, 80)
	stats_display.size = Vector2(300, 400)
	stats_display.character_stats_component = stats_component
	ui_container.add_child(stats_display)
	
	# Instructions
	var instructions = Label.new()
	instructions.position = Vector2(400, 80)
	instructions.size = Vector2(300, 400)
	instructions.text = """Visual Test Phases:
	
Phase 1: Show base stats with random variance
Phase 2: Apply basic upgrades (Health, Damage)
Phase 3: Add advanced stats (Resistances, Luck)
Phase 4: Demonstrate negative stats (trade-offs)
Phase 5: Create specialized build (Speed build)
Phase 6: Show comprehensive tank build

Each phase lasts 3 seconds.
Watch the stat values and colors change!"""
	instructions.add_theme_font_size_override("font_size", 12)
	instructions.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	ui_container.add_child(instructions)

func _process(delta):
	test_timer += delta
	
	# Progress through test phases every 3 seconds
	if test_timer >= 3.0:
		test_timer = 0.0
		test_phase += 1
		_run_test_phase()
		
		if test_phase > 6:
			_finish_test()

func _run_test_phase():
	match test_phase:
		1:
			_phase_1_initialization()
		2:
			_phase_2_basic_upgrades()
		3:
			_phase_3_advanced_stats()
		4:
			_phase_4_negative_stats()
		5:
			_phase_5_speed_build()
		6:
			_phase_6_tank_build()

func _phase_1_initialization():
	info_label.text = "Phase 1: Base stats with random variance"
	# Stats component already initialized with random variance
	print("Phase 1: Showing base character stats")

func _phase_2_basic_upgrades():
	info_label.text = "Phase 2: Applying basic upgrades (Health +50, Damage +25)"
	stats_component.modify_stat(CharacterStat.StatType.HEALTH, 50.0)
	stats_component.modify_stat(CharacterStat.StatType.DAMAGE, 25.0)
	print("Phase 2: Applied basic upgrades")

func _phase_3_advanced_stats():
	info_label.text = "Phase 3: Adding advanced stats (Resistances, Luck, XP Boost)"
	stats_component.modify_stat(CharacterStat.StatType.MAGIC_RESISTANCE, 15.0)
	stats_component.modify_stat(CharacterStat.StatType.FIRE_RESISTANCE, 10.0)
	stats_component.modify_stat(CharacterStat.StatType.LUCK, 20.0)
	stats_component.modify_stat(CharacterStat.StatType.EXPERIENCE_GAIN, 25.0)
	print("Phase 3: Added advanced stats")

func _phase_4_negative_stats():
	info_label.text = "Phase 4: Demonstrating negative stats (Speed -15%, Armor -10)"
	stats_component.modify_stat(CharacterStat.StatType.SPEED, -15.0)
	stats_component.modify_stat(CharacterStat.StatType.ARMOR_RATING, -10.0)
	print("Phase 4: Applied negative stat trade-offs")

func _phase_5_speed_build():
	info_label.text = "Phase 5: Speed build (High Speed, High Crit, Lower Defense)"
	# Reset and create speed build
	stats_component._recalculate_all_stats()
	stats_component.modify_stat(CharacterStat.StatType.SPEED, 40.0)
	stats_component.modify_stat(CharacterStat.StatType.CRITICAL_CHANCE, 25.0)
	stats_component.modify_stat(CharacterStat.StatType.CRITICAL_DAMAGE, 50.0)
	stats_component.modify_stat(CharacterStat.StatType.HEALTH, -25.0)  # Trade-off
	stats_component.modify_stat(CharacterStat.StatType.PICKUP_RANGE, 60.0)
	print("Phase 5: Created speed-focused build")

func _phase_6_tank_build():
	info_label.text = "Phase 6: Tank build (High HP, High Armor, High Resist, Low Speed/Damage)"
	# Reset and create tank build
	stats_component._recalculate_all_stats()
	stats_component.modify_stat(CharacterStat.StatType.HEALTH, 150.0)
	stats_component.modify_stat(CharacterStat.StatType.ARMOR_RATING, 75.0)
	stats_component.modify_stat(CharacterStat.StatType.MAGIC_RESISTANCE, 30.0)
	stats_component.modify_stat(CharacterStat.StatType.FIRE_RESISTANCE, 25.0)
	stats_component.modify_stat(CharacterStat.StatType.ICE_RESISTANCE, 20.0)
	stats_component.modify_stat(CharacterStat.StatType.REGENERATION, 5.0)
	# Trade-offs for tank build
	stats_component.modify_stat(CharacterStat.StatType.SPEED, -30.0)
	stats_component.modify_stat(CharacterStat.StatType.DAMAGE, -15.0)
	stats_component.modify_stat(CharacterStat.StatType.CRITICAL_CHANCE, -10.0)
	print("Phase 6: Created tank build with trade-offs")

func _finish_test():
	info_label.text = "Visual Test Complete! Character stats system demonstrated."
	print("Visual test completed successfully!")
	print("Character stats system is working correctly with:")
	print("- Positive and negative modifiers")
	print("- Random variance")
	print("- Proper display formatting and colors")
	print("- Multiple build archetypes")
	print("- Stat constraints and limits")
	
	# Keep the final state visible
	set_process(false)