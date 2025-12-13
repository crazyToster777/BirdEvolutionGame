import SwiftUI

struct WinView: View {
    let score: Int
    let maxTile: Int
    let onContinue: VoidCallback
    let onNewGame: VoidCallback
    
    @Environment(\.dismiss) private var dismiss
    @State private var crownRotation: Double = 0
    @State private var scale: CGFloat = 0.5
    
    var body: some View {
        ZStack {
            // Background gradient matching onboarding
            LinearGradient(
                colors: [Color.blue.opacity(0.3), Color.purple.opacity(0.3)],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()
            
            VStack(spacing: 40) {
                Spacer()
                
                // Crown icon with rotation
                Text("👑")
                    .font(.system(size: 100 * DeviceInfo.fontMultiplier))
                    .rotationEffect(.degrees(crownRotation))
                
                // Title
                VStack(spacing: 12 * DeviceInfo.paddingMultiplier) {
                    Text("Victory!")
                        .font(.system(size: 48 * DeviceInfo.fontMultiplier, weight: .bold))
                    
                    Text("You reached \(maxTile)!")
                        .font(.title2)
                        .foregroundColor(.secondary)
                }
                
                // Stats card
                VStack(spacing: 20 * DeviceInfo.paddingMultiplier) {
                    HStack(spacing: 40 * DeviceInfo.paddingMultiplier) {
                        StatItem(icon: "star.fill", label: "Score", value: "\(score)")
                        StatItem(icon: "crown.fill", label: "Max Tile", value: "\(maxTile)")
                    }
                }
                .padding(24 * DeviceInfo.paddingMultiplier)
                .background(.ultraThinMaterial)
                .cornerRadius(20)
                .padding(.horizontal, 32 * DeviceInfo.paddingMultiplier)
                
                // Action buttons
                VStack(spacing: 16) {
                    Button(action: {
                        dismiss()
                        onContinue()
                    }) {
                        HStack {
                            Image(systemName: "arrow.forward.circle.fill")
                            Text("Continue Playing")
                        }
                        .font(.title3.bold())
                        .foregroundColor(.green)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 16)
                        .background(.ultraThinMaterial)
                        .cornerRadius(16)
                        .overlay(
                            RoundedRectangle(cornerRadius: 16)
                                .stroke(Color.green, lineWidth: 2)
                        )
                        .shadow(color: .black.opacity(0.1), radius: 10, x: 0, y: 5)
                    }
                    
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
            .onAppear {
                startAnimations()
            }
        }
    }
    
    private func startAnimations() {
        // Crown rotation animation
        withAnimation(.easeInOut(duration: 3.0).repeatForever(autoreverses: true)) {
            crownRotation = 20
        }
        
        // Scale in animation
        withAnimation(.spring(response: 0.6, dampingFraction: 0.7)) {
            scale = 1.0
        }
    }
}

struct StatItem: View {
    let icon: String
    let label: String
    let value: String
    
    var body: some View {
        VStack(spacing: 8) {
            Image(systemName: icon)
                .font(.system(size: 30))
                .foregroundColor(.blue)
            
            Text(label)
                .font(.caption)
                .foregroundColor(.secondary)
            
            Text(value)
                .font(.title2.bold())
        }
    }
}

#Preview {
    WinView(
        score: 12345,
        maxTile: 2048,
        onContinue: {},
        onNewGame: {}
    )
}
