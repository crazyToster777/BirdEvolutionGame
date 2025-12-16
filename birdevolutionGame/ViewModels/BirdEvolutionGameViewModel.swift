
import SwiftUI
import Combine

class BirdEvolutionGameViewModel: ObservableObject {
    @Published var gameState: GameState
    @Published var bestScore: Int = 0
    @Published var dayStats: [String: DayStats] = [:]
    @Published var gridSize: GridSize
    
    // Combo and Power-up System
    @Published var comboCount: Int = 0
    @Published var comboBonus: Int = 0
    @Published var showComboBanner: Bool = false
    @Published var activePowerUpPositions: Set<Position> = []

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

    var grid: [[Int]] { gameState.grid }
    var score: Int { gameState.score }
    var gameOver: Bool { gameState.gameOver }
    var hasWon: Bool { gameState.hasWon }
    var maxTileValue: Int { gameState.maxTileValue }
    var canUndo: Bool { !gameStateHistory.isEmpty && gameState.undosRemaining > 0 && !gameState.gameOver }

    init() {
        // Use a local variable for gridSize's initial value
        let initialGridSize: GridSize = .small
        self.gridSize = initialGridSize
        self.gameModel = GameModel(gridSize: initialGridSize.rawValue)
        self.gameState = GameState(gridSize: initialGridSize.rawValue)
        loadBestScore()
        loadDayStats()
        loadGridSize()
        startNewGame()
    }

    func startNewGame() {
        if gameState.score > 0 || currentSessionMoves > 0 {
            recordGameSession()
        }

        updateBestScore()
        gameState = gameModel.createNewGame()
        currentSessionMoves = 0
        currentSessionStartTime = Date()

        // Reset undo state
        gameStateHistory.removeAll()
        gameState.undosRemaining = GameConstants.maxUndos
        
        // Reset combo and power-up state
        comboSystem.reset()
        updateComboUI()
        activePowerUpPositions.removeAll()
        
        // Reset Energy
        gameState.energy = EnergyConfig.startingEnergy
        gameState.maxEnergy = EnergyConfig.maxEnergy
        
        startEnergyDecay()
    }

    func move(_ direction: Direction) -> (mergedPositions: Set<Position>, newTilePositions: Set<Position>) {
        // Save current state to history before move
        saveStateToHistory()

        let moveResult = gameModel.performMove(direction, on: gameState)

        guard moveResult.gridChanged else {
            // Remove the saved state since move didn't happen
            if !gameStateHistory.isEmpty {
                gameStateHistory.removeLast()
            }
            // Reset combo on failed move
            comboSystem.reset()
            updateComboUI()
            return ([], [])
        }

        currentSessionMoves += 1
        
        // Count merges for combo system
        let mergeCount = moveResult.mergedPositions.count
        comboSystem.updateCombo(mergeCount: mergeCount)
        
        // Play combo sound if applicable
        if comboSystem.currentCombo >= 2 {
            AudioManager.shared.playComboSound(level: comboSystem.currentCombo)
        }
        
        // Apply combo bonus to score
        var totalScore = moveResult.scoreGained + comboSystem.comboBonus
        
        // Apply multiplier if active
        if gameState.activeMultiplier {
            totalScore = PowerUpEffects.applyMultiplier(to: totalScore)
            gameState.activeMultiplier = false
        }
        
        // Update Energy Logic
        // 1. Consume move cost
        gameState.energy -= EnergyConfig.moveCost
        
        // 2. Restore energy from merges
        // 2. Restore energy from merges
        if mergeCount > 0 {
            let flatRestore = Double(mergeCount) * EnergyConfig.mergeRestoration
            let scoreRestore = Double(moveResult.scoreGained) * EnergyConfig.energyPerScorePoint
            
            let totalRestore = flatRestore + scoreRestore
            
            // Bonus for combos
            let comboMultiplier = comboSystem.currentCombo > 1 ? EnergyConfig.comboBonusMultiplier : 1.0
            gameState.energy += totalRestore * comboMultiplier
        }
        
        // 3. Cap at max energy
        gameState.energy = min(gameState.energy, gameState.maxEnergy)
        
        gameState.grid = moveResult.newGrid
        gameState.score += totalScore
        gameState.maxTileValue = gameState.calculatedMaxTileValue
        
        // Check for Energy Depletion Game Over
        // Check for Energy Depletion Game Over
        if gameState.energy <= 0 {
            gameState.energy = 0
            gameState.gameOver = true
            stopEnergyDecay()
            AudioManager.shared.playPowerUpSound(type: .bomb) // Reuse sound or add game over sound
        }

        if moveResult.hasWon && !gameState.hasWon {
            gameState.hasWon = true
        }

        // Add new tile with possible power-up
        let addTileResult = gameModel.addRandomTile(to: gameState)
        gameState = addTileResult.gameState
        
        // Generate power-up based on combo
        if let newTilePosition = addTileResult.newTilePosition {
            if let powerUpType = PowerUpEffects.generatePowerUp(spawnRate: comboSystem.powerUpSpawnRate) {
                gameState.powerUpGrid[newTilePosition.row][newTilePosition.col] = powerUpType
                activePowerUpPositions.insert(newTilePosition)
            }
        }

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
        
        // Check for undo hint
        TutorialManager.shared.checkUndoHint(moveCount: currentSessionMoves, hasUsedUndo: hasUsedUndo)
        
        // Update combo UI
        updateComboUI()
        
        return (moveResult.mergedPositions, newTilePositions)
    }
    
