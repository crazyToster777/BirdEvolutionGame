import SwiftUI

struct MainHeaderSection: View {
    @EnvironmentObject var game: BirdEvolutionGameViewModel
    let boardWidth: CGFloat

    var body: some View {
        VStack(spacing: 0) {
            NewGameButton {
                withAnimation { game.startNewGame() }
            }
            .padding(16 * DeviceInfo.paddingMultiplier)

            EnergyHeaderView(
                energy: game.gameState.energy,
                maxEnergy: game.gameState.maxEnergy,
                score: game.score,
                bestScore: game.bestScore,
                isFrozen: game.isEnergyFrozen
            )
            .frame(maxWidth: boardWidth > 0 ? boardWidth : 320 * DeviceInfo.paddingMultiplier)
        }
        .padding(.horizontal, 8 * DeviceInfo.paddingMultiplier)
        .padding(.top, 8 * DeviceInfo.paddingMultiplier)
    }
}
