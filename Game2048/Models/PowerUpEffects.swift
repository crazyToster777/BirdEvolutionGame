import Foundation

/// Handles power-up effect implementations
class PowerUpEffects {
    
    /// Activate bomb power-up - clears surrounding tiles
    static func activateBomb(at position: Position, grid: inout [[Int]], gridSize: Int) -> (clearedPositions: Set<Position>, pointsEarned: Int) {
        var clearedPositions = Set<Position>()
        var totalPoints = 0
        
        // Clear 3x3 area around the bomb
        for row in max(0, position.row - 1)...min(gridSize - 1, position.row + 1) {
            for col in max(0, position.col - 1)...min(gridSize - 1, position.col + 1) {
                if grid[row][col] > 0 {
                    totalPoints += grid[row][col]
                    grid[row][col] = 0
                    clearedPositions.insert(Position(row: row, col: col))
                }
            }
        }
        
        return (clearedPositions, totalPoints)
    }
    
    /// Activate rainbow power-up - can merge with any adjacent tile
    static func activateRainbow(at position: Position, grid: inout [[Int]], gridSize: Int) -> Position? {
        // Find highest value adjacent tile
        var maxValue = 0
        var maxPosition: Position?
        
        let directions = [(-1, 0), (1, 0), (0, -1), (0, 1)]
        for (dr, dc) in directions {
            let newRow = position.row + dr
            let newCol = position.col + dc
            
            if newRow >= 0 && newRow < gridSize && newCol >= 0 && newCol < gridSize {
                if grid[newRow][newCol] > maxValue {
                    maxValue = grid[newRow][newCol]
                    maxPosition = Position(row: newRow, col: newCol)
                }
            }
        }
        
        return maxPosition
    }
    
    /// Check if shuffle power-up should be activated
    /// Check if shuffle power-up should be activated
    static func activateShuffle(grid: inout [[Int]], powerUpGrid: inout [[PowerUpType?]], gridSize: Int) {
        // Struct to hold tile data coupled with its power-up
        struct TileData {
            let value: Int
            let powerUp: PowerUpType?
        }
        
        // Collect all non-zero value tiles
        var tiles: [TileData] = []
        for row in 0..<gridSize {
            for col in 0..<gridSize {
                if grid[row][col] > 0 {
                    tiles.append(TileData(value: grid[row][col], powerUp: powerUpGrid[row][col]))
                }
            }
        }
        
        // Shuffle tiles
        tiles.shuffle()
        
        // Redistribute shuffled tiles
        var index = 0
        for row in 0..<gridSize {
            for col in 0..<gridSize {
                if grid[row][col] > 0 {
                    // Update both grid and powerUpGrid
                    let tile = tiles[index]
                    grid[row][col] = tile.value
                    powerUpGrid[row][col] = tile.powerUp
                    index += 1
                } else {
                    // Start empties should remain empty
                    // (Though shuffle logic preserves position of empties implicitly by only writing to occupied spots)
                }
            }
        }
    }
    
    /// Apply multiplier to a value
    static func applyMultiplier(to value: Int, multiplier: Double = 2.0) -> Int {
        return Int(Double(value) * multiplier)
    }
    
    /// Generate random power-up based on spawn rate
    static func generatePowerUp(spawnRate: Double) -> PowerUpType? {
        guard Double.random(in: 0...1) < spawnRate else {
            return nil
        }
        
        // Equal chance for each power-up type
        return PowerUpType.allCases.randomElement()
    }
}
