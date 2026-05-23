# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

**BirdEvolution** is an iOS SwiftUI game — a 2048-style tile-merging puzzle with a bird evolution theme. Core mechanics: energy/time-attack system, combo multipliers, consumable power-ups, and a daily play calendar.

- Platform: iOS (SwiftUI), Google Mobile Ads integrated
- Language: Swift
- Architecture: MVVM
- Entry point: `birdEvolutionGameApp.swift` → `newgameApp` struct → `AppDelegate` (inits MobileAds)

---

## Build & Run

There are no test targets or scripts. Build and run exclusively through **Xcode**:
- Open `../birdevolution.xcodeproj`
- Select an iOS simulator or device and hit Run
- All debug utilities are behind `#if DEBUG` guards; accessible via the ladybug toolbar menu at runtime

---

## Architecture

### Pattern: MVVM

| Layer | Role |
|---|---|
| `Models/` | Pure data structs and game logic — no side effects |
| `ViewModels/` | `ObservableObject` classes bridging model to view |
| `Views/` | SwiftUI views — no business logic |
| `Services/` | Singletons: audio, persistence, tutorial, ads |
| `Utilities/` | Constants, config, device helpers |

### Environment Object Chain

Injected at app root in `birdEvolutionGameApp.swift`:
- `BirdEvolutionGameViewModel` — central game state (accessed as `game`)
- `AudioManager` — sound/music
- `ThemeManager` — background theme

### Key Files

**Models**
- `Models/GameStats.swift` — `GameState` struct (grid, score, energy, hasWon, gameOver, undosRemaining). Value type, `Codable`. No power-up state.
- `Models/Model.swift` — `GameModel` class. Pure grid logic: move, merge, add tile, check game over.
- `Models/PowerUp.swift` — `PowerUpType` enum: `energyRush`, `freeze`, `smash`, `hint` with emoji raw values.
- `Models/PowerUpEffects.swift` — Static methods for each power-up effect.
- `Models/ComboSystem.swift` — Tracks consecutive merges, computes combo bonus.
- `Models/MoveResults.swift` — `MoveResult` struct returned by `GameModel.performMove`.

**ViewModel**
- `ViewModels/BirdEvolutionGameViewModel.swift` — All game orchestration: moves, undo, power-up activation, energy decay timer, combo UI, best score, session recording, grid size management.

**Views**
- `MainView.swift` — Root screen: `NavigationView` with toolbar, sheets, overlays. Delegates layout to section views.
- `Views/MainBoardSection.swift` — ZStack wrapping `MergeRotationGameBoardView` + combo banner overlay.
- `Views/MainHeaderSection.swift` — `NewGameButton` + `EnergyHeaderView`, width-matched to board.
- `Views/MainToolbarItems.swift` — `GridSizeToolbarButton`, `ThemeMenuButton`, `SoundToggleButton`, `CalendarToolbarButton`.
- `Views/MainPreferenceKeys.swift` — `BoardWidthPreferenceKey`, `BoardAnchorKey`, `GridSizeButtonFrameKey`.
- `Views/GameBoardView.swift` — `MergeRotationGameBoardView`: drag gesture handling, tile animation triggers, hint arrow overlay.
- `Views/TileView.swift` — Individual tile rendering with rotation/scale animations.
- `Views/PowerUpBarView.swift` — `HStack` of `PowerUpBarItemView` buttons, one per `PowerUpType`.
- `Views/PowerUpIndicatorView.swift` — Contains `PowerUpBarItemView`: emoji + name + count badge, `.ultraThinMaterial` background.

**Services**
- `Services/AudioManager.swift` — Singleton (`AudioManager.shared`). Background music starts on first swipe. `playPowerUpSound(type:)` handles all 4 power-up types.
- `Services/PersistenceManager.swift` — Best score per grid size via UserDefaults.
- `Services/TutorialManager.swift` — Singleton (`TutorialManager.shared`). Contextual hints on first move, undo prompt, grid size suggestion.
- `ViewModels/RewardedAdManager.swift` — Handles Google rewarded ads (grants undo via `game.grantUndo()`).

