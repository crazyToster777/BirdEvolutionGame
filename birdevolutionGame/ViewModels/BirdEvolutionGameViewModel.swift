
import SwiftUI
import Combine
import AudioToolbox

class BirdEvolutionGameViewModel: ObservableObject {
    @Published var gameState: GameState
    @Published var bestScore: Int = 0
    @Published var dayStats: [String: DayStats] = [:]
    @Published var gridSize: GridSize

    // Combo System
    @Published var comboCount: Int = 0
    @Published var comboBonus: Int = 0
    @Published var showComboBanner: Bool = false

    // Power-up inventory (lives in ViewModel only — undo does not restore spent power-ups)
    @Published var powerUpInventory: [PowerUpType: Int] = [:]
    @Published var isEnergyFrozen: Bool = false
    @Published var hintDirection: Direction? = nil

    private var gameModel: GameModel
    private let persistenceManager = GamePersistenceManager()
    private var comboSystem = ComboSystem()
    private var currentSessionMoves: Int = 0
    private var currentSessionStartTime: Date = Date()
    private var gameStateHistory: [GameState] = []
    private let maxHistorySize = GameConstants.maxUndos
    private var hasUsedUndo: Bool = false
    private var gamesCompleted: Int = 0
    private var gameTimer: Timer?
    private var freezeTimer: DispatchWorkItem? = nil

    var grid: [[Int]] { gameState.grid }
    var score: Int { gameState.score }
    var gameOver: Bool { gameState.gameOver }
    var hasWon: Bool { gameState.hasWon }
    var maxTileValue: Int { gameState.maxTileValue }
    var canUndo: Bool { gameState.undosRemaining > 0 }

    init() {
        let initialGridSize: GridSize = .small
        self.gridSize = initialGridSize
        self.gameModel = GameModel(gridSize: initialGridSize.rawValue)
        self.gameState = GameState(gridSize: initialGridSize.rawValue)
        loadBestScore()
        loadDayStats()
        loadGridSize()
        startNewGame()
    }

    func grantUndo() {
        gameState.undosRemaining = GameConstants.maxUndos
    }

    func grantPowerUp(_ type: PowerUpType) {
        powerUpInventory[type] = 3
    }

    func startNewGame() {
        if gameState.score > 0 || currentSessionMoves > 0 {
            recordGameSession()
        }

        updateBestScore()
        gameState = gameModel.createNewGame()
        currentSessionMoves = 0
        currentSessionStartTime = Date()

        gameStateHistory.removeAll()
        gameState.undosRemaining = GameConstants.maxUndos

        comboSystem.reset()
        updateComboUI()

        // Reset power-up state — start each game with 3 of every type
        powerUpInventory = Dictionary(uniqueKeysWithValues: PowerUpType.allCases.map { ($0, 3) })
        freezeTimer?.cancel()
        freezeTimer = nil
        isEnergyFrozen = false
        hintDirection = nil

        gameState.energy = EnergyConfig.startingEnergy
        gameState.maxEnergy = EnergyConfig.maxEnergy

        startEnergyDecay()
    }

    func move(_ direction: Direction) -> (mergedPositions: Set<Position>, newTilePositions: Set<Position>) {
        saveStateToHistory()

        let moveResult = gameModel.performMove(direction, on: gameState)

        guard moveResult.gridChanged else {
            if !gameStateHistory.isEmpty {
                gameStateHistory.removeLast()
            }
            comboSystem.reset()
            updateComboUI()
            return ([], [])
        }

        if isEnergyFrozen {
            isEnergyFrozen = false
            freezeTimer?.cancel()
            freezeTimer = nil
        }

        currentSessionMoves += 1

        let mergeCount = moveResult.mergedPositions.count
        comboSystem.updateCombo(mergeCount: mergeCount)

        if comboSystem.currentCombo >= 2 {
            AudioManager.shared.playComboSound(level: comboSystem.currentCombo)
        }

        let totalScore = moveResult.scoreGained + comboSystem.comboBonus

        // Update Energy
        gameState.energy -= EnergyConfig.moveCost

        if mergeCount > 0 {
            let flatRestore = Double(mergeCount) * EnergyConfig.mergeRestoration
            let scoreRestore = Double(moveResult.scoreGained) * EnergyConfig.energyPerScorePoint
            let totalRestore = flatRestore + scoreRestore
            let comboMultiplier = comboSystem.currentCombo > 1 ? EnergyConfig.comboBonusMultiplier : 1.0
            gameState.energy += totalRestore * comboMultiplier
        }

        gameState.energy = min(gameState.energy, gameState.maxEnergy)

        gameState.grid = moveResult.newGrid
        gameState.score += totalScore
        gameState.maxTileValue = gameState.calculatedMaxTileValue

        // Award power-up if a merge produced a tile >= 64
        awardPowerUpIfEarned(mergedPositions: moveResult.mergedPositions)

        // Check for energy depletion game over
        if gameState.energy <= 0 {
            gameState.energy = 0
            gameState.gameOver = true
            stopEnergyDecay()
            AudioServicesPlaySystemSound(1005)
        }

        if moveResult.hasWon && !gameState.hasWon {
            gameState.hasWon = true
        }

        let addTileResult = gameModel.addRandomTile(to: gameState)
        gameState = addTileResult.gameState

        var newTilePositions: Set<Position> = []
        if let newTilePosition = addTileResult.newTilePosition {
            newTilePositions.insert(newTilePosition)
        }

        if gameModel.checkGameOver(for: gameState) {
            gameState.gameOver = true
            stopEnergyDecay()
            updateBestScore()
            recordGameSession()
            gamesCompleted += 1
            TutorialManager.shared.checkGridSizeHint(gamesCompleted: gamesCompleted)
        }

        TutorialManager.shared.checkUndoHint(moveCount: currentSessionMoves, hasUsedUndo: hasUsedUndo)
        updateComboUI()

        return (moveResult.mergedPositions, newTilePositions)
    }

