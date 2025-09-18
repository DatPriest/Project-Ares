extends Node

@export var end_screen_scene: PackedScene

var pause_menu_scene = preload("res://scenes/ui/pause_menu.tscn")
var crafting_menu_scene = preload("res://scenes/ui/crafting_menu/crafting_menu.tscn")

func _ready():
	$%Player.health_component.died.connect(on_player_died)
	
	
func _unhandled_input(event: InputEvent) -> void:
	handle_inventory(event)
	handle_escape(event)
	handle_debug(event)

func handle_debug(event: InputEvent) -> void:
	# Debug key to print projectile pool stats
	if event.is_action_pressed("ui_accept") and Input.is_key_pressed(KEY_CTRL):
		ProjectilePool.print_pool_stats()
		get_tree().root.set_input_as_handled()


func handle_inventory(event: InputEvent) -> void:
	if event.is_action_pressed("inventory"):
		add_child(crafting_menu_scene.instantiate())
		get_tree().root.set_input_as_handled()
		
func handle_escape(event: InputEvent) -> void:
	if event.is_action_pressed("Escape"):
		add_child(pause_menu_scene.instantiate())
		get_tree().root.set_input_as_handled()
	
func on_player_died() -> void:
	var end_screen_instance = end_screen_scene.instantiate()
	add_child(end_screen_instance)
	end_screen_instance.set_defeat()
	MetaProgression.save()
