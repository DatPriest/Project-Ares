extends Node2D

@export var health_component: Node
@export var sprite: Sprite2D
@onready var hit_random_audio_player_component = $HitRandomAudioPlayerComponent

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
		# Fallback to the original method if entities layer not available
		var entities = get_tree().get_first_node_in_group("entities_layer")
		entities.add_child(self)
	
	global_position = spawn_position
	$AnimationPlayer.play("default")
	hit_random_audio_player_component.play_random()
