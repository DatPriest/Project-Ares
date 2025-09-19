extends Node

signal lobby_created(lobby_id: int)
signal lobby_joined(lobby_id: int)
signal lobby_left()
signal lobby_join_failed(reason: String)
signal player_joined(steam_id: int, name: String)
signal player_left(steam_id: int, name: String)
signal game_started()
signal connection_established()

const MAX_PLAYERS: int = 16
const LOBBY_TYPE_PUBLIC: int = 0
const LOBBY_TYPE_FRIENDS_ONLY: int = 1
const LOBBY_TYPE_PRIVATE: int = 2

var steam_app_id: int = 480  # Default to Spacewar for testing
var steam_username: String = ""
var steam_id: int = 0
var current_lobby_id: int = 0
var is_host: bool = false
var lobby_members: Dictionary = {}
var player_data: Dictionary = {}

# Multiplayer peer
var steam_peer: MultiplayerPeer

func _ready() -> void:
	if not _initialize_steam():
		push_error("Failed to initialize Steam. Multiplayer features will be disabled.")
		return
	
	# Connect Steam callbacks - only if Steam singleton is available
	if Engine.has_singleton("Steam") and Steam:
		if Steam.has_signal("lobby_created"):
			Steam.lobby_created.connect(_on_lobby_created)
			Steam.lobby_match_list.connect(_on_lobby_match_list)
			Steam.lobby_joined.connect(_on_lobby_joined)
			Steam.lobby_join_requested.connect(_on_lobby_join_requested)
			Steam.lobby_data_update.connect(_on_lobby_data_update)
			Steam.lobby_chat_update.connect(_on_lobby_chat_update)
			Steam.join_requested.connect(_on_join_requested)
		
		# Get Steam user info
		if Steam.loggedOn():
			steam_username = Steam.getPersonaName()
			steam_id = Steam.getSteamID()
			print("Steam initialized - User: ", steam_username, " ID: ", steam_id)
		else:
			push_error("Steam user not logged in")

func _initialize_steam() -> bool:
	# Check if Steam is available (this will be false in our development environment)
	if not OS.has_feature("steam") and not Engine.has_singleton("Steam"):
		print("Steam not available - using mock Steam functionality for development")
		_setup_mock_steam()
		return true
	
	# Real Steam initialization - check if Steam singleton exists
	if not Engine.has_singleton("Steam"):
		print("Steam singleton not found")
		_setup_mock_steam()
		return true
	
	# Initialize Steam
	var initialize_result: Dictionary = Steam.steamInitEx(false, steam_app_id)
	
	if initialize_result['status'] != 1:
		push_error("Failed to initialize Steam: " + str(initialize_result))
		return false
	
	return true

func _setup_mock_steam():
	# Mock steam functionality for development/testing
	steam_username = "Dev Player"
	steam_id = randi_range(1000, 9999)
	print("Mock Steam initialized - User: ", steam_username, " ID: ", steam_id)

# Lobby Creation
func create_lobby(lobby_type: int = LOBBY_TYPE_FRIENDS_ONLY, max_members: int = MAX_PLAYERS) -> void:
	if not Engine.has_singleton("Steam") and not _is_mock_mode():
		push_error("Steam not initialized")
		return
	
	print("Creating lobby...")
	
	if _is_mock_mode():
		# Mock lobby creation
		var mock_lobby_id = randi_range(10000, 99999)
		await get_tree().process_frame  # Simulate async operation
		_on_lobby_created(1, mock_lobby_id)
	else:
		Steam.createLobby(lobby_type, max_members)

func _is_mock_mode() -> bool:
	return not Engine.has_singleton("Steam")

func _on_lobby_created(connect_result: int, lobby_id: int) -> void:
	if connect_result == 1:  # Success
		current_lobby_id = lobby_id
		is_host = true
		
		# Set lobby data (only if Steam is available)
		if not _is_mock_mode():
			Steam.setLobbyData(lobby_id, "game_name", "Project Ares")
			Steam.setLobbyData(lobby_id, "game_version", "1.0")
			Steam.setLobbyData(lobby_id, "max_players", str(MAX_PLAYERS))
			Steam.setLobbyData(lobby_id, "current_players", "1")
			Steam.setLobbyData(lobby_id, "host_name", steam_username)
		
		# Add ourselves to lobby members
		lobby_members[steam_id] = {
			"name": steam_username,
			"steam_id": steam_id,
			"is_ready": false
		}
		
		print("Lobby created successfully: ", lobby_id)
		lobby_created.emit(lobby_id)
	else:
		push_error("Failed to create lobby: " + str(connect_result))

