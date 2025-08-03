
import Foundation


struct GameState: Equatable {
    var grid: [[Int]]
    var score: Int
    var gameOver: Bool
    var hasWon: Bool
    var maxTileValue: Int
    
    init() {
        self.grid = Array(repeating: Array(repeating: 0, count: 4), count: 4)
        self.score = 0
        self.gameOver = false
        self.hasWon = false
        self.maxTileValue = 0
    }
    
    var calculatedMaxTileValue: Int {
        return grid.flatMap { $0 }.max() ?? 0
    }
    
    var hasEmptyCells: Bool {
        return grid.contains { row in row.contains(0) }
    }
    
    var emptyCells: [Position] {
        var cells: [Position] = []
        for row in 0..<4 {
            for col in 0..<4 {
                if grid[row][col] == 0 {
                    cells.append(Position(row: row, col: col))
                }
            }
        }
        return cells
    }
}

extension GameState: Codable {}
