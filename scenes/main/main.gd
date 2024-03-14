extends Node

@export var end_screen_scene: PackedScene

var pause_menu_scene = preload("res://scenes/ui/pause_menu.tscn")
var crafting_menu_scene = preload("res://scenes/ui/crafting_menu/crafting_menu.tscn")

func _ready():
	$%Player.health_component.died.connect(on_player_died)
	
	
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
