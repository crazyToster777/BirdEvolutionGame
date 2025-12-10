
import SwiftUI

struct MainView: View {
    @EnvironmentObject var game: Game2048ViewModel
    @EnvironmentObject var audioManager: AudioManager
    @EnvironmentObject var themeManager: ThemeManager
    @StateObject private var tutorialManager = TutorialManager.shared
    @State private var showingCalendar = false
    @State private var showingGridSelector = false
    @State private var showOnboarding = false
    
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
            
            #if DEBUG
            ToolbarItem(placement: .navigationBarLeading) {
                Menu {
                    Button("🏆 Test Win Screen") {
                        game.testWinScreen()
                    }
                    Button("💀 Test Game Over") {
                        game.testGameOver()
                    }
                    Button("🎲 Fill Random") {
                        game.fillAllCellsRandom()
                    }
                    Divider()
                    Button("🔄 Reset Tutorials") {
                        tutorialManager.resetAllTutorials()
                    }
                } label: {
                    Color.clear
                        .frame(width: 30, height: 30)
                        .contentShape(Rectangle())
                }
            }
            #endif
            
            ToolbarItem(placement: .navigationBarTrailing) {
                HStack(spacing: 16) {
                    // Sound toggle button (controls music and sound effects)
                    Button(action: {
                        audioManager.toggleSound()
                    }) {
                        Image(systemName: audioManager.isSoundEnabled ? "speaker.wave.2.fill" : "speaker.slash.fill")
                            .font(.title2)
                            .foregroundColor(audioManager.isSoundEnabled ? .blue : .gray)
                    }
                    
                    // Theme toggle button
                    Button(action: {
                        themeManager.cycleTheme()
                    }) {
                        Image(systemName: themeManager.currentTheme.icon)
                            .font(.title2)
                            .foregroundColor(.primary)
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
        .fullScreenCover(isPresented: $showOnboarding) {
            OnboardingView(isPresented: $showOnboarding)
        }
        .overlay {
            if tutorialManager.showFirstMoveHint {
                VStack {
                    HintOverlay(
                        message: "👆 Swipe in any direction to move tiles",
                        arrowDirection: .down,
                        onDismiss: {
                            tutorialManager.markFirstMoveSeen()
                        }
                    )
                    .padding(.top, 100)
                    Spacer()
                }
            }
            
            if tutorialManager.showUndoHint {
                VStack {
                    Spacer()
                    HintOverlay(
                        message: "↩️ You can undo up to 3 moves per game",
                        arrowDirection: .up,
                        onDismiss: {
                            tutorialManager.markUndoSeen()
                        }
                    )
                    .padding(.bottom, 200)
                }
            }
            
            if tutorialManager.showGridSizeHint {
                VStack {
                    HStack {
                        HintOverlay(
                            message: "🎯 Try different grid sizes!",
                            arrowDirection: .right,
                            onDismiss: {
                                tutorialManager.markGridSizeSeen()
                            }
                        )
                        .padding(.leading, 20)
                        Spacer()
                    }
                    .padding(.top, 100)
                    Spacer()
                }
            }
        }
        .onAppear {
            showOnboarding = tutorialManager.shouldShowOnboarding
            if !tutorialManager.shouldShowOnboarding {
                tutorialManager.checkFirstMoveHint(moveCount: game.gameState.score > 0 ? 1 : 0)
            }
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
            .sheet(isPresented: $game.gameState.gameOver) {
                GameOverView(
                    score: game.score,
                    bestScore: game.bestScore,
                    canUndo: game.canUndo,
                    onUndo: {
                        game.undo()
                    },
                    onNewGame: {
                        game.startNewGame()
                    }
                )
            }
    }
}

#Preview {
    MainView()
        .environmentObject(Game2048ViewModel())
}
