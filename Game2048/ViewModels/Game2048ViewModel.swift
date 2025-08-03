
import SwiftUI
import Combine

class Game2048ViewModel: ObservableObject {
    @Published var gameState: GameState
    @Published var bestScore: Int = 0
    
    private let gameModel = Game2048Model()
    private let persistenceManager = GamePersistenceManager()
    
    var grid: [[Int]] { gameState.grid }
    var score: Int { gameState.score }
    var gameOver: Bool { gameState.gameOver }
    var hasWon: Bool { gameState.hasWon }
    var maxTileValue: Int { gameState.maxTileValue }
    
    init() {
        self.gameState = GameState()
        loadBestScore()
        startNewGame()
    }
    
    func startNewGame() {
        updateBestScore()
        gameState = gameModel.createNewGame()
    }
    
    func move(_ direction: Direction) -> Set<Position> {
        let moveResult = gameModel.performMove(direction, on: gameState)
        
        guard moveResult.gridChanged else {
            return [] // НЕТ изменений - НЕТ слияний
        }
        
        gameState.grid = moveResult.newGrid
        gameState.score += moveResult.scoreGained
        gameState.maxTileValue = gameState.calculatedMaxTileValue
        
        if moveResult.hasWon && !gameState.hasWon {
            gameState.hasWon = true
        }
        
        gameState = gameModel.addRandomTile(to: gameState)
        
        if gameModel.checkGameOver(for: gameState) {
            gameState.gameOver = true
            updateBestScore()
            print(gameOver)
        }
        
        return moveResult.mergedPositions
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
}
