
import Foundation

typealias VoidCallback = () -> Void

// MARK: - Game Constants
enum GameConstants {
    // UserDefaults Keys
    static let bestScoreKey = "bestScore"
    static let dayStatsKey = "dayStats"
    
    // Animation Durations
    static let mergeRotationDuration: Double = 0.15
    static let mergeRotationDelay: Double = 0.7
    static let newTileDelay: Double = 1.0
    
    // Gesture Thresholds
    static let minimumDragDistance: CGFloat = 30
    static let swipeThreshold: CGFloat = 50
    
    // Audio Resources
    static let swipeSounds = ["swipe1", "swipe2"]
    static let audioExtension = "wav"
    
    // Undo Settings
    static let maxUndos = 3
}

// MARK: - Grid Size Configuration
enum GridSize: Int, CaseIterable, Codable {
    case small = 4
    case medium = 5
    case large = 6
    
    var displayName: String {
        switch self {
        case .small: return "4×4 Classic"
        case .medium: return "5×5 Hard"
        case .large: return "6×6 Expert"
        }
    }
    
    /// Base tile size (for iPhone), scaled by device multiplier
    var tileSize: CGFloat {
        let baseSize: CGFloat
        switch self {
        case .small: baseSize = 70
        case .medium: baseSize = 56
        case .large: baseSize = 46
        }
        return baseSize * DeviceInfo.sizeMultiplier
    }
    
    /// Base spacing (for iPhone), scaled by device multiplier
    var spacing: CGFloat {
        let baseSpacing: CGFloat
        switch self {
        case .small: baseSpacing = 8
        case .medium: baseSpacing = 6
        case .large: baseSpacing = 5
        }
        return baseSpacing * DeviceInfo.spacingMultiplier
    }
    
    var emoji: String {
        switch self {
        case .small: return "🎯"
        case .medium: return "⚡️"
        case .large: return "🔥"
        }
    }
}
