
import SwiftUI

struct MainView: View {
    @EnvironmentObject var game: Game2048ViewModel
    var body: some View {
        VStack {
            NewGameButton {
                withAnimation() {
                    game.startNewGame()
                }
            }
            GameHeaderView(
                score: game.gameState.score,
                bestScore: game.bestScore
            )
            MergeRotationGameBoardView(game: game)
        }
        .padding(8)
        
        Text("Swipe to merge tiles. Goal: merge tiles to get 2048!")
        
        GoogleBannerView()
        
            .sheet(isPresented: $game.gameState.hasWon) {
                WinView(
                    score: game.score,
                    maxTile: game.maxTileValue,
                    onContinue: {
                    },
                    onNewGame: {
                        game.startNewGame()
                    }
                )
            }
            .alert("Game Over", isPresented: $game.gameState.gameOver) {
                Button("New Game") { game.startNewGame() }
            } message: {
                Text("No more moves available.\nFinal score: \(game.score)\nBest score: \(game.bestScore)")
            }
    }
}

#Preview {
    MainView()
        .environmentObject(Game2048ViewModel())
}
