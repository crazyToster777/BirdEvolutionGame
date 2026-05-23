import SwiftUI

// MARK: - Grid Size Button

struct GridSizeToolbarButton: View {
    @EnvironmentObject var game: BirdEvolutionGameViewModel
    let onTap: () -> Void

    var body: some View {
        Button(action: onTap) {
            HStack(spacing: 4) {
                Text(game.gridSize.emoji)
                Text("\(game.gridSize.rawValue)×\(game.gridSize.rawValue)")
                    .font(.caption.bold())
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 4)
            .background(
                GeometryReader { proxy in
                    Color.clear.preference(
                        key: GridSizeButtonFrameKey.self,
                        value: proxy.frame(in: .global)
                    )
                }
            )
        }
    }
}

// MARK: - Theme Menu

struct ThemeMenuButton: View {
    @EnvironmentObject var themeManager: ThemeManager

    var body: some View {
        Menu {
            ForEach(AppBackground.allCases, id: \.self) { bg in
                Button { themeManager.currentBackground = bg } label: {
                    if themeManager.currentBackground == bg {
                        Label(bg.rawValue, systemImage: "checkmark")
                    } else {
                        Text(bg.rawValue)
                    }
                }
            }
        } label: {
            toolbarIcon("paintpalette.fill", color: .primary)
        }
    }
}

// MARK: - Sound Toggle

struct SoundToggleButton: View {
    @EnvironmentObject var audioManager: AudioManager

    var body: some View {
        Button { audioManager.toggleSound() } label: {
            toolbarIcon(
                audioManager.isSoundEnabled ? "speaker.wave.2.fill" : "speaker.slash.fill",
                color: audioManager.isSoundEnabled ? .blue : .gray
            )
        }
    }
}

// MARK: - Calendar Button

struct CalendarToolbarButton: View {
    let onTap: () -> Void

    var body: some View {
        Button(action: onTap) {
            toolbarIcon("calendar", color: .primary)
        }
    }
}

// MARK: - Shared Helper

private func toolbarIcon(_ systemName: String, color: Color) -> some View {
    Image(systemName: systemName)
        .font(.body)
        .foregroundColor(color)
}
