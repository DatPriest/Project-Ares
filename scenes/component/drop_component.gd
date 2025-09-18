extends Node
@export_range(0, 1) var drop_percent: float = .5
@export var health_component: Node
@export var resources: Array[DropResource]
@export var material_scene: PackedScene

func _ready(): 
	(health_component as HealthComponent).died.connect(on_died)

func on_died():
	var resource: DropResource = resources.pick_random()
	if resource == null:
		return
	if randf() > resource.drop_chance:
		return

	if not owner is Node2D:
		return
	
	var spawn_position = (owner as Node2D).global_position
	
	# Use event system for resource drop spawning instead of direct layer access
	GameEvents.emit_resource_drop_requested(material_scene, spawn_position, resource)
