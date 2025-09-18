extends Area2D
class_name Arrow

@export var speed: float = 300.0
@export var damage: int = 10
@export var max_range: float = 400.0

var velocity: Vector2 = Vector2.ZERO
var start_position: Vector2
var traveled_distance: float = 0.0

@onready var sprite_2d: Sprite2D = $Sprite2D

func _ready() -> void:
	# Connect screen exit signal for automatic cleanup
	if has_node("VisibilityNotifier2D"):
		var visibility_notifier: VisibilityNotifier2D = $VisibilityNotifier2D
		if not visibility_notifier.screen_exited.is_connected(_on_screen_exited):
			visibility_notifier.screen_exited.connect(_on_screen_exited)

func reset_arrow() -> void:
	"""Reset arrow state for reuse from pool"""
	velocity = Vector2.ZERO
	start_position = Vector2.ZERO
	traveled_distance = 0.0
	rotation = 0.0

func setup_arrow(position: Vector2, direction: Vector2, arrow_speed: float) -> void:
	"""Setup arrow with initial parameters"""
	global_position = position
	start_position = position
	velocity = direction * arrow_speed
	traveled_distance = 0.0
	
	# Orient arrow based on velocity direction
	if velocity.length() > 0:
		rotation = velocity.angle()

func _physics_process(delta: float) -> void:
	# Move the arrow
	var movement: Vector2 = velocity * delta
	global_position += movement
	traveled_distance += movement.length()
	
	# Check if arrow has traveled max range
	if traveled_distance >= max_range:
		_return_to_pool()

func _on_screen_exited() -> void:
	"""Called when arrow exits screen - return to pool"""
	_return_to_pool()

func _return_to_pool() -> void:
	"""Return this arrow to the pool"""
	ProjectilePool.return_arrow(self)