**Utilities**
- `Utilities/Constants.swift` — `GameConstants` (UserDefaults keys, animation durations, gesture thresholds, `maxUndos=3`). `GridSize` enum (small=4, medium=5, large=6).
- `Utilities/EnergyConfig.swift` — All energy tuning values. Edit here only, never inline.
- `Utilities/DeviceInfo.swift` — `DeviceInfo` struct: `sizeMultiplier`, `spacingMultiplier`, `paddingMultiplier` for iPhone/iPad scaling.

---

## Core Game Mechanics

### Move Flow (`BirdEvolutionGameViewModel.move(_:)`)
1. Save `GameState` copy to undo history.
2. Call `GameModel.performMove` → `MoveResult`.
3. If grid unchanged: revert history, reset combo, return early.
4. Update combo system; play combo sound if combo ≥ 2.
5. Apply energy delta: subtract `moveCost`, restore based on merge count + score points + combo multiplier.
6. Write new grid/score/maxTileValue to `gameState`.
7. Call `awardPowerUpIfEarned(mergedPositions:)` — merges that produce ≥ 64 tile grant 1 random power-up (cap 5 per type).
8. Check energy depletion game over.
9. Check win (tile == 2048).
10. Add random tile; check board-full game over.
11. Update tutorial hints.

### Energy System
- Starts at 100, max 100. Decays over time (timer every 0.5s, rate 0.8/s).
- Each swipe costs 2 energy; each merge restores 3 + 5% of score gained; combo multiplies restoration by 1.5×.
- Energy depletion = immediate game over.
- Freeze power-up: sets `isEnergyFrozen = true`; decay timer skips when frozen.
- All values in `EnergyConfig.swift`.

### Power-Ups
Consumable inventory — tap buttons in `PowerUpBarView` below the puzzle. Inventory lives **only on the ViewModel**; undo does not restore spent power-ups.

**Earning:** Merge that produces a tile ≥ 64 → +1 random power-up (max 5 per type). Game starts with 3 of each.

| Type | Effect |
|---|---|
| Energy Rush ⚡ | +40 energy (capped at max) |
| Freeze ❄️ | Pause time-decay 15s; re-tapping resets the timer |
| Smash 🔨 | Zeros all cells matching the minimum non-zero value on the board |
| Hint 💡 | Flashes best swipe-direction arrow on board for 1.5s |

### Undo
- Max 3 undos per game (`GameConstants.maxUndos`). Stores full `GameState` copies.
- `canUndo`: `gameState.undosRemaining > 0` (power-up inventory is NOT restored).

---

## Data Persistence (UserDefaults)
- Best score per grid size: `"bestScore_<gridSize>"` via `GamePersistenceManager`
- Daily stats: `"dayStats"` (JSON-encoded `[String: DayStats]`)
- Selected grid size: `"selectedGridSize"`
- Background theme: `"appBackground"`

---

## Conventions

- **No logic in Views** — views call ViewModel methods and bind to `@Published` properties only.
- **`GameState` is a value type** — always copy-on-write; never mutate through references.
- **`powerUpInventory` never in `GameState`** — intentional: keeps `GameState` `Codable` and ensures undo doesn't restore power-ups.
- **Singletons** — `AudioManager.shared` and `TutorialManager.shared`; do not instantiate new ones.
- **Device scaling** — always use `DeviceInfo.sizeMultiplier` / `spacingMultiplier` / `paddingMultiplier` for layout values; never hardcode `CGFloat`.
- **Energy tuning** — `EnergyConfig.swift` only.
- **Animation/gesture constants** — `GameConstants` only.
- **Win tile value** — hardcoded as `2048` in `Model.swift` `compressRowWithMerges` and `compressColumnWithMerges`; update both if changing.
- **New grid size** — add a case to `GridSize` in `Constants.swift` with `tileSize`, `spacing`, `displayName`, and `emoji`.
- **New files** must be added inside Xcode to compile sources target — creating a `.swift` file on disk alone is not enough.
- **Grid indexing** — `grid[row][col]`, row-major. Use `Position(row:col:)` for all coordinates.
