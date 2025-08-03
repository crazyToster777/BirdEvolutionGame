import Foundation

struct Position: Equatable, Hashable {
    let row: Int
    let col: Int
}

enum Direction {
    case left, right, up, down
}

extension Position: Codable {}
