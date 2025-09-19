extends Node

@export var end_screen_scene: PackedScene

var pause_menu_scene = preload("res://scenes/ui/pause_menu.tscn")
var crafting_menu_scene = preload("res://scenes/ui/crafting_menu/crafting_menu.tscn")
var floating_text_scene = preload("res://scenes/ui/floating_text.tscn")

@onready var entities_layer: Node = $%EntitiesLayer
@onready var foreground_layer: Node = $%ForegroundLayer

# Enemy tracking optimization
var enemy_tracking_timer: Timer
var cached_enemies: Array[Node2D] = []
var cached_player_position: Vector2 = Vector2.ZERO
const ENEMY_UPDATE_INTERVAL: float = 0.1  # Update every 100ms instead of every frame

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
	
	# Set up enemy tracking optimization
	_setup_enemy_tracking()
	
	# Connect to player position updates
	GameEvents.player_position_updated.connect(on_player_position_updated)

func _setup_enemy_tracking():
	"""Initialize performance-optimized enemy tracking system"""
	enemy_tracking_timer = Timer.new()
	enemy_tracking_timer.wait_time = ENEMY_UPDATE_INTERVAL
	enemy_tracking_timer.timeout.connect(_update_enemy_cache)
	enemy_tracking_timer.autostart = true
	add_child(enemy_tracking_timer)

func on_player_position_updated(player_position: Vector2):
	cached_player_position = player_position

func _update_enemy_cache():
	"""Update cached enemy list at reduced frequency to improve performance"""
	cached_enemies = get_tree().get_nodes_in_group("enemy")
	# Filter out invalid nodes
	cached_enemies = cached_enemies.filter(func(enemy): return is_instance_valid(enemy) and enemy is Node2D)
	# Broadcast the updated enemy list
	GameEvents.emit_enemies_near_player_updated(cached_enemies, cached_player_position)
	
	
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
	var hitbox_component = ability_instance.get("hitbox_component")
	if hitbox_component:
		hitbox_component.damage = damage
	ability_instance.rotation = rotation_angle
	foreground_layer.add_child(ability_instance)
	ability_instance.global_position = position
