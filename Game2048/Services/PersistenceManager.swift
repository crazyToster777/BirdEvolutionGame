
import Foundation


class GamePersistenceManager {
    private let bestScoreKey = "bestScore"
    
    func loadBestScore() -> Int {
        return UserDefaults.standard.integer(forKey: bestScoreKey)
    }
    
    func saveBestScore(_ score: Int) {
        UserDefaults.standard.set(score, forKey: bestScoreKey)
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
