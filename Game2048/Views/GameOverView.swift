import SwiftUI

struct GameOverView: View {
    let score: Int
    let bestScore: Int
    let canUndo: Bool
    let onUndo: VoidCallback
    let onNewGame: VoidCallback
    
    @Environment(\.dismiss) private var dismiss
    @State private var skullRotation: Double = 0
    @State private var scale: CGFloat = 0.5
    @State private var opacity: Double = 0
    
    var body: some View {
        ZStack {
            // Background gradient matching WinView style
            LinearGradient(
                colors: [Color.red.opacity(0.3), Color.orange.opacity(0.3)],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()
            
            VStack(spacing: 40) {
                Spacer()
                
                // Skull icon with rotation animation
                Text("💀")
                    .font(.system(size: 100))
                    .rotationEffect(.degrees(skullRotation))
                
                // Title
                VStack(spacing: 12) {
                    Text("Game Over")
                        .font(.system(size: 48, weight: .bold))
                    
                    Text("No more moves available")
                        .font(.title2)
                        .foregroundColor(.secondary)
                }
                
                // Stats card
                VStack(spacing: 20) {
                    HStack(spacing: 40) {
                        StatItem(icon: "star.fill", label: "Score", value: "\(score)")
                        StatItem(icon: "trophy.fill", label: "Best", value: "\(bestScore)")
                    }
                }
                .padding(24)
                .background(
                    RoundedRectangle(cornerRadius: 20)
                        .fill(Color(.systemBackground).opacity(0.9))
                        .shadow(color: .black.opacity(0.1), radius: 10, x: 0, y: 5)
                )
                .padding(.horizontal, 32)
                
                // Action buttons
                VStack(spacing: 16) {
                    // Undo button (only if available)
                    if canUndo {
                        Button(action: {
                            dismiss()
                            onUndo()
                        }) {
                            HStack {
                                Image(systemName: "arrow.uturn.backward.circle.fill")
                                Text("Undo Last Move")
                            }
                            .font(.title3.bold())
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 16)
                            .background(
                                LinearGradient(
                                    colors: [Color.orange, Color.orange.opacity(0.8)],
                                    startPoint: .leading,
                                    endPoint: .trailing
                                )
                            )
                            .cornerRadius(16)
                            .shadow(color: .orange.opacity(0.3), radius: 10, x: 0, y: 5)
                        }
                    }
                    
                    // New Game button
                    Button(action: {
                        dismiss()
                        onNewGame()
                    }) {
                        HStack {
                            Image(systemName: "arrow.clockwise.circle.fill")
                            Text("New Game")
                        }
                        .font(.title3.bold())
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 16)
                        .background(
                            LinearGradient(
                                colors: [Color.blue, Color.purple],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .cornerRadius(16)
                        .shadow(color: .blue.opacity(0.3), radius: 10, x: 0, y: 5)
                    }
                }
                .padding(.horizontal, 32)
                
                Spacer()
            }
            .scaleEffect(scale)
            .opacity(opacity)
            .onAppear {
                startAnimations()
            }
        }
    }
    
    private func startAnimations() {
        // Skull rotation animation
        withAnimation(.easeInOut(duration: 2.5).repeatForever(autoreverses: true)) {
            skullRotation = 15
        }
        
        // Scale in animation
        withAnimation(.spring(response: 0.6, dampingFraction: 0.7)) {
            scale = 1.0
        }
        
        // Fade in animation
        withAnimation(.easeIn(duration: 0.3)) {
            opacity = 1.0
        }
    }
}

#Preview {
    GameOverView(
        score: 1234,
        bestScore: 5678,
        canUndo: true,
        onUndo: {},
        onNewGame: {}
    )
}