# Lobby Search and Join
func search_lobbies() -> void:
	if not Engine.has_singleton("Steam") and not _is_mock_mode():
		return
	
	print("Searching for lobbies...")
	
	if _is_mock_mode():
		# Mock lobby search
		await get_tree().process_frame
		var mock_lobbies = [
			{
				"lobby_id": 12345,
				"game_name": "Project Ares",
				"host_name": "Test Host 1",
				"current_players": "2",
				"max_players": "16"
			},
			{
				"lobby_id": 67890,
				"game_name": "Project Ares", 
				"host_name": "Test Host 2",
				"current_players": "1",
				"max_players": "16"
			}
		]
		_on_lobby_match_list([12345, 67890])
	else:
		Steam.addRequestLobbyListStringFilter("game_name", "Project Ares", 0)  # ELobbyComparison.Equal
		Steam.addRequestLobbyListNumericalFilter("current_players", MAX_PLAYERS, -1)  # Less than max
		Steam.requestLobbyList()

func _on_lobby_match_list(lobbies: Array) -> void:
	print("Found ", lobbies.size(), " lobbies")
	
	var lobby_list: Array = []
	for lobby_id in lobbies:
		var lobby_data: Dictionary
		
		if _is_mock_mode():
			# Mock lobby data
			lobby_data = {
				"lobby_id": lobby_id,
				"game_name": "Project Ares",
				"host_name": "Test Host " + str(lobby_id),
				"current_players": str(randi_range(1, 4)),
				"max_players": "16"
			}
		else:
			lobby_data = {
				"lobby_id": lobby_id,
				"game_name": Steam.getLobbyData(lobby_id, "game_name"),
				"host_name": Steam.getLobbyData(lobby_id, "host_name"),
				"current_players": Steam.getLobbyData(lobby_id, "current_players"),
				"max_players": Steam.getLobbyData(lobby_id, "max_players")
			}
		
		lobby_list.append(lobby_data)
	
	# Emit signal with lobby list for UI to handle
	GameEvents.lobbies_found.emit(lobby_list)

func join_lobby(lobby_id: int) -> void:
	if not Engine.has_singleton("Steam") and not _is_mock_mode():
		return
	
	print("Joining lobby: ", lobby_id)
	
	if _is_mock_mode():
		# Mock join
		await get_tree().process_frame
		_on_lobby_joined(lobby_id, 0, false, 1)  # Success
	else:
		Steam.joinLobby(lobby_id)

func _on_lobby_joined(lobby_id: int, permissions: int, locked: bool, response: int) -> void:
	if response == 1:  # Success
		current_lobby_id = lobby_id
		is_host = false
		
		# Get lobby members
		_update_lobby_members()
		
		print("Joined lobby successfully: ", lobby_id)
		lobby_joined.emit(lobby_id)
	else:
		print("Failed to join lobby: ", response)
		lobby_join_failed.emit("Failed to join lobby: " + str(response))

func _on_lobby_join_requested(lobby_id: int, friend_id: int) -> void:
	# Handle Steam overlay join requests
	join_lobby(lobby_id)

func leave_lobby() -> void:
	if current_lobby_id != 0:
		if not _is_mock_mode():
			Steam.leaveLobby(current_lobby_id)
		_cleanup_lobby()
		lobby_left.emit()

func _cleanup_lobby() -> void:
	current_lobby_id = 0
	is_host = false
	lobby_members.clear()
	player_data.clear()
	
	if steam_peer:
		steam_peer.close()
		steam_peer = null

# Lobby Management
func _update_lobby_members() -> void:
	if current_lobby_id == 0:
		return
	
	var member_count: int = Steam.getNumLobbyMembers(current_lobby_id)
	lobby_members.clear()
	
	for i in range(member_count):
		var member_id: int = Steam.getLobbyMemberByIndex(current_lobby_id, i)
		var member_name: String = Steam.getFriendPersonaName(member_id)
		
		lobby_members[member_id] = {
			"name": member_name,
			"steam_id": member_id,
			"is_ready": false
		}

func _on_lobby_data_update(success: int, lobby_id: int, member_id: int, key: int) -> void:
	if lobby_id != current_lobby_id:
		return
	
	_update_lobby_members()
	
	# Update current player count in lobby data if we're host
	if is_host:
		var current_count: String = str(lobby_members.size())
		Steam.setLobbyData(lobby_id, "current_players", current_count)

