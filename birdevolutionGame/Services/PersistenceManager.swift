import Foundation


class GamePersistenceManager {
    private let userDefaults = UserDefaults.standard
    
    func loadBestScore(for gridSize: Int = 4) -> Int {
        let key = "bestScore_\(gridSize)x\(gridSize)"
        return userDefaults.integer(forKey: key)
    }
    
    func saveBestScore(_ score: Int, for gridSize: Int = 4) {
        let key = "bestScore_\(gridSize)x\(gridSize)"
        userDefaults.set(score, forKey: key)
    }
    
    // Legacy support for old saves (4x4 only)
    func migrateLegacyBestScore() {
        if let oldScore = userDefaults.value(forKey: "bestScore") as? Int {
            saveBestScore(oldScore, for: 4)
            userDefaults.removeObject(forKey: "bestScore")
        }
    }
    
    func saveGame(_ gameState: GameState) {
        if let data = try? JSONEncoder().encode(gameState) {
            UserDefaults.standard.set(data, forKey: "savedGame")
        }
    }
    
    func loadGame() -> GameState? {
        guard let data = UserDefaults.standard.data(forKey: "savedGame"),
              let gameState = try? JSONDecoder().decode(GameState.self, from: data) else {
            return nil
        }
        return gameState
    }
}
