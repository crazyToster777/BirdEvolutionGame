import SwiftUI

struct EnergyHeaderView: View {
    let energy: Double
    let maxEnergy: Double
    let bestScore: Int
    
    // Calculate percentage for width
    private var progress: Double {
        return max(0, min(1.0, energy / maxEnergy))
    }
    
    private var energyColor: Color {
        if progress > 0.5 { return .green }
        if progress > 0.2 { return .orange }
        return .red
    }
    
    var body: some View {
        HStack(spacing: 20 * DeviceInfo.paddingMultiplier) {
            // Energy Value
            VStack(alignment: .leading, spacing: 4) {
                Text("SURVIVAL ENERGY")
                    .font(.caption2.bold())
                    .foregroundColor(.secondary)
                    .tracking(1)
                
                HStack(alignment: .bottom, spacing: 4) {
                    Text("\(Int(energy))")
                        .font(.system(size: 32 * DeviceInfo.fontMultiplier, weight: .black))
                        .foregroundColor(energyColor)
                        .contentTransition(.numericText())
                    
                    Text("/ \(Int(maxEnergy))")
                        .font(.title3.bold())
                        .foregroundColor(.secondary.opacity(0.5))
                        .padding(.bottom, 4)
                }
            }
            .animation(.spring(), value: energy)
            
            Spacer()
            
            // Best Score (kept for history)
            VStack(alignment: .trailing, spacing: 4) {
                Text("BEST RECORD")
                    .font(.caption2.bold())
                    .foregroundColor(.secondary)
                    .tracking(1)
                
                Text("\(bestScore)")
                    .font(.title3.bold())
                    .foregroundColor(.primary)
            }
        }
        .padding()
        .background(.ultraThinMaterial)
        .cornerRadius(12)
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(
                    LinearGradient(
                        colors: [.primary.opacity(0.3), .primary.opacity(0.1)],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    ),
                    lineWidth: 1.5
                )
        )
        .shadow(color: Color.black.opacity(0.1), radius: 4, x: 0, y: 2)
        .overlay(alignment: .bottom) {
            // Progress Bar
            GeometryReader { geo in
                ZStack(alignment: .leading) {
                    Capsule()
                        .fill(Color.gray.opacity(0.2))
                        .frame(height: 6)
                    
                    Capsule()
                        .fill(
                            LinearGradient(
                                colors: [energyColor, energyColor.opacity(0.8)],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .frame(width: geo.size.width * progress, height: 6)
                        .animation(.spring(response: 0.4, dampingFraction: 0.6), value: progress)
                }
            }
            .frame(height: 6)
            .padding(.horizontal, 16)
            .padding(.bottom, 12)
            
        }
    }
}

#Preview {
    VStack {
        EnergyHeaderView(energy: 85, maxEnergy: 100, bestScore: 24000)
        EnergyHeaderView(energy: 40, maxEnergy: 100, bestScore: 24000)
        EnergyHeaderView(energy: 10, maxEnergy: 100, bestScore: 24000)
    }
    .padding()
}
