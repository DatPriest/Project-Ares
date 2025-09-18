extends Node

@export_range(0, 1) var drop_percent: float = .5
@export var health_component: Node
@export var vial_scene: PackedScene

func _ready(): 
	(health_component as HealthComponent).died.connect(on_died)

func on_died():
	var adjusted_drop_percent = drop_percent
	var experience_gain_upgrade_count = MetaProgression.get_upgrade_count("experience_gain")
	if experience_gain_upgrade_count > 0:
		adjusted_drop_percent += .1
	if randf() > adjusted_drop_percent:
		return
	if vial_scene == null:
		return
	
	if not owner is Node2D:
		return
		
	var spawn_position = (owner as Node2D).global_position
	# Use event system for entity spawning instead of direct layer access
	GameEvents.emit_entity_spawn_requested(vial_scene, spawn_position)
