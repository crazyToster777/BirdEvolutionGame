import SwiftUI

struct PowerUpBarView: View {
    @EnvironmentObject var game: BirdEvolutionGameViewModel

    var body: some View {
        HStack(spacing: 8 * DeviceInfo.spacingMultiplier) {
            ForEach(PowerUpType.allCases, id: \.self) { type in
                PowerUpBarItemView(
                    type: type,
                    count: game.powerUpInventory[type, default: 0]
                ) {
                    withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                        game.activatePowerUp(type)
                    }
                }
            }
        }
        .padding(.horizontal, 80 * DeviceInfo.paddingMultiplier)
        .padding(.vertical, 4 * DeviceInfo.paddingMultiplier)
    }
}
