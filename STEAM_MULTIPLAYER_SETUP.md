# Steam Multiplayer Setup Guide

This document explains how to set up and use the Steam multiplayer system in Project Ares.

## Overview

The game now supports up to 16 players using Steam networking with peer-to-peer connections and Steam Datagram Relay (SDR) for optimal connectivity.

## Features

- **Steam Integration**: Full Steam API integration for lobby management
- **16-Player Support**: Supports up to 16 concurrent players
- **Lobby System**: Create, browse, and join lobbies through Steam
- **Steam Datagram Relay**: Uses Steam's networking infrastructure for reliable connections
- **Listen-Server Model**: Host acts as the authoritative server
- **Player Synchronization**: Real-time synchronization of player positions, health, and actions
- **Development Fallback**: Works without Steam for development using ENet networking

## Requirements

### For Production (Steam Release)
1. **GodotSteam Plugin**: Install the GodotSteam plugin for Godot 4.x
2. **Steam SDK**: The Steam SDK must be properly integrated
3. **App ID**: Configure your Steam App ID in `SteamMultiplayer.steam_app_id`

### For Development
The system includes fallback networking using ENet when Steam is not available, allowing development and testing without Steam.

## Setup Instructions

### 1. Install GodotSteam Plugin
1. Download GodotSteam from: https://github.com/CoaguCo-Industries/GodotSteam
2. Extract to `addons/godotsteam/` directory
3. Enable the plugin in Project Settings > Plugins

### 2. Configure Steam App ID
Edit `scenes/autoload/steam_multiplayer.gd`:
```gdscript
var steam_app_id: int = YOUR_STEAM_APP_ID  # Replace with your actual App ID
```

### 3. Steam SDK Integration
Follow the GodotSteam documentation for integrating the Steam SDK with your export templates.

## Usage

### Main Menu
- New "Multiplayer" button added to the main menu
- Choose from Host Game, Quick Join, or Browse Lobbies

### Hosting a Game
1. Click "Host Game" to create a new lobby
2. Wait for players to join
3. Click "Start Game" when ready

### Joining a Game
1. Use "Quick Join" to join the first available lobby
2. Or use "Browse Lobbies" to see all available games
3. Select a lobby and click "Join Selected"

### In-Game
- All players spawn simultaneously in the multiplayer arena
- Movement, combat, and abilities are synchronized
- Experience and upgrades work independently for each player
- Host has authority over game state and enemy spawning

## Technical Details

### Architecture
- **Listen-Server**: Host acts as the authoritative server
- **P2P Networking**: Direct peer-to-peer connections through Steam
- **Authority System**: Host controls game state, clients handle local input
- **Synchronization**: Uses Godot's MultiplayerSynchronizer for state sync

### Key Components
- `SteamMultiplayer`: Main singleton handling Steam integration
- `MultiplayerPlayer`: Player controller with network synchronization
- `MultiplayerMain`: Game scene with multiplayer player management
- UI components for lobby browsing and management

### Network Optimization
- Position interpolation for smooth remote player movement
- Reliable RPCs for critical events (health, abilities)
- Unreliable RPCs for frequent updates (position, animation)

## Development and Testing

### Without Steam
The system automatically detects when Steam is unavailable and switches to ENet networking:
- Creates mock lobbies for testing
- Uses localhost connections (127.0.0.1:7000)
- Simulates Steam functionality for development

### With Steam
When Steam is available, full Steam integration is used:
- Real Steam lobbies and friends integration
- Steam Datagram Relay for optimal networking  
- Steam overlay and invite system support

## Troubleshooting

### Common Issues
1. **"Steam not available"**: Install GodotSteam plugin and Steam SDK
2. **Connection failed**: Check firewall settings and Steam connectivity
3. **Lobby not found**: Ensure both players have the same game version

### Debug Information
The system outputs debug information to the console:
- Steam initialization status
- Lobby creation/join events
- Player connection/disconnection
- Network synchronization events

## Future Enhancements

Potential improvements for the multiplayer system:
- Spectator mode for defeated players
- In-game chat system
- Player statistics and leaderboards
- Custom game modes (PvP, co-op challenges)
- Dedicated server support for larger games