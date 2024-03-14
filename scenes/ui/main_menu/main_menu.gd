extends CanvasLayer

var options_scene = preload("res://scenes/ui/options_menu.tscn")
@onready var upgrade_button = %UpgradeButton
@onready var options_button = %OptionsButton
@onready var quit_button = %QuitButton
@onready var play_button = %PlayButton

func _ready():
	play_button.pressed.connect(on_play_pressed)
	upgrade_button.pressed.connect(on_upgrade_pressed)
	options_button.pressed.connect(on_options_pressed)
	quit_button.pressed.connect(on_quit_pressed)



func on_quit_pressed():
	get_tree().quit()
	
func on_play_pressed():
	ScreenTransition.transition()
	await ScreenTransition.transitioned_halfway
	get_tree().change_scene_to_file("res://scenes/main/main.tscn")
	
func on_upgrade_pressed():
	ScreenTransition.transition()
	await ScreenTransition.transitioned_halfway
	get_tree().change_scene_to_file("res://scenes/ui/meta_menu/meta_menu.tscn")
	
func on_options_pressed():
	ScreenTransition.transition()
	await ScreenTransition.transitioned_halfway
	var options_instance = options_scene.instantiate()
	add_child(options_instance)
	options_instance.back_pressed.connect(on_options_closed.bind(options_instance))
	

func on_options_closed(options_instance: Node):
	options_instance.queue_free()
