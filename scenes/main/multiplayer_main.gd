extends Node

@export var end_screen_scene: PackedScene
@export var multiplayer_player_scene: PackedScene = preload("res://scenes/game_object/player/multiplayer_player.tscn")

var pause_menu_scene = preload("res://scenes/ui/pause_menu.tscn")
var crafting_menu_scene = preload("res://scenes/ui/crafting_menu/crafting_menu.tscn")
var floating_text_scene = preload("res://scenes/ui/floating_text.tscn")

@onready var entities_layer: Node = $%EntitiesLayer
@onready var foreground_layer: Node = $%ForegroundLayer
@onready var players_layer: Node = $%PlayersLayer

var players: Dictionary = {}
var local_player: Node = null

func _ready():
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
	
	# Connect multiplayer events
	multiplayer.peer_connected.connect(_on_peer_connected)
	multiplayer.peer_disconnected.connect(_on_peer_disconnected)
	multiplayer.connected_to_server.connect(_on_connected_to_server)
	multiplayer.connection_failed.connect(_on_connection_failed)
	multiplayer.server_disconnected.connect(_on_server_disconnected)
	
	# Spawn players
	if multiplayer.is_server():
		_spawn_all_players()
	else:
		# Client - request spawn from server
		_request_player_spawn.rpc_id(1)

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

# Multiplayer callbacks
func _on_peer_connected(peer_id: int):
	print("Peer connected: ", peer_id)
	if multiplayer.is_server():
		# Spawn player for new peer
		_spawn_player(peer_id)

func _on_peer_disconnected(peer_id: int):
	print("Peer disconnected: ", peer_id)
	_despawn_player(peer_id)

func _on_connected_to_server():
	print("Connected to server")

func _on_connection_failed():
	push_error("Connection to server failed")
	_return_to_lobby()

func _on_server_disconnected():
	print("Server disconnected")
	_return_to_lobby()

# Player management
func _spawn_all_players():
	if not multiplayer.is_server():
		return
	
	# Spawn host player
	_spawn_player(1)
	
	# Spawn players for all connected peers
	for peer_id in multiplayer.get_peers():
		_spawn_player(peer_id)

func _spawn_player(peer_id: int):
	if not multiplayer.is_server():
		return
		
	if players.has(peer_id):
		print("Player already exists for peer: ", peer_id)
		return
	
	var player_instance = multiplayer_player_scene.instantiate()
	player_instance.name = "Player_" + str(peer_id)
	player_instance.player_id = peer_id
	
	# Get player info from Steam if available
	if SteamMultiplayer and SteamMultiplayer.lobby_members.has(peer_id):
		var member_data = SteamMultiplayer.lobby_members[peer_id]
		player_instance.player_name = member_data.name
		player_instance.steam_id = member_data.steam_id
	else:
		player_instance.player_name = "Player " + str(peer_id)
		player_instance.steam_id = peer_id
	
	# Set spawn position (spread players out)
	var spawn_positions = [
		Vector2(0, 0), Vector2(50, 0), Vector2(-50, 0), Vector2(0, 50),
		Vector2(0, -50), Vector2(50, 50), Vector2(-50, -50), Vector2(50, -50),
		Vector2(-50, 50), Vector2(100, 0), Vector2(-100, 0), Vector2(0, 100),
		Vector2(0, -100), Vector2(100, 100), Vector2(-100, -100), Vector2(100, -100)
	]
	
	var spawn_index = (peer_id - 1) % spawn_positions.size()
	player_instance.global_position = spawn_positions[spawn_index]
	
	# Add to scene
	players_layer.add_child(player_instance, true)
	players[peer_id] = player_instance
	
	# Connect death signal
	player_instance.health_component.died.connect(_on_player_died.bind(peer_id))
	
	# Set local player reference
	if peer_id == multiplayer.get_unique_id():
		local_player = player_instance
	
	print("Spawned player: ", player_instance.player_name, " (", peer_id, ")")
	
	# Emit spawn event
	var player_data = {
		"peer_id": peer_id,
		"name": player_instance.player_name,
		"steam_id": player_instance.steam_id,
		"position": player_instance.global_position
	}
	GameEvents.emit_player_spawned(player_data)

func _despawn_player(peer_id: int):
	if players.has(peer_id):
		var player_instance = players[peer_id]
		print("Despawning player: ", player_instance.player_name)
		player_instance.queue_free()
		players.erase(peer_id)
		
		GameEvents.emit_player_despawned(peer_id)

@rpc("any_peer", "call_local", "reliable")
func _request_player_spawn():
	var peer_id = multiplayer.get_remote_sender_id()
	_spawn_player(peer_id)

func _on_player_died(peer_id: int):
	print("Player died: ", peer_id)
	# Could implement respawning logic here
	# For now, just show end screen for local player
	if peer_id == multiplayer.get_unique_id():
		var end_screen_instance = end_screen_scene.instantiate()
		add_child(end_screen_instance)
		end_screen_instance.set_defeat()
		MetaProgression.save()

func _return_to_lobby():
	# Return to main menu or lobby
	ScreenTransition.transition()
	await ScreenTransition.transitioned_halfway
	get_tree().change_scene_to_file("res://scenes/ui/main_menu/main_menu.tscn")

# Centralized spawning handlers (same as single-player)
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