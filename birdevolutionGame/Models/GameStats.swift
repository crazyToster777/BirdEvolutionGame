import Foundation

struct GameState: Equatable {
    var grid: [[Int]]
    var score: Int
    var energy: Double // New Energy System
    var maxEnergy: Double
    var gameOver: Bool
    var hasWon: Bool
    var maxTileValue: Int
    let gridSize: Int
    var undosRemaining: Int
    
    init(gridSize: Int = 4) {
        self.gridSize = gridSize
        self.grid = Array(repeating: Array(repeating: 0, count: gridSize), count: gridSize)
        self.score = 0
        self.energy = EnergyConfig.startingEnergy
        self.maxEnergy = EnergyConfig.maxEnergy
        self.gameOver = false
        self.hasWon = false
        self.maxTileValue = 0
        self.undosRemaining = 3
    }
    
    var calculatedMaxTileValue: Int {
        return grid.flatMap { $0 }.max() ?? 0
    }
    
    var hasEmptyCells: Bool {
        return grid.contains { row in row.contains(0) }
    }
    
    var emptyCells: [Position] {
        var cells: [Position] = []
        for row in 0..<gridSize {
            for col in 0..<gridSize {
                if grid[row][col] == 0 {
                    cells.append(Position(row: row, col: col))
                }
            }
        }
        return cells
    }
}

extension GameState: Codable {}