    // MARK: - Power-Up Activation

    func activatePowerUp(_ type: PowerUpType) {
        guard (powerUpInventory[type] ?? 0) > 0, !gameState.gameOver, !gameState.hasWon else { return }
        powerUpInventory[type] = (powerUpInventory[type] ?? 1) - 1
        AudioManager.shared.playPowerUpSound(type: type)
        switch type {
        case .energyRush:
            gameState.energy = PowerUpEffects.applyEnergyRush(to: gameState.energy, max: gameState.maxEnergy)
        case .freeze:
            isEnergyFrozen = true
            freezeTimer?.cancel()
            let work = DispatchWorkItem { [weak self] in self?.isEnergyFrozen = false }
            freezeTimer = work
            DispatchQueue.main.asyncAfter(deadline: .now() + EnergyConfig.freezeDuration, execute: work)
        case .smash:
            PowerUpEffects.applySmash(to: &gameState.grid, gridSize: gameState.gridSize)
            gameState.maxTileValue = gameState.calculatedMaxTileValue
            if gameState.grid.allSatisfy({ $0.allSatisfy { $0 == 0 } }) {
                let result = gameModel.addRandomTile(to: gameState)
                gameState = result.gameState
            }
        case .hint:
            hintDirection = PowerUpEffects.computeBestHintDirection(
                grid: gameState.grid, gridSize: gameState.gridSize, model: gameModel)
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) { [weak self] in self?.hintDirection = nil }
        }
    }

    private func awardPowerUpIfEarned(mergedPositions: Set<Position>) {
        for position in mergedPositions {
            let tileValue = gameState.grid[position.row][position.col]
            if tileValue >= 64, let randomType = PowerUpType.allCases.randomElement() {
                let current = powerUpInventory[randomType, default: 0]
                if current < 5 { powerUpInventory[randomType] = current + 1 }
            }
        }
    }

    // MARK: - Combo System

    private func updateComboUI() {
        comboCount = comboSystem.currentCombo
        comboBonus = comboSystem.comboBonus

        if comboCount >= 2 {
            showComboBanner = true
            DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
                self.showComboBanner = false
            }
        } else {
            showComboBanner = false
        }
    }

    func resetGame() {
        startNewGame()
    }

    // MARK: - Undo Functionality

    func undo() {
        guard canUndo else { return }
        guard let previousState = gameStateHistory.popLast() else { return }

        var restoredState = previousState
        restoredState.undosRemaining = gameState.undosRemaining - 1

        gameState = restoredState

        if currentSessionMoves > 0 {
            currentSessionMoves -= 1
        }

        hasUsedUndo = true
        TutorialManager.shared.markUndoSeen()
    }

    private func saveStateToHistory() {
        gameStateHistory.append(gameState)
        if gameStateHistory.count > maxHistorySize {
            gameStateHistory.removeFirst()
        }
    }

    private func loadBestScore() {
        bestScore = persistenceManager.loadBestScore(for: gridSize.rawValue)
    }

    private func updateBestScore() {
        if gameState.score > bestScore {
            bestScore = gameState.score
            persistenceManager.saveBestScore(bestScore, for: gridSize.rawValue)
        }
    }

    // MARK: - Time Attack Logic

    private func startEnergyDecay() {
        stopEnergyDecay()

        gameTimer = Timer.scheduledTimer(withTimeInterval: EnergyConfig.decayInterval, repeats: true) { [weak self] _ in
            guard let self = self else { return }
            guard !self.gameState.gameOver && !self.gameState.hasWon else {
                self.stopEnergyDecay()
                return
            }
            guard !self.isEnergyFrozen else { return }

            let decayAmount = EnergyConfig.decayInterval * EnergyConfig.timeDecayRate
            self.gameState.energy -= decayAmount

            if self.gameState.energy <= 0 {
                self.gameState.energy = 0
                self.gameState.gameOver = true
                self.stopEnergyDecay()
                AudioServicesPlaySystemSound(1005)
            }
        }
    }

    private func stopEnergyDecay() {
        gameTimer?.invalidate()
        gameTimer = nil
    }

    // MARK: - App Lifecycle Management

    func pauseGame() {
        stopEnergyDecay()
    }

    func resumeGame() {
        if !gameState.gameOver && !gameState.hasWon {
            startEnergyDecay()
        }
    }

    // MARK: - Debug/Test Functions
    #if DEBUG
    func fillAllCellsRandom() {
        let tiles = [16384, 8192, 4096, 2048, 1024, 512, 256, 128, 64, 32, 16, 8, 4, 2]
        var index = 0
        for row in 0..<gameState.gridSize {
            for col in 0..<gameState.gridSize {
                gameState.grid[row][col] = tiles[index % tiles.count]
                index += 1
            }
        }
        gameState.maxTileValue = gameState.calculatedMaxTileValue
    }

    func testWinScreen() {
        var testGrid = Array(repeating: Array(repeating: 0, count: gameState.gridSize), count: gameState.gridSize)
        let center = gameState.gridSize / 2
        testGrid[center][center] = 2048
        testGrid[0][0] = 2
        testGrid[0][1] = 4
        testGrid[1][0] = 8
        testGrid[1][1] = 16
        gameState.grid = testGrid
        gameState.maxTileValue = 2048
        gameState.hasWon = true
        gameState.score = 12345
        gameState.gameOver = false
    }

    func testGameOver() {
        var testGrid = Array(repeating: Array(repeating: 0, count: gameState.gridSize), count: gameState.gridSize)
        for row in 0..<gameState.gridSize {
            for col in 0..<gameState.gridSize {
                testGrid[row][col] = (row + col) % 2 == 0 ? 2 : 4
            }
        }
        gameState.grid = testGrid
        gameState.gameOver = true
        gameState.score = 5678
    }
    #endif

    // MARK: - Calendar/Session Tracking

    func getDayStats(for date: Date) -> DayStats? {
        let dayKey = createDayKey(from: date)
        return dayStats[dayKey]
    }

    private func recordGameSession() {
        let session = GameSession(
            date: currentSessionStartTime,
            score: gameState.score,
            maxTile: gameState.maxTileValue,
            gamesPlayed: 1,
            totalMoves: currentSessionMoves,
            gridSize: gridSize.rawValue
        )

        let dayKey = session.dayKey

        if var existingStats = dayStats[dayKey] {
            existingStats.addSession(session)
            dayStats[dayKey] = existingStats
        } else {
            var newStats = DayStats(date: session.date)
            newStats.addSession(session)
            dayStats[dayKey] = newStats
        }

        saveDayStats()
    }

    private func createDayKey(from date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter.string(from: date)
    }

    private func loadDayStats() {
        if let data = UserDefaults.standard.data(forKey: GameConstants.dayStatsKey),
           let decoded = try? JSONDecoder().decode([String: DayStats].self, from: data) {
            dayStats = decoded
        }
    }

    private func saveDayStats() {
        if let encoded = try? JSONEncoder().encode(dayStats) {
            UserDefaults.standard.set(encoded, forKey: GameConstants.dayStatsKey)
        }
    }

    // MARK: - Grid Size Management

    func changeGridSize(to newSize: GridSize) {
        guard newSize != gridSize else { return }

        if gameState.score > 0 || currentSessionMoves > 0 {
            recordGameSession()
        }

        gridSize = newSize
        saveGridSize()
        gameModel = GameModel(gridSize: newSize.rawValue)
        loadBestScore()

        gameState = gameModel.createNewGame()
        currentSessionMoves = 0
        currentSessionStartTime = Date()

        gameStateHistory.removeAll()
        gameState.undosRemaining = GameConstants.maxUndos

        // Reset power-up state — start each game with 3 of every type
        powerUpInventory = Dictionary(uniqueKeysWithValues: PowerUpType.allCases.map { ($0, 3) })
        freezeTimer?.cancel()
        freezeTimer = nil
        isEnergyFrozen = false
        hintDirection = nil

        startEnergyDecay()
        TutorialManager.shared.markGridSizeSeen()
    }

    private func loadGridSize() {
        if let savedSize = UserDefaults.standard.value(forKey: "selectedGridSize") as? Int,
           let size = GridSize(rawValue: savedSize) {
            gridSize = size
            gameModel = GameModel(gridSize: size.rawValue)
        }
    }

    private func saveGridSize() {
        UserDefaults.standard.set(gridSize.rawValue, forKey: "selectedGridSize")
    }
}
