
import SwiftUI

struct MainView: View {
    @EnvironmentObject var game: Game2048ViewModel
    @EnvironmentObject var audioManager: AudioManager
    @State private var showingCalendar = false
    @State private var showingGridSelector = false
    
    var body: some View {
        NavigationView {
            VStack {
                
                NewGameButton {
                    withAnimation() {
                        game.startNewGame()
                    }
                }
            GameHeaderView(
                score: game.gameState.score,
                bestScore: game.bestScore
            )
            .padding(.horizontal, 24)
            MergeRotationGameBoardView(game: game)
            
            // Undo Button
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
                .background(
                    RoundedRectangle(cornerRadius: 12)
                        .fill(game.canUndo ? Color.blue.opacity(0.1) : Color.gray.opacity(0.1))
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(game.canUndo ? Color.blue : Color.gray.opacity(0.3), lineWidth: 2)
                )
            }
            .disabled(!game.canUndo)
            .opacity(game.canUndo ? 1.0 : 0.5)
            .padding(.horizontal, 24)
            
            Text("Merge two of the same birds to create a stronger one.")
                .lineLimit(1)
                .minimumScaleFactor(0.5)
            HowToPlayView()
        }
        .padding(8)
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                Button(action: {
                    showingGridSelector = true
                }) {
                    HStack(spacing: 4) {
                        Text(game.gridSize.emoji)
                        Text("\(game.gridSize.rawValue)×\(game.gridSize.rawValue)")
                            .font(.caption.bold())
                    }
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(Color.blue.opacity(0.1))
                    .cornerRadius(8)
                }
            }
            
            ToolbarItem(placement: .navigationBarTrailing) {
                HStack(spacing: 16) {
                    // Music toggle button
                    Button(action: {
                        audioManager.toggleBackgroundMusic()
                    }) {
                        Image(systemName: audioManager.isMusicPlaying ? "speaker.wave.2.fill" : "speaker.slash.fill")
                            .font(.title2)
                            .foregroundColor(audioManager.isMusicPlaying ? .blue : .gray)
                    }
                    
                    // Calendar button
                    Button(action: {
                        showingCalendar = true
                    }) {
                        Image(systemName: "calendar")
                            .font(.title2)
                            .foregroundColor(.primary)
                    }
                }
            }
        }
        .sheet(isPresented: $showingGridSelector) {
            GridSizeSelector(currentSize: game.gridSize)
                .environmentObject(game)
        }
        .sheet(isPresented: $showingCalendar) {
            CalendarView()
                .environmentObject(game)
        }
        }
        
        
        
        
            .sheet(isPresented: $game.gameState.hasWon) {
                WinView(
                    score: game.score,
                    maxTile: game.maxTileValue,
                    onContinue: {
                    },
                    onNewGame: {
                        game.startNewGame()
                    }
                )
            }
            .alert("Game Over", isPresented: $game.gameState.gameOver) {
                Button("New Game") { game.startNewGame() }
            } message: {
                Text("No more moves available.\nFinal score: \(game.score)\nBest score: \(game.bestScore)")
            }
    }
}

#Preview {
    MainView()
        .environmentObject(Game2048ViewModel())
}
