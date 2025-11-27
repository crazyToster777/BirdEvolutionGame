
import SwiftUI

struct MainView: View {
    @EnvironmentObject var game: Game2048ViewModel
    @State private var showingCalendar = false
    
    var body: some View {
        NavigationView {
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
            .padding(.horizontal, 24)
            MergeRotationGameBoardView(game: game)
            Text("Merge two of the same birds to create a stronger one.")
                .lineLimit(1)
                .minimumScaleFactor(0.5)
            HowToPlayView()
        }
        .padding(8)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button(action: {
                    showingCalendar = true
                }) {
                    Image(systemName: "calendar")
                        .font(.title2)
                        .foregroundColor(.primary)
                }
            }
        }
        .sheet(isPresented: $showingCalendar) {
            CalendarView()
                .environmentObject(game)
        }
        }
        
        
        
        
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
