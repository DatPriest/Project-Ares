
-----

# Project Ares - 2D Survivor Roguelite

 **Project Ares** ist ein actiongeladenes 2D-Top-Down-Roguelite im Survivor-Stil, entwickelt mit der Godot Engine 4. Kämpfe gegen unerbittliche Horden von Gegnern, sammle Erfahrung, um aufzusteigen, und wähle aus einer Vielzahl von Fähigkeiten und Upgrades, um in jeder Runde einen einzigartigen Build zu erstellen. Das Ziel ist einfach: Überlebe so lange wie möglich.

Das Projekt befindet sich derzeit in der aktiven Entwicklung mit dem Ziel, einen fesselnden Koop-Multiplayer-Modus für bis zu 16 Spieler zu implementieren.

## ✨ Kern-Features

  * **Klassisches Survivor-Gameplay:** Einfache Steuerung, automatische Angriffe. Konzentriere dich auf Bewegung, Positionierung und strategische Entscheidungen.
  * **Dynamische Progression:** Jeder Levelaufstieg gibt dir die Wahl zwischen neuen Fähigkeiten und mächtigen Upgrades. Kein Durchlauf ist wie der letzte\!
  * **Wachsende Gegnervielfalt:** Kämpfe gegen verschiedene Gegnertypen mit einzigartigen Verhaltensweisen.
  * **Meta-Progression:** Schalte zwischen den Runden dauerhafte Verbesserungen frei, um stärker zu werden und länger zu überleben.
  * **Geplanter 16-Spieler-Koop-Multiplayer:** Schließe dich mit bis zu 15 anderen Spielern zusammen, um die Horden gemeinsam zu bekämpfen, exklusiv über Steam.

## 🕹️ Gameplay-Überblick

1.  **Wähle deinen Charakter** (zukünftiges Feature) und starte in der Arena.
2.  **Bewege dich,** um den anstürmenden Gegnerwellen auszuweichen. Deine Waffen und Fähigkeiten feuern automatisch.
3.  **Sammle Erfahrungskristalle,** die von besiegten Gegnern fallen gelassen werden, um im Level aufzusteigen.
4.  **Triff strategische Entscheidungen,** wenn du aufsteigst, indem du neue Waffen oder Upgrades für deine bestehenden Fähigkeiten wählst.
5.  **Überlebe** so lange wie du kannst, setze neue Rekorde und schalte dauerhafte Boni für zukünftige Runden frei.

## 🌐 Geplanter Multiplayer (16 Spieler über Steam)

Das Kernziel von Project Ares ist es, ein chaotisches und unterhaltsames Koop-Erlebnis zu schaffen. Hier ist der technische Plan für die Implementierung.

### Architektur

  * **Technologie:** Godot 4's High-Level Networking API in Kombination mit dem [GodotSteam](https://godotsteam.com/) GDExtension-Plugin.
  * **Verbindungs-Modell:** Peer-to-Peer mit Steam's Relay-Netzwerk (Steam Datagram Relay). Einer der Spieler agiert als Host (Listen-Server), der die Spiel-Logik autoritativ verwaltet. Dies verhindert Cheating und sorgt für eine konsistente Spielwelt.
  * **Spieler-Slots:** Das Spiel wird Lobbys für bis zu 16 Spieler unterstützen.

### Synchronisation

Die größte Herausforderung bei 16 Spielern und hunderten von Gegnern ist die Synchronisation.

1.  **Spieler-Synchronisation:**

      * Die Position, Animation und der Zustand jedes Spielers werden über einen `MultiplayerSynchronizer`-Node synchronisiert. Die Synchronisation erfolgt unzuverlässig (unreliable), aber geordnet, um die Latenz gering zu halten.
      * Aktionen wie das Erleiden von Schaden werden über zuverlässige Remote Procedure Calls (RPCs) an den Host gesendet und von dort an alle Clients verteilt.

    <!-- end list -->

    ```gdscript
    # player.gd
    @export var health_component: HealthComponent

    # RPC wird vom Client aufgerufen, aber nur auf dem Host (Server) ausgeführt
    @rpc("call_remote", "reliable")
    func take_damage_rpc(amount: int):
        if is_multiplayer_authority(): # Nur der Host führt die Logik aus
            health_component.damage(amount)
    ```

