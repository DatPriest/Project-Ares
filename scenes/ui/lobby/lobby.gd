extends CanvasLayer

signal back_pressed

@onready var player_list: ItemList = %PlayerList
@onready var start_button: Button = %StartButton
@onready var leave_button: Button = %LeaveButton
@onready var lobby_info_label: Label = %LobbyInfoLabel
@onready var status_label: Label = %StatusLabel

func _ready() -> void:
	start_button.pressed.connect(_on_start_pressed)
	leave_button.pressed.connect(_on_leave_pressed)
	
	# Connect to Steam multiplayer signals
	SteamMultiplayer.player_joined.connect(_on_player_joined)
	SteamMultiplayer.player_left.connect(_on_player_left)
	SteamMultiplayer.game_started.connect(_on_game_started)
	SteamMultiplayer.lobby_left.connect(_on_lobby_left)
	GameEvents.player_spawned.connect(_on_player_spawned)
	
	_update_lobby_display()
	
	# Only host can start the game
	start_button.visible = SteamMultiplayer.is_host

func _update_lobby_display() -> void:
	var lobby_info = SteamMultiplayer.get_lobby_info()
	
	if lobby_info.is_empty():
		status_label.text = "Not in a lobby"
		return
	
	# Update lobby info
	lobby_info_label.text = "Lobby ID: " + str(lobby_info.lobby_id) + "\nPlayers: " + str(lobby_info.member_count) + "/" + str(lobby_info.max_members)
	
	# Update player list
	player_list.clear()
	for steam_id in lobby_info.members:
		var member = lobby_info.members[steam_id]
		var player_text = member.name
		if steam_id == SteamMultiplayer.steam_id:
			player_text += " (You)"
		if SteamMultiplayer.is_host and steam_id == SteamMultiplayer.steam_id:
			player_text += " [HOST]"
		player_list.add_item(player_text)
	
	# Update status
	if SteamMultiplayer.is_host:
		status_label.text = "You are the host. Click Start Game when ready."
	else:
		status_label.text = "Waiting for host to start the game..."

func _on_start_pressed() -> void:
	if not SteamMultiplayer.is_host:
		return
	
	status_label.text = "Starting game..."
	start_button.disabled = true
	SteamMultiplayer.start_game()

func _on_leave_pressed() -> void:
	SteamMultiplayer.leave_lobby()

func _on_player_joined(steam_id: int, name: String) -> void:
	print("Player joined lobby: ", name)
	_update_lobby_display()

func _on_player_left(steam_id: int, name: String) -> void:
	print("Player left lobby: ", name)
	_update_lobby_display()

func _on_game_started() -> void:
	status_label.text = "Game starting..."
	# Transition to multiplayer game scene
	ScreenTransition.transition()
	await ScreenTransition.transitioned_halfway
	get_tree().change_scene_to_file("res://scenes/main/multiplayer_main.tscn")

func _on_lobby_left() -> void:
	back_pressed.emit()

func _on_player_spawned(player_data: Dictionary) -> void:
	print("Player spawned: ", player_data)