import Foundation

struct GameSession: Codable, Identifiable {
    let id = UUID()
    let date: Date
    let score: Int
    let maxTile: Int
    let gamesPlayed: Int
    let totalMoves: Int
    let gridSize: Int
    
    var dayKey: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter.string(from: date)
    }
}

struct DayStats: Codable {
    var date: Date
    var totalGames: Int
    var bestScore: Int
    var bestTile: Int
    var totalMoves: Int
    var gridSize: Int
    
    init(date: Date, gridSize: Int = 4) {
        self.date = date
        self.gridSize = gridSize
        self.totalGames = 0
        self.bestScore = 0
        self.bestTile = 0
        self.totalMoves = 0
    }
    
    mutating func addSession(_ session: GameSession) {
        totalGames += session.gamesPlayed
        bestScore = max(bestScore, session.score)
        bestTile = max(bestTile, session.maxTile)
        totalMoves += session.totalMoves
    }
    
    var dayKey: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter.string(from: date)
    }
}