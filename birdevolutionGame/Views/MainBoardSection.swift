import SwiftUI

struct MainBoardSection: View {
    @EnvironmentObject var game: BirdEvolutionGameViewModel
    let onWidthChange: (CGFloat) -> Void

    var body: some View {
        ZStack(alignment: .top) {
            MergeRotationGameBoardView(game: game)
                .background(widthReader)
                .anchorPreference(key: BoardAnchorKey.self, value: .bounds) { $0 }

            if game.showComboBanner {
                ComboCounterView(
                    comboCount: game.comboCount,
                    comboBonus: game.comboBonus,
                    isVisible: game.showComboBanner
                )
                .transition(.scale.combined(with: .opacity))
                .offset(y: -60)
                .zIndex(10)
            }
        }
        .onPreferenceChange(BoardWidthPreferenceKey.self, perform: onWidthChange)
    }

    private var widthReader: some View {
        GeometryReader { proxy in
            Color.clear.preference(key: BoardWidthPreferenceKey.self, value: proxy.size.width)
        }
    }
}
