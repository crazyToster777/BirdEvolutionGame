import SwiftUI

struct ComboCounterView: View {
    let comboCount: Int
    let comboBonus: Int
    let isVisible: Bool
    
    @State private var scale: CGFloat = 0.5
    @State private var opacity: Double = 0
    
    private var comboLevel: ComboLevel {
        switch comboCount {
        case 0...1:
            return .none
        case 2:
            return .double
        case 3:
            return .triple
        default:
            return .mega
        }
    }
    
    private var comboColor: Color {
        switch comboLevel {
        case .none:
            return .gray
        case .double:
            return .blue
        case .triple:
            return .purple
        case .mega:
            return .orange
        }
    }
    
    var body: some View {
        if isVisible && comboCount >= 2 {
            VStack(spacing: 8 * DeviceInfo.paddingMultiplier) {
                // Combo text
                Text("\(comboCount)x COMBO!")
                    .font(.system(size: 24 * DeviceInfo.fontMultiplier, weight: .bold))
                    .foregroundColor(.white)
                
                // Bonus points
                if comboBonus > 0 {
                    Text("+\(comboBonus) pts")
                        .font(.system(size: 16 * DeviceInfo.fontMultiplier, weight: .semibold))
                        .foregroundColor(.white.opacity(0.9))
                }
            }
            .padding(.horizontal, 20 * DeviceInfo.paddingMultiplier)
            .padding(.vertical, 12 * DeviceInfo.paddingMultiplier)
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(
                        LinearGradient(
                            colors: [comboColor, comboColor.opacity(0.7)],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .shadow(color: comboColor.opacity(0.5), radius: 10, x: 0, y: 5)
            )
            .scaleEffect(scale)
            .opacity(opacity)
            .onAppear {
                withAnimation(.spring(response: 0.4, dampingFraction: 0.6)) {
                    scale = 1.0
                    opacity = 1.0
                }
            }
            .onChange(of: isVisible) { newValue in
                if !newValue {
                    withAnimation(.easeOut(duration: 0.3)) {
                        opacity = 0
                        scale = 0.8
                    }
                }
            }
        }
    }
}

#Preview {
    VStack(spacing: 20) {
        ComboCounterView(comboCount: 2, comboBonus: 50, isVisible: true)
        ComboCounterView(comboCount: 3, comboBonus: 150, isVisible: true)
        ComboCounterView(comboCount: 5, comboBonus: 700, isVisible: true)
    }
    .padding()
    .background(Color.gray.opacity(0.2))
}
