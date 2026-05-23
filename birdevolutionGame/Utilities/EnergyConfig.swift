import Foundation

struct EnergyConfig {
    static let startingEnergy: Double = 100.0
    static let maxEnergy: Double = 100.0
    static let moveCost: Double = 2.0 // Cost per swipe without merges
    
    // Energy restoration
    static let mergeRestoration: Double = 3.0 // Increased to ensure even small merges are profitable (Net: -2 + 3 = +1)
    static let energyPerScorePoint: Double = 0.05 // New: 5% of score becomes energy (e.g. merge 16+16=32pts -> +1.6 energy)
    static let comboBonusMultiplier: Double = 1.5 // Multiplier for combos
    
    // Time Attack Settings
    static let timeDecayRate: Double = 0.8 // Reduced from 1.0 to give more breathing room
    static let decayInterval: Double = 0.5 // Update frequency (twice per second)
    
    // Power-up constants
    static let energyRushAmount: Double = 40.0
    static let freezeDuration: Double = 15.0

    // Warning thresholds for UI
    static let lowEnergyThreshold: Double = 30.0
    static let criticalEnergyThreshold: Double = 15.0
}
