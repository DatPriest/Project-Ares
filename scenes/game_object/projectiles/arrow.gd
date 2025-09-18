extends Area2D
class_name Arrow

@export var speed: float = 300.0
@export var max_range: float = 400.0

var velocity: Vector2 = Vector2.ZERO
var start_position: Vector2
var traveled_distance: float = 0.0

@onready var sprite_2d = $Sprite2D
@onready var hitbox_component = $HitboxComponent

func _ready():
	start_position = global_position
	
	# Orient arrow based on velocity direction
	if velocity.length() > 0:
		rotation = velocity.angle()
	
	# Set damage on the hitbox component
	if hitbox_component:
		hitbox_component.damage = 10
		# Connect to area entered to destroy arrow on hit
		hitbox_component.area_entered.connect(_on_hitbox_area_entered)

func _physics_process(delta):
	# Move the arrow
	var movement = velocity * delta
	global_position += movement
	traveled_distance += movement.length()
	
	# Check if arrow has traveled max range
	if traveled_distance >= max_range:
		queue_free()

func _on_hitbox_area_entered(area: Area2D):
	# Arrow hit something, destroy it
	queue_free()