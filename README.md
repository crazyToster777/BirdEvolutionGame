# 🐦 Bird Evolution Game

A 2048-style tile-merging puzzle for iOS with a bird evolution theme. Slide tiles to merge birds, evolve them to higher forms, and race against an energy timer before the clock runs out.

![Platform](https://img.shields.io/badge/platform-iOS-lightgrey?logo=apple)
![Language](https://img.shields.io/badge/language-Swift-orange?logo=swift)
![UI](https://img.shields.io/badge/UI-SwiftUI-blue)
![Architecture](https://img.shields.io/badge/architecture-MVVM-green)

---

## About

Bird Evolution Game takes the classic 2048 mechanic and layers on a time-attack energy system, combo multipliers, consumable power-ups, and a daily play calendar. Instead of numbers, tiles show birds that evolve as they merge — from a humble tier-2 hatchling all the way up to a legendary 16384 form.

---

## Features

### Core Gameplay
- **2048-style merging** — swipe in any direction to slide and merge matching tiles
- **Bird evolution theme** — each tile value has a unique bird illustration (2 → 4 → 8 → … → 16384)
- **Three grid sizes** — 4×4 Classic, 5×5 Hard, 6×6 Expert
- **Win condition** — reach the 2048 tile; keep playing beyond it for a higher score

### Energy System (Time Attack)
- Every game starts with 100 energy
- Energy drains passively over time and costs 2 per swipe
- Merging tiles restores energy (flat restore + 5% of score gained)
- Hitting 0 energy ends the game immediately — manage it or die

### Combo System
- Consecutive moves that produce merges build a combo streak
- Streaks of 2+ trigger a combo banner, bonus points, and a sound effect
- Missing a merge (no tiles moved) resets the streak to zero

### Power-Ups
Earned by merging tiles that produce a value ≥ 64. Each game starts with 3 of every type (cap: 5 per type). Tap a button in the power-up bar below the board to activate.

| Power-Up | Effect |
|---|---|
| ⚡ Energy Rush | +40 energy instantly |
| ❄️ Freeze | Pauses energy drain for 15 seconds; re-tapping resets the timer |
| 🔨 Smash | Removes all tiles matching the lowest value on the board |
| 💡 Hint | Flashes the best swipe direction on the board for 1.5 seconds |

### Other Features
- **Undo** — revert up to 3 moves per game (power-up inventory is not restored)
- **Rewarded ads** — watch an ad to restore your undo count mid-game
- **Daily calendar** — tracks games played, score, and max tile per day
- **Three backgrounds** — Mountain, Sky, Grass (persisted across sessions)
- **Sound & music** — background music, swipe sounds, combo cues, and per-power-up audio
- **iPad support** — all layouts and font sizes scale via `DeviceInfo` multipliers
- **Onboarding** — contextual tutorial hints on first launch

---

## Gameplay

```
┌─────────────────────────────────┐
│  🎯 4×4   🎨  🔊  📅           │  ← Toolbar
├─────────────────────────────────┤
│  [New Game]                     │
│  ████████████░░░░  Best: 12450  │  ← Energy bar
├─────────────────────────────────┤
│  ┌────┬────┬────┬────┐          │
│  │ 🐦 │ 🐦 │    │ 🐦 │          │
│  ├────┼────┼────┼────┤          │  ← Game board
│  │    │ 🦅 │ 🐦 │    │          │
│  ├────┼────┼────┼────┤          │
│  │ 🦅 │    │ 🦜 │ 🐦 │          │
│  ├────┼────┼────┼────┤          │
│  │    │ 🐦 │    │ 🦅 │          │
│  └────┴────┴────┴────┘          │
├─────────────────────────────────┤
│  ⚡ x3  ❄️ x3  🔨 x3  💡 x3     │  ← Power-up bar
├─────────────────────────────────┤
│  [↩ Undo (3)]                   │
└─────────────────────────────────┘
```

**Swipe** in any direction — tiles slide to the edge and matching values merge. Each merge evolves the bird to its next form. Chain merges in one swipe for a combo bonus.

---

## Requirements

- iOS 16.0+
- Xcode 15+
- Swift 5.9+
- Google Mobile Ads SDK (via Swift Package Manager)

---

## Getting Started

1. Clone the repository
2. Open `birdevolution.xcodeproj` in Xcode
3. Select a simulator or device and press **Run** (⌘R)

No additional setup is required. The Google Mobile Ads SDK resolves automatically via SPM. The app uses test ad unit IDs in `DEBUG` builds.

> **Note:** New `.swift` files must be added inside Xcode (File → New → File) to be included in the compile sources target. Creating files on disk alone is not enough.

---

## Architecture

The project follows **MVVM** with SwiftUI.

```
birdevolutionGame/
├── birdEvolutionGameApp.swift   # App entry point, @StateObject injection
├── MainView.swift               # Root screen, sheet/overlay coordination
├── Models/                      # Pure data structs and game logic
│   ├── GameStats.swift          # GameState value type (Codable)
│   ├── Model.swift              # GameModel — pure move/merge logic
│   ├── PowerUp.swift            # PowerUpType enum
│   ├── PowerUpEffects.swift     # Static power-up effect implementations
│   └── ComboSystem.swift        # Combo streak tracking
├── ViewModels/
│   └── BirdEvolutionGameViewModel.swift  # All game orchestration
├── Views/                       # SwiftUI views (no business logic)
├── Services/
│   ├── AudioManager.swift       # Singleton — music and sound effects
│   ├── ThemeManager.swift       # Background theme persistence
│   ├── PersistenceManager.swift # Best score per grid size (UserDefaults)
│   └── TutorialManager.swift    # Singleton — contextual hint state
└── Utilities/
    ├── Constants.swift          # GameConstants, GridSize enum
    ├── EnergyConfig.swift       # All energy tuning values
    └── DeviceInfo.swift         # iPhone/iPad size multipliers
```

### Key Design Decisions

- **`GameState` is a value type** — the grid, score, and energy are a plain `Codable` struct. The undo system stores full copies, making rollback trivial and eliminating shared-state bugs.
- **Power-up inventory lives only on the ViewModel** — intentionally excluded from `GameState` so that undo does not restore spent power-ups.
- **`GameModel` is stateless** — `performMove` is a pure function that takes a `GameState` and returns a `MoveResult`. It can be called speculatively (e.g. for the Hint power-up) without any side effects.
- **All tuning in one place** — energy constants live exclusively in `EnergyConfig.swift`; animation/gesture constants in `GameConstants`. Nothing is inlined.

---

## Debug Menu

In `DEBUG` builds a 🐞 ladybug icon appears in the toolbar (nearly invisible by design — tap it):

| Option | Effect |
|---|---|
| Instant Win | Sets board to near-2048 state |
| Instant Game Over | Fills board with non-mergeable tiles |
| Chaos Mode (Fill) | Fills all cells with high-value tiles |
| Show Onboarding | Re-triggers the first-launch flow |

---

## License

This project is private. All rights reserved.
