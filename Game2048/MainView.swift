
import SwiftUI

struct MainView: View {
    @EnvironmentObject var game: Game2048ViewModel
    @EnvironmentObject var audioManager: AudioManager
    @EnvironmentObject var themeManager: ThemeManager
    @Environment(\.scenePhase) var scenePhase
    @StateObject private var tutorialManager = TutorialManager.shared
    @State private var showingCalendar = false
    @State private var showingGridSelector = false
    @State private var showOnboarding = false

    
    var body: some View {
        NavigationView {
            ZStack {
                // Background Layer
                if let imageName = themeManager.currentBackground.backgroundImageName {
                    Image(imageName)
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .ignoresSafeArea()
                } else {
                    themeManager.currentBackground.color
                        .ignoresSafeArea()
                }
                
                VStack {
                    VStack(spacing: 0) {
                        NewGameButton {
                            withAnimation {
                                game.startNewGame()
                            }
                        }
                        .padding(.bottom, 32)
                        
                        // Small gap before header
                        
                        EnergyHeaderView(
                            energy: game.gameState.energy,
                            maxEnergy: game.gameState.maxEnergy,
                            bestScore: game.bestScore
                        )
                    }
                    .padding(.horizontal, 80 * DeviceInfo.paddingMultiplier)
                    
                    ZStack(alignment: .top) {
                        MergeRotationGameBoardView(game: game)
                        
                        // Combo Counter Overlay
                        if game.showComboBanner {
                            ComboCounterView(
                                comboCount: game.comboCount,
                                comboBonus: game.comboBonus,
                                isVisible: game.showComboBanner
                            )
                            .transition(.scale.combined(with: .opacity))
                            .offset(y: -60) // Position above the grid
                            .zIndex(10)
                        }
                    }
                    
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
                    
                    Text("Merge two of the same birds to create a stronger one.")
                        .font(.caption)
                        .fontWeight(.medium)
                        .foregroundColor(.primary)
                        .lineLimit(1)
                        .minimumScaleFactor(0.8)
                        .padding(.horizontal, 16)
                        .padding(.vertical, 8)
                        .background(.ultraThinMaterial)
                        .cornerRadius(20)
                        .padding(.top, 8)
                    HowToPlayView()
                    
                    Spacer(minLength: 0) // Push everything to the top
                }
                .padding(8 * DeviceInfo.paddingMultiplier)
            }
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
                        .padding(.horizontal, 12)
                        .padding(.vertical, 6)
                        .background(.ultraThinMaterial)
                        .cornerRadius(12)
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    HStack(spacing: 12) {
                        #if DEBUG
                        Menu {
                            Button("Instant Win") {
                                game.testWinScreen()
                            }
                            Button("Instant Game Over") {
                                game.testGameOver()
                            }
                            Button("Chaos Mode (Fill)") {
                                game.fillAllCellsRandom()
                            }
                            Button("Show Onboarding") {
                                showOnboarding = true
                            }
                        } label: {
                            Image(systemName: "ladybug.fill")
                                .font(.body)
                                .foregroundColor(.red)
                                .frame(width: 36, height: 36)
                                .background(.ultraThinMaterial)
                                .clipShape(Circle())
                        }
                        #endif

                        // Background toggle
                        Menu {
                            ForEach(AppBackground.allCases, id: \.self) { bg in
                                Button(action: {
                                    themeManager.currentBackground = bg
                                }) {
                                    if themeManager.currentBackground == bg {
                                        Label(bg.rawValue, systemImage: "checkmark")
                                    } else {
                                        Text(bg.rawValue)
                                    }
                                }
                            }
                        } label: {
                            Image(systemName: "paintpalette.fill")
                                .font(.body)
                                .foregroundColor(.primary)
                                .frame(width: 36, height: 36)
                                .background(.ultraThinMaterial)
                                .clipShape(Circle())
                        }

                        // Sound toggle
                        Button(action: {
                            audioManager.toggleSound()
                        }) {
                            Image(systemName: audioManager.isSoundEnabled ? "speaker.wave.2.fill" : "speaker.slash.fill")
                                .font(.body)
                                .foregroundColor(audioManager.isSoundEnabled ? .blue : .gray)
                                .frame(width: 36, height: 36)
                                .background(.ultraThinMaterial)
                                .clipShape(Circle())
                        }
                        
                        
                        // Calendar
                        Button(action: {
                            showingCalendar = true
                        }) {
                            Image(systemName: "calendar")
                                .font(.body)
                                .foregroundColor(.primary)
                                .frame(width: 36, height: 36)
                                .background(.ultraThinMaterial)
                                .clipShape(Circle())
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
        .navigationViewStyle(.stack)
        .onChange(of: scenePhase) { newPhase in
            switch newPhase {
            case .active:
                if !showingCalendar && !showOnboarding {
                    game.resumeGame()
                }
            case .inactive, .background:
                game.pauseGame()
            @unknown default:
                break
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
