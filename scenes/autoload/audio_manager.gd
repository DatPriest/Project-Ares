extends Node

# Bus-Namen aus den Godot-Audio-Einstellungen
const MUSIC_BUS: String = "Music"
const SFX_BUS: String = "SFX"

# Pool für AudioStreamPlayer2D um Garbage Collection zu reduzieren
var sfx_player_pool: Array[AudioStreamPlayer2D] = []
var active_players: Array[AudioStreamPlayer2D] = []
const MAX_POOL_SIZE: int = 20

func _ready() -> void:
	# Pool mit AudioStreamPlayer2D Instanzen vorab füllen
	for i in MAX_POOL_SIZE:
		var player: AudioStreamPlayer2D = AudioStreamPlayer2D.new()
		player.bus = SFX_BUS
		sfx_player_pool.append(player)

func play_sfx(sound: AudioStream, position: Vector2 = Vector2.ZERO) -> void:
	if sound == null:
		return
		
	var player: AudioStreamPlayer2D = _get_sfx_player()
	if player == null:
		return
		
	player.stream = sound
	player.global_position = position
	player.play()
	
	# Automatisches Cleanup nach dem Abspielen
	if not player.finished.is_connected(_on_sfx_finished):
		player.finished.connect(_on_sfx_finished.bind(player))

func play_sfx_random(streams: Array[AudioStream], position: Vector2 = Vector2.ZERO, randomize_pitch: bool = true, min_pitch: float = 0.9, max_pitch: float = 1.1) -> void:
	if streams == null || streams.size() == 0:
		return
		
	var player: AudioStreamPlayer2D = _get_sfx_player()
	if player == null:
		return
		
	if randomize_pitch:
		player.pitch_scale = randf_range(min_pitch, max_pitch)
	else:
		player.pitch_scale = 1.0
		
	player.stream = streams.pick_random()
	player.global_position = position
	player.play()
	
	# Automatisches Cleanup nach dem Abspielen
	if not player.finished.is_connected(_on_sfx_finished):
		player.finished.connect(_on_sfx_finished.bind(player))

func set_music_volume(volume_db: float) -> void:
	var bus_index: int = AudioServer.get_bus_index(MUSIC_BUS)
	AudioServer.set_bus_volume_db(bus_index, volume_db)

func set_sfx_volume(volume_db: float) -> void:
	var bus_index: int = AudioServer.get_bus_index(SFX_BUS)
	AudioServer.set_bus_volume_db(bus_index, volume_db)

func set_music_volume_percent(percent: float) -> void:
	var volume_db: float = linear_to_db(percent)
	set_music_volume(volume_db)

func set_sfx_volume_percent(percent: float) -> void:
	var volume_db: float = linear_to_db(percent)
	set_sfx_volume(volume_db)

func get_music_volume_percent() -> float:
	var bus_index: int = AudioServer.get_bus_index(MUSIC_BUS)
	var volume_db: float = AudioServer.get_bus_volume_db(bus_index)
	return db_to_linear(volume_db)

func get_sfx_volume_percent() -> float:
	var bus_index: int = AudioServer.get_bus_index(SFX_BUS)
	var volume_db: float = AudioServer.get_bus_volume_db(bus_index)
	return db_to_linear(volume_db)

# Private Methoden
func _get_sfx_player() -> AudioStreamPlayer2D:
	var player: AudioStreamPlayer2D
	
	if sfx_player_pool.size() > 0:
		# Player aus Pool wiederverwenden
		player = sfx_player_pool.pop_back()
	else:
		# Neuen Player erstellen falls Pool leer ist
		player = AudioStreamPlayer2D.new()
		player.bus = SFX_BUS
		print("Warning: SFX player pool exhausted, creating new player")
	
	# Player zum Scene-Baum hinzufügen
	add_child(player)
	active_players.append(player)
	
	return player

func _on_sfx_finished(player: AudioStreamPlayer2D) -> void:
	if player == null:
		return
		
	# Player von aktiver Liste entfernen
	var index: int = active_players.find(player)
	if index != -1:
		active_players.remove_at(index)
	
	# Player vom Scene-Baum entfernen
	if player.get_parent() != null:
		player.get_parent().remove_child(player)
	
	# Verbindung trennen um Memory Leaks zu vermeiden
	if player.finished.is_connected(_on_sfx_finished):
		player.finished.disconnect(_on_sfx_finished)
	
	# Player zurück in Pool
	if sfx_player_pool.size() < MAX_POOL_SIZE:
		player.stream = null
		player.pitch_scale = 1.0
		sfx_player_pool.append(player)
	else:
		# Pool ist voll, Player freigeben
		player.queue_free()