func _on_lobby_chat_update(lobby_id: int, changed_id: int, making_change_id: int, chat_state: int) -> void:
	if lobby_id != current_lobby_id:
		return
	
	var member_name: String = Steam.getFriendPersonaName(changed_id)
	
	match chat_state:
		Steam.CHAT_MEMBER_STATE_CHANGE_ENTERED:
			print("Player joined: ", member_name)
			player_joined.emit(changed_id, member_name)
		Steam.CHAT_MEMBER_STATE_CHANGE_LEFT:
			print("Player left: ", member_name)
			if lobby_members.has(changed_id):
				lobby_members.erase(changed_id)
			player_left.emit(changed_id, member_name)
		Steam.CHAT_MEMBER_STATE_CHANGE_DISCONNECTED:
			print("Player disconnected: ", member_name)
			if lobby_members.has(changed_id):
				lobby_members.erase(changed_id)
			player_left.emit(changed_id, member_name)

func _on_join_requested(lobby_id: int, friend_id: int) -> void:
	# Handle join requests from Steam friends
	join_lobby(lobby_id)

# Game Start
func start_game() -> void:
	if not is_host:
		push_error("Only host can start the game")
		return
	
	if lobby_members.size() < 1:
		push_error("Not enough players to start game")
		return
	
	# Set up Steam P2P networking
	_setup_steam_networking()
	
	# Notify all players to start the game
	Steam.setLobbyData(current_lobby_id, "game_started", "true")
	
	# Start the game locally
	game_started.emit()

func _setup_steam_networking() -> void:
	# Create Steam multiplayer peer or fallback to ENet for development
	if Engine.has_singleton("Steam") and Steam and ClassDB.class_exists("SteamMultiplayerPeer"):
		steam_peer = SteamMultiplayerPeer.new()
		
		if is_host:
			# Host creates the session
			var error = steam_peer.create_host(0)  # 0 means use Steam relay
			if error != OK:
				push_error("Failed to create Steam host: " + str(error))
				return
		else:
			# Clients connect to host
			var host_id: int = Steam.getLobbyOwner(current_lobby_id)
			var error = steam_peer.create_client(host_id, 0)
			if error != OK:
				push_error("Failed to create Steam client: " + str(error))
				return
	else:
		# Development fallback - use ENet peer
		print("Using ENet peer for development (Steam not available)")
		var enet_peer = ENetMultiplayerPeer.new()
		
		if is_host:
			var error = enet_peer.create_server(7000, 16)
			if error != OK:
				push_error("Failed to create ENet server: " + str(error))
				return
			steam_peer = enet_peer
		else:
			var error = enet_peer.create_client("127.0.0.1", 7000)
			if error != OK:
				push_error("Failed to create ENet client: " + str(error))
				return
			steam_peer = enet_peer
	
	# Set the multiplayer peer
	multiplayer.multiplayer_peer = steam_peer
	
	# Connect multiplayer signals
	multiplayer.peer_connected.connect(_on_peer_connected)
	multiplayer.peer_disconnected.connect(_on_peer_disconnected)
	multiplayer.connected_to_server.connect(_on_connected_to_server)
	multiplayer.connection_failed.connect(_on_connection_failed)
	multiplayer.server_disconnected.connect(_on_server_disconnected)
	
	connection_established.emit()

# Multiplayer Callbacks
func _on_peer_connected(peer_id: int) -> void:
	print("Peer connected: ", peer_id)

func _on_peer_disconnected(peer_id: int) -> void:
	print("Peer disconnected: ", peer_id)

func _on_connected_to_server() -> void:
	print("Connected to server")

func _on_connection_failed() -> void:
	push_error("Connection to server failed")

func _on_server_disconnected() -> void:
	print("Server disconnected")
	_cleanup_lobby()

# Utility Functions
func get_lobby_info() -> Dictionary:
	if current_lobby_id == 0:
		return {}
	
	return {
		"lobby_id": current_lobby_id,
		"is_host": is_host,
		"members": lobby_members,
		"member_count": lobby_members.size(),
		"max_members": MAX_PLAYERS
	}

func is_in_lobby() -> bool:
	return current_lobby_id != 0

func get_player_count() -> int:
	return lobby_members.size()

# Called by Godot
func _process(_delta: float) -> void:
	if Engine.has_singleton("Steam") and not _is_mock_mode():
		Steam.run_callbacks()
