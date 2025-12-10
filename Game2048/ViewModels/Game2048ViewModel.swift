
import SwiftUI
import Combine

class Game2048ViewModel: ObservableObject {
    @Published var gameState: GameState
    @Published var bestScore: Int = 0
    @Published var dayStats: [String: DayStats] = [:]
    @Published var gridSize: GridSize

    private var gameModel: Game2048Model
    private let persistenceManager = GamePersistenceManager()
    private var currentSessionMoves: Int = 0
    private var currentSessionStartTime: Date = Date()
    private var gameStateHistory: [GameState] = []
    private let maxHistorySize = GameConstants.maxUndos
    private var hasUsedUndo: Bool = false
    private var gamesCompleted: Int = 0

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
        self.gameModel = Game2048Model(gridSize: initialGridSize.rawValue)
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
            return ([], []) // НЕТ изменений - НЕТ слияний
        }

        currentSessionMoves += 1
        gameState.grid = moveResult.newGrid
        gameState.score += moveResult.scoreGained
        gameState.maxTileValue = gameState.calculatedMaxTileValue

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
            updateBestScore()
            recordGameSession()
            gamesCompleted += 1
            TutorialManager.shared.checkGridSizeHint(gamesCompleted: gamesCompleted)
        }
        
        // Check for undo hint
        TutorialManager.shared.checkUndoHint(moveCount: currentSessionMoves, hasUsedUndo: hasUsedUndo)
        
        return (moveResult.mergedPositions, newTilePositions)
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

    // MARK: - Debug/Test Functions
    #if DEBUG
    func fillAllCellsRandom() {
        for row in 0..<gameState.gridSize {
            for col in 0..<gameState.gridSize {
                gameState.grid[row][col] = [2, 4, 8, 16, 32, 64, 128, 256, 512, 1024].randomElement() ?? 2
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
        gameModel = Game2048Model(gridSize: newSize.rawValue)

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
            gameModel = Game2048Model(gridSize: size.rawValue)
        }
    }

    private func saveGridSize() {
        UserDefaults.standard.set(gridSize.rawValue, forKey: "selectedGridSize")
    }
}

