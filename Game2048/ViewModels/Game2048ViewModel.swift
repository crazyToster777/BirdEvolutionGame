
import SwiftUI
import Combine

class Game2048ViewModel: ObservableObject {
    @Published var gameState: GameState
    @Published var bestScore: Int = 0
    @Published var dayStats: [String: DayStats] = [:]
    
    private let gameModel = Game2048Model()
    private let persistenceManager = GamePersistenceManager()
    private var currentSessionMoves: Int = 0
    private var currentSessionStartTime: Date = Date()
    
    var grid: [[Int]] { gameState.grid }
    var score: Int { gameState.score }
    var gameOver: Bool { gameState.gameOver }
    var hasWon: Bool { gameState.hasWon }
    var maxTileValue: Int { gameState.maxTileValue }
    
    init() {
        self.gameState = GameState()
        loadBestScore()
        loadDayStats()
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
    }
    
    func move(_ direction: Direction) -> (mergedPositions: Set<Position>, newTilePositions: Set<Position>) {
        let moveResult = gameModel.performMove(direction, on: gameState)
        
        guard moveResult.gridChanged else {
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
            print(gameOver)
        }
        
        return (moveResult.mergedPositions, newTilePositions)
    }
    
    func resetGame() {
        startNewGame()
    }
    
    private func loadBestScore() {
        bestScore = persistenceManager.loadBestScore()
    }
    
    private func updateBestScore() {
        if gameState.score > bestScore {
            bestScore = gameState.score
            persistenceManager.saveBestScore(bestScore)
        }
    }
    
    // MARK: TEST
    func fillAllCellsRandom() {
        let possibleValues = [2, 4, 8, 16, 32, 64, 128, 256, 512, 1024]
        
        for row in 0..<4 {
            for col in 0..<4 {
                gameState.grid[row][col] = possibleValues.randomElement() ?? 2
            }
        }
        
        updateGameStateAfterTest()
        
        func updateGameStateAfterTest() {
               gameState.maxTileValue = gameState.calculatedMaxTileValue
               
               // Проверяем состояние игры
               if gameState.calculatedMaxTileValue >= 2048 && !gameState.hasWon {
                   gameState.hasWon = true
               }
               
               // Проверяем Game Over только если сетка полная
               if !gameState.hasEmptyCells {
                   gameState.gameOver = gameModel.checkGameOver(for: gameState)
               } else {
                   gameState.gameOver = false
               }
           }
    }
    
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
            totalMoves: currentSessionMoves
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
        if let data = UserDefaults.standard.data(forKey: "dayStats"),
           let decoded = try? JSONDecoder().decode([String: DayStats].self, from: data) {
            dayStats = decoded
        }
    }
    
    private func saveDayStats() {
        if let encoded = try? JSONEncoder().encode(dayStats) {
            UserDefaults.standard.set(encoded, forKey: "dayStats")
        }
    }
}
