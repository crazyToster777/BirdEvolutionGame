
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
        .background(buttonGradient)
        .foregroundColor(.white)
        .cornerRadius(12)
        .shadow(color: Color.blue.opacity(0.3), radius: 4, x: 0, y: 2)
        .alert("Start New Game?", isPresented: $showingConfirmation) {
            Button("Cancel", role: .cancel) { }
            Button("New Game", role: .destructive) {
                action()
            }
        } message: {
            Text("Your current game will be saved to statistics, but progress will be lost.")
        }
    }
    
    private var buttonGradient: LinearGradient {
        LinearGradient(
            gradient: Gradient(colors: [
                Color(red: 0.3, green: 0.7, blue: 1.0),
                Color(red: 0.2, green: 0.6, blue: 0.9)
            ]),
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }
}