2.  **Gegner- & Projektil-Synchronisation:**

      * Das Spawnen von Gegnern wird ausschließlich vom Host gesteuert.
      * Um die Netzwerkbelastung zu minimieren, wird die Position der meisten "dummen" Gegner **nicht** kontinuierlich synchronisiert. Stattdessen synchronisiert der Host nur wichtige Ereignisse:
          * `spawn_enemy(enemy_type, position, id)` - RPC vom Host an alle Clients.
          * `enemy_took_damage(id, new_health)` - RPC vom Host an alle Clients.
          * `enemy_died(id)` - RPC vom Host an alle Clients.
      * Jeder Client simuliert die Gegnerbewegung zwischen diesen Updates eigenständig. Dies reduziert den Netzwerk-Traffic drastisch. Nur bei wichtigen oder komplexen Gegnern (z.B. Bossen) wird eine kontinuierliche Synchronisation in Betracht gezogen.

3.  **Welt-Zustand:**

      * Der Spiel-Timer, die Wellen-Nummer und Level-Ups werden vom Host verwaltet und über RPCs an die Clients gesendet.
      * Das Aufsammeln von Erfahrungskristallen wird lokal vom Client gemeldet (`i_picked_up_xp_rpc.rpc_id(1, xp_id)`), vom Host validiert und das Ergebnis (`level_up_rpc`) an den entsprechenden Client zurückgesendet.

## 🚀 Roadmap

  * **Phase 1: Kern-Gameplay (In Arbeit)**
      * [x] Spieler-Bewegung und Fähigkeiten
      * [x] Gegner-KI und Spawning
      * [ ] Mehr Waffen, Upgrades und Gegnertypen
      * [ ] Boss-Gegner
  * **Phase 2: Multiplayer-Prototyp**
      * [ ] Integration von GodotSteam
      * [ ] Basis-Lobby-System (Erstellen, Beitreten)
      * [ ] Prototyp für 2-4 Spieler
  * **Phase 3: Skalierung & Inhalt**
      * [ ] Optimierung des Netcodes für 16 Spieler
      * [ ] Multiplayer-spezifische Fähigkeiten und Balancing
      * [ ] Steam-Features: Achievements, Freundes-Einladungen
  * **Phase 4: Politur & Veröffentlichung**
      * [ ] Sound-Design & Musik
      * [ ] Visuelle Effekte & UI-Verbesserungen
      * [ ] Community-Testing & Balancing

## 🛠️ Setup & Mitwirken

Du möchtest bei der Entwicklung helfen? Großartig\!

1.  **Klone das Repository:**
    ```bash
    git clone https://github.com/DatPriest/Project-Ares.git
    ```
2.  **Öffne das Projekt** in der Godot Engine (Version 4.2 oder neuer).
3.  **Lese die Entwickler-Dokumentation:** Bevor du Code schreibst, lies unseren [**Developer Onboarding Guide**](docs/contributing.md) für eine umfassende Einführung in Projektarchitektur, Komponenten-System und Code-Standards.

**Wichtige Ressourcen für Mitwirkende:**
- 📖 [Contributing Guide](docs/contributing.md) - Vollständige Entwickler-Dokumentation
- 🤖 [Copilot Instructions](.github/copilot-instructions.md) - KI-Coding-Standards 
- 🧪 [DPS Testing System](scenes/test/dps_benchmark/README.md) - Ability-Testing und Balance

Wir freuen uns über Pull Requests und Issue-Reports\!
