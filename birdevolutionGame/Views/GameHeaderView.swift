
import SwiftUI


struct GameHeaderView: View {
    let score: Int
    let bestScore: Int
    
    var body: some View {
        HStack {
            ScoreCard(
                title: "SCORE",
                value: score,
                color: Color(red: 0.2, green: 0.6, blue: 1.0)
            )
            ScoreCard(
                title: "BEST",
                value: bestScore,
                color: Color(red: 1.0, green: 0.6, blue: 0.2)
            )
        }
    }
}
