extends CanvasLayer

@onready var panel_container = %PanelContainer
@onready var resume_button = %ResumeButton
@onready var options_button = %OptionsButton
@onready var quit_button = %QuitButton
@onready var animation_player: AnimationPlayer = $AnimationPlayer

var is_closing: bool

func _ready():
	get_tree().paused = true
	panel_container.pivot_offset = panel_container.size / 2
	
	animation_player.play("default")
	
	var tween = create_tween()
	tween.tween_property(panel_container, "scale", Vector2.ZERO, 0)
	tween.tween_property(panel_container, "scale", Vector2.ONE, .3)\
	.set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_BACK)

func close():
	if is_closing:
		return
		
	is_closing = true
	animation_player.play_backwards("default")
	
	var tween = create_tween()
	tween.tween_property(panel_container, "scale", Vector2.ONE, 0)
	tween.tween_property(panel_container, "scale", Vector2.ZERO, .3)\
	.set_ease(Tween.EASE_IN).set_trans(Tween.TRANS_BACK)

	await tween.finished
	
	get_tree().paused = false	
	queue_free()

func _unhandled_input(event):
	handle_inventory(event)
	handle_escape(event)


func handle_inventory(event):
	if event.is_action_pressed("inventory") && !is_closing:
		close()
		get_tree().root.set_input_as_handled()
		
func handle_escape(event):
	if event.is_action_pressed("Escape") && !is_closing:
		close()
		get_tree().root.set_input_as_handled()
