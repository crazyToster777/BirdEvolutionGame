import SwiftUI

struct UndoArea: View {
    @ObservedObject var game: BirdEvolutionGameViewModel

    var body: some View {
        Group {
            if game.canUndo {
                Button(action: {
                    withAnimation {
                        game.undo()
                    }
                }) {
                    HStack(spacing: 8) {
                        Image(systemName: "arrow.uturn.backward.circle.fill")
                            .font(.title3)
                        Text("Undo")
                            .fontWeight(.semibold)
                        Spacer()
                        Text("\(game.gameState.undosRemaining)/\(GameConstants.maxUndos)")
                            .font(.caption)
                            .padding(.horizontal, 8)
                            .padding(.vertical, 4)
                            .background(game.canUndo ? Color.blue.opacity(0.2) : Color.gray.opacity(0.2))
                            .cornerRadius(6)
                    }
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(.ultraThinMaterial)
                    .cornerRadius(12)
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(
                                LinearGradient(
                                    colors: [Color.blue.opacity(0.6), Color.blue.opacity(0.3)],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                ),
                                lineWidth: 1.5
                            )
                    )
                    .shadow(color: Color.black.opacity(0.1), radius: 4, x: 0, y: 2)
                }
                .disabled(!game.canUndo)
                .opacity(game.canUndo ? 1.0 : 0.6)
                .padding(.horizontal, 80 * DeviceInfo.paddingMultiplier)
            } else {
                WatchAdButton {
                    game.grantUndo()
                }
                .onAppear {
                    RewardedAdManager.shared.load()
                }
            }
        }
    }
}
