
import SwiftUI

struct NewGameButton: View {
    let action: VoidCallback
    @EnvironmentObject var game: Game2048ViewModel
    @State private var showingConfirmation = false
    
    var body: some View {
        Button("Start Evolution") {
            if game.gameState.score > 0 {
                showingConfirmation = true
            } else {
                action()
            }
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 12)
        .background(.ultraThinMaterial)
        .foregroundColor(.primary)
        .cornerRadius(12)
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(
                    LinearGradient(
                        colors: [.green, .green.opacity(0.6)],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    ),
                    lineWidth: 1.5
                )
        )
        .shadow(color: Color.black.opacity(0.1), radius: 4, x: 0, y: 2)
        .alert("Start New Game?", isPresented: $showingConfirmation) {
            Button("Cancel", role: .cancel) { }
            Button("New Game", role: .destructive) {
                action()
            }
        } message: {
            Text("Your current game will be saved to statistics, but progress will be lost.")
        }
    }
}
