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
                    .font(.system(size: 100 * DeviceInfo.fontMultiplier))
                    .rotationEffect(.degrees(skullRotation))
                
                // Title
                VStack(spacing: 12 * DeviceInfo.paddingMultiplier) {
                    Text("Game Over")
                        .font(.system(size: 48 * DeviceInfo.fontMultiplier, weight: .bold))
                    
                    Text("No more moves available")
                        .font(.title2)
                        .foregroundColor(.secondary)
                }
                
                // Stats card
                VStack(spacing: 20 * DeviceInfo.paddingMultiplier) {
                    HStack(spacing: 40 * DeviceInfo.paddingMultiplier) {
                        StatItem(icon: "star.fill", label: "Score", value: "\(score)")
                        StatItem(icon: "trophy.fill", label: "Best", value: "\(bestScore)")
                    }
                }
                .padding(24 * DeviceInfo.paddingMultiplier)
                .background(.ultraThinMaterial)
                .cornerRadius(20)
                .padding(.horizontal, 32 * DeviceInfo.paddingMultiplier)
                
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
                            .foregroundColor(.orange)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 16)
                            .background(.ultraThinMaterial)
                            .cornerRadius(16)
                            .overlay(
                                RoundedRectangle(cornerRadius: 16)
                                    .stroke(Color.orange, lineWidth: 2)
                            )
                            .shadow(color: .black.opacity(0.1), radius: 10, x: 0, y: 5)
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
                        .foregroundColor(.blue)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 16)
                        .background(.ultraThinMaterial)
                        .cornerRadius(16)
                        .overlay(
                            RoundedRectangle(cornerRadius: 16)
                                .stroke(
                                    LinearGradient(
                                        colors: [Color.blue, Color.purple],
                                        startPoint: .leading,
                                        endPoint: .trailing
                                    ),
                                    lineWidth: 2
                                )
                        )
                        .shadow(color: .black.opacity(0.1), radius: 10, x: 0, y: 5)
                    }
                }
                .padding(.horizontal, 32 * DeviceInfo.paddingMultiplier)
                
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
