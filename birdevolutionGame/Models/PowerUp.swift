import Foundation

/// Types of power-ups available in the game
enum PowerUpType: String, Codable, CaseIterable {
    case energyRush = "⚡"
    case freeze = "❄️"
    case smash = "🔨"
    case hint = "💡"

    var displayName: String {
        switch self {
        case .energyRush: return "Energy"
        case .freeze: return "Freeze"
        case .smash: return "Smash"
        case .hint: return "Hint"
        }
    }

    var description: String {
        switch self {
        case .energyRush: return "+40 energy instantly"
        case .freeze: return "Pause time-decay 15s"
        case .smash: return "Remove lowest tiles"
        case .hint: return "Flash best swipe direction"
        }
    }

    var emoji: String {
        return self.rawValue
    }
}
