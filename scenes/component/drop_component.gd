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
	
	var resource_instance = material_scene.instantiate() as Node2D
 	# Find the Sprite node (You can adjust the path if needed)
	var sprite_node = resource_instance.get_node("Sprite2D") as Sprite2D
	if sprite_node:
		sprite_node.texture = resource.sprite 
	var entities_layer = get_tree().get_first_node_in_group("entities_layer")
	resource_instance.drop_resource = resource
	
	entities_layer.add_child(resource_instance)
	resource_instance.global_position = spawn_position
