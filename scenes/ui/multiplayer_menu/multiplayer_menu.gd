extends CanvasLayer

signal back_pressed

@onready var host_button: Button = %HostButton
@onready var join_button: Button = %JoinButton
@onready var lobby_browser_button: Button = %LobbyBrowserButton
@onready var back_button: Button = %BackButton
@onready var status_label: Label = %StatusLabel

var lobby_browser_scene = preload("res://scenes/ui/lobby_browser/lobby_browser.tscn")
var lobby_scene = preload("res://scenes/ui/lobby/lobby.tscn")

func _ready() -> void:
	host_button.pressed.connect(_on_host_pressed)
	join_button.pressed.connect(_on_join_pressed)
	lobby_browser_button.pressed.connect(_on_lobby_browser_pressed)
	back_button.pressed.connect(_on_back_pressed)
	
	# Connect to Steam multiplayer signals
	SteamMultiplayer.lobby_created.connect(_on_lobby_created)
	SteamMultiplayer.lobby_joined.connect(_on_lobby_joined)
	SteamMultiplayer.lobby_join_failed.connect(_on_lobby_join_failed)
	
	_update_ui_state()

func _update_ui_state() -> void:
	if not SteamMultiplayer:
		status_label.text = "Steam not available - Multiplayer disabled"
		host_button.disabled = true
		join_button.disabled = true
		lobby_browser_button.disabled = true
		return
	
	if SteamMultiplayer.is_in_lobby():
		status_label.text = "In lobby"
		host_button.disabled = true
		join_button.disabled = true
		lobby_browser_button.disabled = true
	else:
		status_label.text = "Ready to play multiplayer"
		host_button.disabled = false
		join_button.disabled = false
		lobby_browser_button.disabled = false

func _on_host_pressed() -> void:
	status_label.text = "Creating lobby..."
	host_button.disabled = true
	SteamMultiplayer.create_lobby()

func _on_join_pressed() -> void:
	# Quick join - search for available lobbies and join the first one
	status_label.text = "Searching for lobbies..."
	join_button.disabled = true
	SteamMultiplayer.search_lobbies()
	
	# Connect to lobby found signal temporarily
	if not GameEvents.lobbies_found.is_connected(_on_quick_join_lobby_found):
		GameEvents.lobbies_found.connect(_on_quick_join_lobby_found, CONNECT_ONE_SHOT)

func _on_lobby_browser_pressed() -> void:
	var browser_instance = lobby_browser_scene.instantiate()
	add_child(browser_instance)
	browser_instance.back_pressed.connect(_on_browser_closed.bind(browser_instance))

func _on_back_pressed() -> void:
	back_pressed.emit()

func _on_lobby_created(lobby_id: int) -> void:
	print("Lobby created: ", lobby_id)
	_open_lobby_scene()

func _on_lobby_joined(lobby_id: int) -> void:
	print("Joined lobby: ", lobby_id)
	_open_lobby_scene()

func _on_lobby_join_failed(reason: String) -> void:
	status_label.text = "Failed to join: " + reason
	join_button.disabled = false

func _on_quick_join_lobby_found(lobby_list: Array) -> void:
	if lobby_list.size() > 0:
		var first_lobby = lobby_list[0]
		SteamMultiplayer.join_lobby(first_lobby.lobby_id)
	else:
		status_label.text = "No lobbies found"
		join_button.disabled = false

func _open_lobby_scene() -> void:
	var lobby_instance = lobby_scene.instantiate()
	get_parent().add_child(lobby_instance)
	lobby_instance.back_pressed.connect(_on_lobby_closed.bind(lobby_instance))
	queue_free()

func _on_browser_closed(browser_instance: Node) -> void:
	browser_instance.queue_free()
	_update_ui_state()

func _on_lobby_closed(lobby_instance: Node) -> void:
	lobby_instance.queue_free()
	_update_ui_state()