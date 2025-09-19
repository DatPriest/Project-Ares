extends Node2D

@export var health_component: Node
@export var sprite: Sprite2D
@export var death_sounds: Array[AudioStream] = []

var entities_layer: Node = null

func _ready():
	$GPUParticles2D.texture = sprite.texture
	health_component.died.connect(on_died)
	GameEvents.entities_layer_ready.connect(on_entities_layer_ready)

func on_entities_layer_ready(layer: Node):
	entities_layer = layer
	
func on_died():
	if owner == null || not owner is Node2D:
		return
		
	var spawn_position = owner.global_position
	get_parent().remove_child(self)
	
	# Use cached entities layer reference instead of direct tree access
	if entities_layer != null:
		entities_layer.add_child(self)
	else:
		push_warning("entities_layer not initialized. Death component could not be reparented.")
	global_position = spawn_position
	$AnimationPlayer.play("default")
	if death_sounds.size() > 0:
		AudioManager.play_sfx_random(death_sounds, global_position)
