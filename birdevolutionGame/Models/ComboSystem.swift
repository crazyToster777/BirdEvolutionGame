import Foundation

/// Manages combo tracking and bonus calculations
class ComboSystem: ObservableObject {
    @Published var currentCombo: Int = 0
    @Published var comboBonus: Int = 0
    @Published var totalComboScore: Int = 0
    
    // Combo thresholds and bonuses
    private let combo2xBonus = 50
    private let combo3xBonus = 150
    private let combo4xBonus = 500
    
    // Power-up spawn rate multipliers based on combo
    var powerUpSpawnRate: Double {
        switch currentCombo {
        case 0...1:
            return 0.05  // 5% base rate
        case 2:
            return 0.08  // 8% for 2x combo
        case 3:
            return 0.12  // 12% for 3x combo
        default:
            return 0.20  // 20% for 4x+ combo
        }
    }
    
    /// Update combo count based on number of merges in current move
    func updateCombo(mergeCount: Int) {
        if mergeCount > 0 {
            currentCombo = mergeCount
            comboBonus = calculateBonus()
            totalComboScore += comboBonus
        } else {
            reset()
        }
    }
    
    /// Calculate bonus points for current combo
    private func calculateBonus() -> Int {
        switch currentCombo {
        case 2:
            return combo2xBonus
        case 3:
            return combo3xBonus
        case 4...:
            return combo4xBonus + (currentCombo - 4) * 100  // Extra 100 per combo above 4
        default:
            return 0
        }
    }
    
    /// Reset combo counter
    func reset() {
        currentCombo = 0
        comboBonus = 0
    }
    
    /// Get combo multiplier text for UI
    var comboText: String {
        guard currentCombo > 1 else { return "" }
        return "\(currentCombo)x COMBO!"
    }
    
    /// Get combo level for visual effects
    var comboLevel: ComboLevel {
        switch currentCombo {
        case 0...1:
            return .none
        case 2:
            return .double
        case 3:
            return .triple
        default:
            return .mega
        }
    }
}

/// Combo levels for visual differentiation
enum ComboLevel {
    case none
    case double
    case triple
    case mega
    
    var color: String {
        switch self {
        case .none: return "gray"
        case .double: return "blue"
        case .triple: return "purple"
        case .mega: return "orange"
        }
    }
}
