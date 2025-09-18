extends Node

# Projectile pool sizes - configurable for performance tuning
const ARROW_POOL_SIZE: int = 50
const DEBUG_STATS_INTERVAL: float = 30.0  # Print stats every 30 seconds

# Pool containers
var arrow_pool: Array[Arrow] = []
var active_arrows: Array[Arrow] = []

# Preloaded scenes
var arrow_scene: PackedScene = preload("res://scenes/game_object/projectiles/arrow.tscn")

# Performance tracking
var total_arrows_created: int = 0
var total_arrows_reused: int = 0

# Debug timer
var debug_timer: Timer

func _ready() -> void:
	# Pre-populate arrow pool
	for i in ARROW_POOL_SIZE:
		var arrow: Arrow = arrow_scene.instantiate()
		arrow.set_process(false)
		arrow.set_physics_process(false)
		arrow.visible = false
		arrow_pool.append(arrow)
		total_arrows_created += 1
	
	print("ProjectilePool initialized with %d arrows" % ARROW_POOL_SIZE)
	
	# Setup debug timer
	debug_timer = Timer.new()
	debug_timer.wait_time = DEBUG_STATS_INTERVAL
	debug_timer.timeout.connect(_on_debug_timer_timeout)
	debug_timer.autostart = true
	add_child(debug_timer)

func _on_debug_timer_timeout() -> void:
	print_pool_stats()

func get_arrow() -> Arrow:
	var arrow: Arrow
	
	if arrow_pool.size() > 0:
		# Reuse from pool
		arrow = arrow_pool.pop_back()
		total_arrows_reused += 1
	else:
		# Pool exhausted, create new one (this should rarely happen with proper sizing)
		arrow = arrow_scene.instantiate()
		total_arrows_created += 1
		print("Warning: Arrow pool exhausted, creating new arrow (total created: %d)" % total_arrows_created)
	
	# Reset and activate arrow
	arrow.reset_arrow()
	arrow.set_process(true)
	arrow.set_physics_process(true)
	arrow.visible = true
	active_arrows.append(arrow)
	
	return arrow

func return_arrow(arrow: Arrow) -> void:
	if arrow == null:
		return
		
	# Remove from active list
	var index: int = active_arrows.find(arrow)
	if index != -1:
		active_arrows.remove_at(index)
	
	# Deactivate arrow
	arrow.set_process(false)
	arrow.set_physics_process(false)
	arrow.visible = false
	
	# Remove from scene tree if it's in one
	if arrow.get_parent() != null:
		arrow.get_parent().remove_child(arrow)
	
	# Return to pool
	arrow_pool.append(arrow)

func get_pool_stats() -> Dictionary:
	return {
		"arrow_pool_available": arrow_pool.size(),
		"arrow_pool_active": active_arrows.size(),
		"arrow_pool_total": arrow_pool.size() + active_arrows.size(),
		"total_arrows_created": total_arrows_created,
		"total_arrows_reused": total_arrows_reused,
		"reuse_ratio": float(total_arrows_reused) / max(1, total_arrows_created + total_arrows_reused)
	}

func print_pool_stats() -> void:
	var stats: Dictionary = get_pool_stats()
	print("Pool Stats - Available: %d, Active: %d, Created: %d, Reused: %d, Reuse Ratio: %.2f" % [
		stats.arrow_pool_available,
		stats.arrow_pool_active,
		stats.total_arrows_created,
		stats.total_arrows_reused,
		stats.reuse_ratio
	])

func _exit_tree() -> void:
	print_pool_stats()
	# Clean up debug timer
	if debug_timer:
		debug_timer.queue_free()
	# Clean up all arrows
	for arrow in arrow_pool:
		if is_instance_valid(arrow):
			arrow.queue_free()
	for arrow in active_arrows:
		if is_instance_valid(arrow):
			arrow.queue_free()
	arrow_pool.clear()
	active_arrows.clear()