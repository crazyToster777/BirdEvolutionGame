import Foundation

/// Handles power-up effect implementations
class PowerUpEffects {

    /// Apply energy rush: adds energyRushAmount capped at max
    static func applyEnergyRush(to energy: Double, max: Double) -> Double {
        return min(energy + EnergyConfig.energyRushAmount, max)
    }

    /// Remove all tiles matching the minimum non-zero value on the board
    static func applySmash(to grid: inout [[Int]], gridSize: Int) {
        var minValue = Int.max
        for row in 0..<gridSize {
            for col in 0..<gridSize {
                let v = grid[row][col]
                if v > 0 && v < minValue { minValue = v }
            }
        }
        guard minValue != Int.max else { return }
        for row in 0..<gridSize {
            for col in 0..<gridSize {
                if grid[row][col] == minValue { grid[row][col] = 0 }
            }
        }
    }

    /// Return the direction that produces the most merges; nil if no merges possible
    static func computeBestHintDirection(grid: [[Int]], gridSize: Int, model: GameModel) -> Direction? {
        var tempState = GameState(gridSize: gridSize)
        tempState.grid = grid

        var bestDirection: Direction? = nil
        var bestMerges = 0

        for direction in [Direction.left, .right, .up, .down] {
            let result = model.performMove(direction, on: tempState)
            if result.mergedPositions.count > bestMerges {
                bestMerges = result.mergedPositions.count
                bestDirection = direction
            }
        }
        return bestDirection
    }
}
