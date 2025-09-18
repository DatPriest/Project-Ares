
# Anweisungen für KI-Assistenten (GitHub Copilot) für "Project Ares"

Willkommen bei Project Ares! Du bist ein KI-Assistent, der bei der Entwicklung dieses Spiels hilft. Um sicherzustellen, dass dein Beitrag konsistent und von hoher Qualität ist, befolge bitte die folgenden Anweisungen genau.

## 1. Projektübersicht

**Projekt Ares** ist ein 2D-Top-Down-Actionspiel im Survivor-Stil, entwickelt mit der **Godot Engine 4** und **GDScript**. Der Spieler steuert einen Charakter, der automatisch angreift, und muss Wellen von Gegnern überleben, indem er Erfahrung sammelt, auflevelt und neue Fähigkeiten oder Verbesserungen auswählt.

**Kern-Features:**
* **Spieler-Progression:** Sammeln von Erfahrungspunkten (XP), Level-Ups.
* **Fähigkeitssystem:** Automatische Angriffe durch Fähigkeiten, die verbessert werden können.
* **Gegner-Management:** Dynamisches Spawnen von Gegnern mit steigender Schwierigkeit.
* **Komponenten-Architektur:** Wiederverwendbare Nodes für Funktionalitäten wie Leben, Bewegung etc.

## 2. GDScript - Programmierstandards und Best Practices

Qualitativ hochwertiger und lesbarer Code ist entscheidend.

### 2.1. Statische Typisierung (Static Typing)

**Verwende IMMER statische Typisierung.** Gib für Variablen, Funktionsparameter und Rückgabewerte explizite Typen an. Das reduziert Fehler und verbessert die Code-Vervollständigung.

```gdscript
# GUT
var health: int = 100
var speed: float = 80.0
var player_node: CharacterBody2D

func apply_damage(amount: int) -> void:
    health -= amount
    if health <= 0:
        die()
````

```gdscript
# SCHLECHT
var health = 100
var player_node

func apply_damage(amount):
    health -= amount
```

### 2.2. Namenskonventionen

  * **Klassen / Nodes:** `PascalCase` (z.B., `PlayerController`, `HealthComponent`).
  * **Dateien (Skripte & Szenen):** `snake_case` (z.B., `player_controller.gd`, `health_component.tscn`).
  * **Variablen & Funktionen:** `snake_case` (z.B., `max_health`, `apply_damage`).
  * **Signale:** `past_tense` (Vergangenheitsform), `snake_case` (z.B., `died`, `health_updated`).
  * **Konstanten:** `UPPER_SNAKE_CASE` (z.B., `MAX_SPEED`).

### 2.3. Onready-Annotation

Verwende `@onready` anstelle von `$NodePath` im `_ready()`-Callback, um Nodes sicher zu referenzieren.

```gdscript
# GUT
@onready var animation_player: AnimationPlayer = $AnimationPlayer

func _ready() -> void:
    animation_player.play("run")
```

### 2.4. Exports

Exportiere Variablen mit `@export`, um sie im Godot-Editor sichtbar und konfigurierbar zu machen. Gib immer einen expliziten Typ an.

```gdscript
@export var move_speed: float = 100.0
@export var bullet_scene: PackedScene
```

## 3\. Architektur & Design-Patterns

### 3.1. Komponentenbasierte Architektur

Das Projekt nutzt eine komponentenbasierte Architektur. Funktionalitäten sind in wiederverwendbare Szenen/Nodes gekapselt (z.B., `HealthComponent`, `VelocityComponent`). Anstatt komplexe Klassen zu erstellen, füge diese Komponenten als Child-Nodes zu GameObjects hinzu.

**Beispiel:** Ein Gegner (`base_enemy.tscn`) besteht aus:

  * `HealthComponent` (verwaltet Leben und Tod)
  * `VelocityComponent` (steuert die Bewegung)
  * `HitboxComponent` / `HurtboxComponent` (für Kollisionen und Schaden)

### 3.2. Singletons (Autoloads)

Globale Manager werden als Singletons über Godots "Autoload"-Funktion verwaltet.

  * **`GameEvents`:** Ein zentraler Event-Bus für die entkoppelte Kommunikation zwischen Spielsystemen. Anstatt direkte Referenzen zu halten, sollten Systeme Signale über `GameEvents` senden und empfangen.
  * **`MetaProgression`:** Verwaltet dauerhafte Upgrades zwischen Spielrunden.
  * **`MusicPlayer`:** Steuert die Hintergrundmusik.

**Beispiel für die Verwendung von `GameEvents`:**

```gdscript
# Ein Gegner sendet ein Signal, wenn er besiegt wird
GameEvents.enemy_defeated.emit(reward_amount)

# Ein UI-Element hört auf dieses Signal
func _ready() -> void:
    GameEvents.enemy_defeated.connect(_on_enemy_defeated)

func _on_enemy_defeated(reward: int) -> void:
    # Logik, um die Punktzahl zu aktualisieren
```

### 3.3. Ressourcen für Konfiguration

Verwende `Resource`-basierte Skripte (`.gd`-Dateien, die von `Resource` erben), um Daten zu konfigurieren. Dies wird bereits für Upgrades (`AbilityUpgrade`) und Meta-Upgrades (`MetaUpgrade`) genutzt. Halte dich an dieses Muster für neue konfigurierbare Daten (z.B., Gegnertypen, Waffen-Stats).

## 4\. Git-Workflow & Issue-Management

  * **Commit-Nachrichten:** Schreibe aussagekräftige Commit-Nachrichten. Beginne mit einem Präfix, das die Art der Änderung beschreibt (z.B., `feat:`, `fix:`, `refactor:`, `docs:`).
      * `feat: Implement Goblin Archer enemy`
      * `fix: Prevent player from moving outside the map`
      * `refactor: Centralize audio playback in AudioManager`
  * **Branching:** Erstelle für jedes neue Feature oder jeden Bugfix einen eigenen Branch.
  * **Issues:** Wenn du an einem GitHub Issue arbeitest, referenziere es in deinen Commits (z.B., `feat: Implement Goblin Archer (fixes #1)`).

Wenn du den Auftrag erhältst, neue Issues zu erstellen (wie in Issue \#5 beschrieben), analysiere den Code gemäß den dortigen Richtlinien und erstelle detaillierte, umsetzbare Issues.

```
```
