import SwiftUI

struct PowerUpIndicatorView: View {
    let powerUpType: PowerUpType?
    let tileSize: CGFloat
    
    var body: some View {
        if let powerUp = powerUpType {
            ZStack {
                // Glow effect
                Circle()
                    .fill(
                        RadialGradient(
                            colors: [powerUpColor.opacity(0.6), powerUpColor.opacity(0)],
                            center: .center,
                            startRadius: 0,
                            endRadius: tileSize * 0.6
                        )
                    )
                    .frame(width: tileSize * 1.2, height: tileSize * 1.2)
                
                // Power-up emoji
                Text(powerUp.emoji)
                    .font(.system(size: tileSize * 0.4))
                    .shadow(color: .black.opacity(0.3), radius: 2, x: 0, y: 2)
            }
        }
    }
    
    private var powerUpColor: Color {
        guard let powerUp = powerUpType else { return .clear }
        
        switch powerUp {
        case .bomb:
            return .red
        case .rainbow:
            return .purple
        case .multiplier:
            return .orange
        case .shuffle:
            return .blue
        }
    }
}

#Preview {
    HStack(spacing: 20) {
        PowerUpIndicatorView(powerUpType: .bomb, tileSize: 70)
        PowerUpIndicatorView(powerUpType: .rainbow, tileSize: 70)
        PowerUpIndicatorView(powerUpType: .multiplier, tileSize: 70)
        PowerUpIndicatorView(powerUpType: .shuffle, tileSize: 70)
    }
    .padding()
    .background(Color.gray.opacity(0.3))
}
