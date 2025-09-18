extends Node
class_name BossNetworkSyncComponent

# This component handles network synchronization for boss enemies
# It ensures boss states are properly synchronized across multiplayer clients

@export var boss_data: EnemyData
@export var sync_interval: float = 0.1  # Sync every 0.1 seconds

var boss_node: Node2D
var last_sync_time: float = 0.0

# Synchronized boss state
var synced_position: Vector2
var synced_health: float
var synced_phase_index: int = 0
var synced_is_attacking: bool = false

func _ready():
	boss_node = owner as Node2D
	if boss_node == null:
		push_error("BossNetworkSyncComponent: Owner must be a Node2D")
		return
	
	# Only enable network sync if this is a boss and multiplayer is active
	if boss_data == null or not boss_data.is_boss:
		set_process(false)
		return
	
	if not multiplayer.has_multiplayer_peer():
		set_process(false)
		return
	
	# Initialize synced values
	synced_position = boss_node.global_position
	
	# Get health component for health sync
	var health_component = boss_node.get_node_or_null("HealthComponent") as HealthComponent
	if health_component != null:
		synced_health = health_component.current_health
		health_component.health_changed.connect(_on_health_changed)

func _process(delta: float):
	if not multiplayer.has_multiplayer_peer():
		return
	
	last_sync_time += delta
	
	# Only the authority (host) sends sync data
	if multiplayer.is_server() and last_sync_time >= sync_interval:
		_sync_boss_state_to_clients()
		last_sync_time = 0.0

@rpc("unreliable", "call_remote", "reliable")
func sync_boss_state(position: Vector2, health: float, phase_index: int, is_attacking: bool):
	# Called on clients to update boss state
	if multiplayer.is_server():
		return  # Server doesn't need to receive its own sync
	
	synced_position = position
	synced_health = health
	synced_phase_index = phase_index
	synced_is_attacking = is_attacking
	
	# Apply synced state to boss
	_apply_synced_state()

func _sync_boss_state_to_clients():
	if boss_node == null:
		return
	
	# Get current boss state
	var current_position = boss_node.global_position
	var current_health = _get_current_health()
	var current_phase = _get_current_phase_index()
	var current_attacking = _is_currently_attacking()
	
	# Send to all clients
	sync_boss_state.rpc(current_position, current_health, current_phase, current_attacking)

func _apply_synced_state():
	if boss_node == null:
		return
	
	# Smooth position interpolation to avoid jittery movement
	boss_node.global_position = boss_node.global_position.lerp(synced_position, 0.3)
	
	# Update health if changed significantly
	var health_component = boss_node.get_node_or_null("HealthComponent") as HealthComponent
	if health_component != null:
		var health_diff = abs(health_component.current_health - synced_health)
		if health_diff > 1.0:  # Only sync if difference is significant
			health_component.current_health = synced_health
			health_component.health_changed.emit()

func _get_current_health() -> float:
	var health_component = boss_node.get_node_or_null("HealthComponent") as HealthComponent
	if health_component != null:
		return health_component.current_health
	return 0.0

func _get_current_phase_index() -> int:
	# Get phase index from GenericEnemy if it's a boss
	if boss_node.has_method("get_current_phase_index"):
		return boss_node.get_current_phase_index()
	return 0

func _is_currently_attacking() -> bool:
	# Check if boss is currently executing a special attack
	if boss_node.has_method("is_attacking"):
		return boss_node.is_attacking()
	return false

func _on_health_changed():
	# Immediately sync health changes (reliable RPC)
	if multiplayer.is_server() and boss_node != null:
		var current_health = _get_current_health()
		sync_boss_health.rpc(current_health)

@rpc("reliable", "call_remote")
func sync_boss_health(health: float):
	if multiplayer.is_server():
		return
	
	synced_health = health
	var health_component = boss_node.get_node_or_null("HealthComponent") as HealthComponent
	if health_component != null:
		health_component.current_health = health
		health_component.health_changed.emit()

# RPC for phase changes (reliable and immediate)
@rpc("reliable", "call_remote") 
func sync_phase_change(new_phase_index: int):
	if multiplayer.is_server():
		return
	
	synced_phase_index = new_phase_index
	
	# Trigger phase change on client-side boss
	if boss_node.has_method("set_current_phase_index"):
		boss_node.set_current_phase_index(new_phase_index)

# Call this from GenericEnemy when boss phase changes
func notify_phase_change(new_phase_index: int):
	if multiplayer.is_server():
		sync_phase_change.rpc(new_phase_index)

# RPC for special attacks (reliable and immediate)
@rpc("reliable", "call_remote")
func sync_special_attack(attack_name: String, position: Vector2):
	if multiplayer.is_server():
		return
	
	# Trigger special attack on client
	if boss_node.has_method("execute_special_attack_client"):
		boss_node.execute_special_attack_client(attack_name, position)

# Call this from GenericEnemy when boss uses special attack
func notify_special_attack(attack_name: String, position: Vector2):
	if multiplayer.is_server():
		sync_special_attack.rpc(attack_name, position)