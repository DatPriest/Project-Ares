extends Node

@export var end_screen_scene: PackedScene

var pause_menu_scene = preload("res://scenes/ui/pause_menu.tscn")
var crafting_menu_scene = preload("res://scenes/ui/crafting_menu/crafting_menu.tscn")
var floating_text_scene = preload("res://scenes/ui/floating_text.tscn")

@onready var entities_layer: Node = $%EntitiesLayer
@onready var foreground_layer: Node = $%ForegroundLayer

func _ready():
	$%Player.health_component.died.connect(on_player_died)
	
	# Register layer references with GameEvents
	GameEvents.emit_entities_layer_ready(entities_layer)
	GameEvents.emit_foreground_layer_ready(foreground_layer)
	
	# Connect spawning events
	GameEvents.entity_spawn_requested.connect(on_entity_spawn_requested)
	GameEvents.projectile_spawn_requested.connect(on_projectile_spawn_requested)
	GameEvents.resource_drop_requested.connect(on_resource_drop_requested)
	GameEvents.floating_text_requested.connect(on_floating_text_requested)
	GameEvents.effect_spawn_requested.connect(on_effect_spawn_requested)
	GameEvents.ability_spawn_requested.connect(on_ability_spawn_requested)
	
	
func _unhandled_input(event):
	handle_inventory(event)
	handle_escape(event)


func handle_inventory(event):
	if event.is_action_pressed("inventory"):
		add_child(crafting_menu_scene.instantiate())
		get_tree().root.set_input_as_handled()
		
func handle_escape(event):
	if event.is_action_pressed("Escape"):
		add_child(pause_menu_scene.instantiate())
		get_tree().root.set_input_as_handled()
	
func on_player_died():
	var end_screen_instance = end_screen_scene.instantiate()
	add_child(end_screen_instance)
	end_screen_instance.set_defeat()
	MetaProgression.save()

# Centralized spawning handlers
func on_entity_spawn_requested(entity_scene: PackedScene, spawn_position: Vector2):
	if entity_scene == null or entities_layer == null:
		return
	var entity_instance = entity_scene.instantiate()
	entities_layer.add_child(entity_instance)
	entity_instance.global_position = spawn_position

func on_projectile_spawn_requested(projectile_scene: PackedScene, spawn_position: Vector2, velocity: Vector2):
	if projectile_scene == null or entities_layer == null:
		return
	var projectile_instance = projectile_scene.instantiate()
	entities_layer.add_child(projectile_instance)
	projectile_instance.global_position = spawn_position
	if projectile_instance.has_method("set_velocity"):
		projectile_instance.set_velocity(velocity)
	elif "velocity" in projectile_instance:
		projectile_instance.velocity = velocity

func on_resource_drop_requested(material_scene: PackedScene, spawn_position: Vector2, resource: DropResource):
	if material_scene == null or entities_layer == null:
		return
	var resource_instance = material_scene.instantiate()
	# Configure the resource
	var sprite_node = resource_instance.get_node("Sprite2D") as Sprite2D
	if sprite_node:
		sprite_node.texture = resource.sprite 
	resource_instance.drop_resource = resource
	entities_layer.add_child(resource_instance)
	resource_instance.global_position = spawn_position

func on_floating_text_requested(text: String, position: Vector2):
	if floating_text_scene == null or foreground_layer == null:
		return
	var floating_text_instance = floating_text_scene.instantiate()
	foreground_layer.add_child(floating_text_instance)
	floating_text_instance.global_position = position
	floating_text_instance.start(text)

func on_effect_spawn_requested(effect_scene: PackedScene, position: Vector2):
	if effect_scene == null or foreground_layer == null:
		return
	var effect_instance = effect_scene.instantiate()
	foreground_layer.add_child(effect_instance)
	effect_instance.global_position = position

func on_ability_spawn_requested(ability_scene: PackedScene, position: Vector2, damage: float, rotation_angle: float):
	if ability_scene == null or foreground_layer == null:
		return
	var ability_instance = ability_scene.instantiate()
	# Set damage if the ability has a hitbox component
	if ability_instance.has_method("get") and ability_instance.get("hitbox_component"):
		ability_instance.hitbox_component.damage = damage
	ability_instance.rotation = rotation_angle
	foreground_layer.add_child(ability_instance)
	ability_instance.global_position = position
