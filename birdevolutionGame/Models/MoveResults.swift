
import Foundation


struct MoveResult {
    let newGrid: [[Int]]
    let scoreGained: Int
    let hasWon: Bool
    let gridChanged: Bool
    let mergedPositions: Set<Position>
    let newTilePositions: Set<Position>
}
