extends CanvasLayer

signal back_pressed

@onready var window_button: Button = %WindowButton
@onready var music_slider: HSlider = %MusicSlider
@onready var sfx_slider: HSlider = %SFXSlider
@onready var back_button: Button = %BackButton


func _ready():
	back_button.pressed.connect(on_back_button_pressed)
	window_button.pressed.connect(on_window_button_pressed)
	sfx_slider.value_changed.connect(on_sfx_slider_changed)
	music_slider.value_changed.connect(on_music_slider_changed)
	update_display()
	
func update_display():
	window_button.text = "Windowed"
	if DisplayServer.window_get_mode() == DisplayServer.WINDOW_MODE_FULLSCREEN:
		window_button.text = "Fullscreen"
	sfx_slider.value = AudioManager.get_sfx_volume_percent()
	music_slider.value = AudioManager.get_music_volume_percent()


func on_window_button_pressed():
	var mode = DisplayServer.window_get_mode()
	if mode != DisplayServer.WINDOW_MODE_FULLSCREEN:
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN)
	else:
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED, false)		
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)
	update_display()

func on_sfx_slider_changed(value: float):
	AudioManager.set_sfx_volume_percent(value)

func on_music_slider_changed(value: float):
	AudioManager.set_music_volume_percent(value)

func on_back_button_pressed():
	ScreenTransition.transition()
	await ScreenTransition.transitioned_halfway
	back_pressed.emit()