    // MARK: - Combo System
    
    private func updateComboUI() {
        comboCount = comboSystem.currentCombo
        comboBonus = comboSystem.comboBonus
        
        // Show combo banner for 2x and above
        if comboCount >= 2 {
            showComboBanner = true
            // Auto-hide after 2 seconds
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
        
        // Restore previous state but keep the decremented undo count
        var restoredState = previousState
        restoredState.undosRemaining = gameState.undosRemaining - 1
        
        gameState = restoredState
        
        // Decrement session moves since we're undoing
        if currentSessionMoves > 0 {
            currentSessionMoves -= 1
        }
        
        // Mark that undo has been used
        hasUsedUndo = true
        TutorialManager.shared.markUndoSeen()
    }

    private func saveStateToHistory() {
        // Save current state
        gameStateHistory.append(gameState)

        // Limit history size to maxHistorySize
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
    
    // MARK: - Power-Up Activation
    
    func activatePowerUp(at position: Position) {
        guard let powerUpType = gameState.powerUpGrid[position.row][position.col] else {
            return
        }
        
        // Play sound effect
        AudioManager.shared.playPowerUpSound(type: powerUpType)
        
        switch powerUpType {
        case .bomb:
            activateBomb(at: position)
        case .rainbow:
            activateRainbow(at: position)
        case .multiplier:
            activateMultiplier()
        case .shuffle:
            activateShuffle()
        }
        
        // Remove power-up after activation
        gameState.powerUpGrid[position.row][position.col] = nil
        activePowerUpPositions.remove(position)
    }
    
    private func activateBomb(at position: Position) {
        let result = PowerUpEffects.activateBomb(at: position, grid: &gameState.grid, gridSize: gameState.gridSize)
        gameState.score += result.pointsEarned
        
        // Restore Energy from Bomb
        // Restore Energy from Bomb
        if result.pointsEarned > 0 {
            // Base energy from score
            let baseEnergy = Double(result.pointsEarned) * EnergyConfig.energyPerScorePoint
            
            // Bomb acts as a mega-charger: 3x efficiency + flat bonus
            let bombMultiplier = 3.0
            let flatBonus = 10.0 // Guaranteed chunk of energy
            
            let totalBombEnergy = (baseEnergy * bombMultiplier) + flatBonus
            
            gameState.energy += totalBombEnergy
            gameState.energy = min(gameState.energy, gameState.maxEnergy)
        }
        
        gameState.maxTileValue = gameState.calculatedMaxTileValue
    }
    
    private func activateRainbow(at position: Position) {
        if let targetPosition = PowerUpEffects.activateRainbow(at: position, grid: &gameState.grid, gridSize: gameState.gridSize) {
            // Merge rainbow tile with target
            // Rainbow behaves like a Joker: it mimics the target tile to upgrade it
            let targetValue = gameState.grid[targetPosition.row][targetPosition.col]
            let mergedValue = targetValue * 2
            
            gameState.grid[targetPosition.row][targetPosition.col] = mergedValue
            gameState.grid[position.row][position.col] = 0
            gameState.score += mergedValue
            gameState.maxTileValue = gameState.calculatedMaxTileValue
        }
    }
    
    private func activateMultiplier() {
        // Set flag for next merge to be doubled
        gameState.activeMultiplier = true
    }
    
    private func activateShuffle() {
        // Fix for "Inout writeback" error: copy properties to local vars
        var grid = gameState.grid
        var powerUpGrid = gameState.powerUpGrid
        
        // Pass local copies
        PowerUpEffects.activateShuffle(grid: &grid, powerUpGrid: &powerUpGrid, gridSize: gameState.gridSize)
        
        // Assign back to gameState
        gameState.grid = grid
        gameState.powerUpGrid = powerUpGrid
        
        // Rebuild active positions cache because tiles moved
        activePowerUpPositions.removeAll()
        for r in 0..<gameState.gridSize {
            for c in 0..<gameState.gridSize {
                if gameState.powerUpGrid[r][c] != nil {
                    activePowerUpPositions.insert(Position(row: r, col: c))
                }
            }
        }
        
        gameState.maxTileValue = gameState.calculatedMaxTileValue
    }
    
    // MARK: - Time Attack Logic
    
    private func startEnergyDecay() {
        stopEnergyDecay() // Ensure previous timer is invalidated
        
        gameTimer = Timer.scheduledTimer(withTimeInterval: EnergyConfig.decayInterval, repeats: true) { [weak self] _ in
            guard let self = self else { return }
            guard !self.gameState.gameOver && !self.gameState.hasWon else {
                self.stopEnergyDecay()
                return
            }
            
            // Apply decay based on elapsed time (interval * rate)
            let decayAmount = EnergyConfig.decayInterval * EnergyConfig.timeDecayRate
            self.gameState.energy -= decayAmount
            
            // Check for game over
            if self.gameState.energy <= 0 {
                self.gameState.energy = 0
                self.gameState.gameOver = true
                self.stopEnergyDecay()
                AudioManager.shared.playPowerUpSound(type: .bomb)
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
        // Clear existing powerups first to avoid stale state
        for r in 0..<gameState.gridSize {
            for c in 0..<gameState.gridSize {
                gameState.powerUpGrid[r][c] = nil
            }
        }
        activePowerUpPositions.removeAll()

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
        // Create a grid with 2048 tile for testing win screen
        var testGrid = Array(repeating: Array(repeating: 0, count: gameState.gridSize), count: gameState.gridSize)
        
        // Add 2048 tile in center
        let center = gameState.gridSize / 2
        testGrid[center][center] = 2048
        
        // Add some other tiles around it
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
        // Fill grid with non-mergeable tiles for testing game over
        var testGrid = Array(repeating: Array(repeating: 0, count: gameState.gridSize), count: gameState.gridSize)
        
        for row in 0..<gameState.gridSize {
            for col in 0..<gameState.gridSize {
                // Alternate between 2 and 4 to make grid full but not mergeable
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

        // Save current game session if in progress
        if gameState.score > 0 || currentSessionMoves > 0 {
            recordGameSession()
        }

        // Update grid size
        gridSize = newSize
        saveGridSize()

        // Recreate game model with new size
        gameModel = GameModel(gridSize: newSize.rawValue)

        // Load best score for new grid size
        loadBestScore()

        // Start new game with new grid size
        gameState = gameModel.createNewGame()
        currentSessionMoves = 0
        currentSessionStartTime = Date()

        // Clear undo history
        gameStateHistory.removeAll()
        gameState.undosRemaining = GameConstants.maxUndos
        
        // Mark grid size hint as seen
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

