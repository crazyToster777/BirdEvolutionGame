
import Foundation


class Game2048Model {
    private let gridSize = 4
    
    func createNewGame() -> GameState {
        var gameState = GameState()
        let result1 = addRandomTile(to: gameState)
        gameState = result1.gameState
        let result2 = addRandomTile(to: gameState)
        gameState = result2.gameState
        return gameState
    }
    
    func addRandomTile(to gameState: GameState) -> (gameState: GameState, newTilePosition: Position?) {
        let emptyCells = gameState.emptyCells
        guard !emptyCells.isEmpty else { return (gameState, nil) }
        
        let randomCell = emptyCells.randomElement()!
        let value = Int.random(in: 1...10) == 1 ? 4 : 2
        
        var newGameState = gameState
        newGameState.grid[randomCell.row][randomCell.col] = value
        newGameState.maxTileValue = newGameState.calculatedMaxTileValue
        
        return (newGameState, randomCell)
    }
    
    func performMove(_ direction: Direction, on gameState: GameState) -> MoveResult {
        guard !gameState.gameOver else {
            return MoveResult(newGrid: gameState.grid, scoreGained: 0, hasWon: false, gridChanged: false, mergedPositions: [], newTilePositions: [])
        }
        
        let result = moveGrid(gameState.grid, in: direction)
        
        return MoveResult(
            newGrid: result.grid,
            scoreGained: result.scoreGained,
            hasWon: result.hasWon,
            gridChanged: !gridsAreEqual(gameState.grid, result.grid),
            mergedPositions: result.mergedPositions,
            newTilePositions: []
        )
    }
    
    func checkGameOver(for gameState: GameState) -> Bool {
        return !gameState.hasEmptyCells && !canMove(gameState.grid)
    }
    
    // MARK: - Private Methods
    
    private func moveGrid(_ grid: [[Int]], in direction: Direction) -> (grid: [[Int]], scoreGained: Int, hasWon: Bool, mergedPositions: Set<Position>) {
        var newGrid = grid
        var totalScore = 0
        var hasWon = false
        var allMergedPositions: Set<Position> = []
        
        switch direction {
        case .left:
            for row in 0..<gridSize {
                let result = compressRowWithMerges(newGrid[row], rowIndex: row, direction: .left)
                newGrid[row] = result.row
                totalScore += result.scoreGained
                if result.hasWon { hasWon = true }
                allMergedPositions.formUnion(result.mergedPositions)
            }
            
        case .right:
            for row in 0..<gridSize {
                let reversed = Array(newGrid[row].reversed())
                let result = compressRowWithMerges(reversed, rowIndex: row, direction: .right)
                newGrid[row] = Array(result.row.reversed())
                totalScore += result.scoreGained
                if result.hasWon { hasWon = true }
                allMergedPositions.formUnion(result.mergedPositions)
            }
            
        case .up:
            for col in 0..<gridSize {
                let column = (0..<gridSize).map { newGrid[$0][col] }
                let result = compressColumnWithMerges(column, colIndex: col, direction: .up)
                for (rowIndex, value) in result.row.enumerated() {
                    newGrid[rowIndex][col] = value
                }
                totalScore += result.scoreGained
                if result.hasWon { hasWon = true }
                allMergedPositions.formUnion(result.mergedPositions)
            }
            
        case .down:
            for col in 0..<gridSize {
                let column = (0..<gridSize).map { newGrid[$0][col] }
                let reversed = Array(column.reversed())
                let result = compressColumnWithMerges(reversed, colIndex: col, direction: .down)
                let finalColumn = Array(result.row.reversed())
                for (rowIndex, value) in finalColumn.enumerated() {
                    newGrid[rowIndex][col] = value
                }
                totalScore += result.scoreGained
                if result.hasWon { hasWon = true }
                allMergedPositions.formUnion(result.mergedPositions)
            }
        }
        
        return (newGrid, totalScore, hasWon, allMergedPositions)
    }
    
    private func compressRowWithMerges(_ row: [Int], rowIndex: Int, direction: Direction) -> (row: [Int], scoreGained: Int, hasWon: Bool, mergedPositions: Set<Position>) {
        var newRow = row.filter { $0 != 0 }
        var scoreGained = 0
        var hasWon = false
        var mergedPositions: Set<Position> = []
        
        var i = 0
        while i < newRow.count - 1 {
            if newRow[i] == newRow[i + 1] {
                newRow[i] *= 2
                scoreGained += newRow[i]
                newRow.remove(at: i + 1)
                
                let colIndex: Int
                if direction == .left {
                    colIndex = i
                } else { // .right
                    colIndex = gridSize - 1 - i
                }
                
                mergedPositions.insert(Position(row: rowIndex, col: colIndex))
                
                if newRow[i] == 2048 {
                    hasWon = true
                }
            }
            i += 1
        }
        
        while newRow.count < gridSize {
            newRow.append(0)
        }
        
        return (newRow, scoreGained, hasWon, mergedPositions)
    }
    
    private func compressColumnWithMerges(_ column: [Int], colIndex: Int, direction: Direction) -> (row: [Int], scoreGained: Int, hasWon: Bool, mergedPositions: Set<Position>) {
        var newColumn = column.filter { $0 != 0 }
        var scoreGained = 0
        var hasWon = false
        var mergedPositions: Set<Position> = []
        
        var i = 0
        while i < newColumn.count - 1 {
            if newColumn[i] == newColumn[i + 1] {
                newColumn[i] *= 2
                scoreGained += newColumn[i]
                newColumn.remove(at: i + 1)
                
                let rowIndex: Int
                if direction == .up {
                    rowIndex = i
                } else { // .down
                    rowIndex = gridSize - 1 - i
                }
                
                mergedPositions.insert(Position(row: rowIndex, col: colIndex))
                
                if newColumn[i] == 2048 {
                    hasWon = true
                }
            }
            i += 1
        }
        
        while newColumn.count < gridSize {
            newColumn.append(0)
        }
        
        return (newColumn, scoreGained, hasWon, mergedPositions)
    }
    
    private func canMove(_ grid: [[Int]]) -> Bool {
        for row in 0..<gridSize {
            for col in 0..<(gridSize - 1) {
                if grid[row][col] == grid[row][col + 1] {
                    return true
                }
            }
        }
        
        for row in 0..<(gridSize - 1) {
            for col in 0..<gridSize {
                if grid[row][col] == grid[row + 1][col] {
                    return true
                }
            }
        }
        
        return false
    }
    
    private func gridsAreEqual(_ grid1: [[Int]], _ grid2: [[Int]]) -> Bool {
        for row in 0..<gridSize {
            for col in 0..<gridSize {
                if grid1[row][col] != grid2[row][col] {
                    return false
                }
            }
        }
        return true
    }
}
