import Foundation

/// Types of power-ups available in the game
enum PowerUpType: String, Codable, CaseIterable {
    case bomb = "💣"
    case rainbow = "🌈"
    case multiplier = "✖️2"
    case shuffle = "🔀"
    
    var displayName: String {
        switch self {
        case .bomb: return "Bomb"
        case .rainbow: return "Rainbow"
        case .multiplier: return "Multiplier"
        case .shuffle: return "Shuffle"
        }
    }
    
    var description: String {
        switch self {
        case .bomb:
            return "Clears surrounding tiles"
        case .rainbow:
            return "Merges with any tile"
        case .multiplier:
            return "Doubles next merge"
        case .shuffle:
            return "Randomizes board"
        }
    }
    
    var emoji: String {
        return self.rawValue
    }
}

/// Represents a power-up in the game
struct PowerUp: Codable, Equatable {
    let type: PowerUpType
    let id: UUID
    
    init(type: PowerUpType) {
        self.type = type
        self.id = UUID()
    }
}
