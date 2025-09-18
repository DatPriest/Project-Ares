extends CanvasLayer

signal back_pressed

@onready var lobby_list: ItemList = %LobbyList
@onready var refresh_button: Button = %RefreshButton
@onready var join_button: Button = %JoinButton
@onready var back_button: Button = %BackButton
@onready var status_label: Label = %StatusLabel

var current_lobbies: Array = []

func _ready() -> void:
	refresh_button.pressed.connect(_on_refresh_pressed)
	join_button.pressed.connect(_on_join_pressed)
	back_button.pressed.connect(_on_back_pressed)
	lobby_list.item_selected.connect(_on_lobby_selected)
	
	# Connect to Steam multiplayer signals
	GameEvents.lobbies_found.connect(_on_lobbies_found)
	SteamMultiplayer.lobby_joined.connect(_on_lobby_joined)
	SteamMultiplayer.lobby_join_failed.connect(_on_lobby_join_failed)
	
	join_button.disabled = true
	_refresh_lobby_list()

func _refresh_lobby_list() -> void:
	status_label.text = "Searching for lobbies..."
	refresh_button.disabled = true
	lobby_list.clear()
	current_lobbies.clear()
	
	SteamMultiplayer.search_lobbies()

func _on_refresh_pressed() -> void:
	_refresh_lobby_list()

func _on_join_pressed() -> void:
	var selected_items = lobby_list.get_selected_items()
	if selected_items.size() == 0:
		return
	
	var selected_index = selected_items[0]
	if selected_index >= current_lobbies.size():
		return
	
	var lobby_data = current_lobbies[selected_index]
	status_label.text = "Joining lobby..."
	join_button.disabled = true
	
	SteamMultiplayer.join_lobby(lobby_data.lobby_id)

func _on_back_pressed() -> void:
	back_pressed.emit()

func _on_lobby_selected(index: int) -> void:
	join_button.disabled = false

func _on_lobbies_found(lobby_list_data: Array) -> void:
	lobby_list.clear()
	current_lobbies = lobby_list_data
	
	if lobby_list_data.size() == 0:
		status_label.text = "No lobbies found"
	else:
		status_label.text = str(lobby_list_data.size()) + " lobbies found"
		
		for lobby in lobby_list_data:
			var lobby_text = str(lobby.host_name) + " (" + str(lobby.current_players) + "/" + str(lobby.max_players) + ")"
			lobby_list.add_item(lobby_text)
	
	refresh_button.disabled = false

func _on_lobby_joined(lobby_id: int) -> void:
	# This will be handled by the parent multiplayer menu
	pass

func _on_lobby_join_failed(reason: String) -> void:
	status_label.text = "Failed to join: " + reason
	join_button.disabled = false