import SwiftUI

struct MainView: View {
    @EnvironmentObject var game: BirdEvolutionGameViewModel
    @EnvironmentObject var audioManager: AudioManager
    @EnvironmentObject var themeManager: ThemeManager
    @Environment(\.scenePhase) var scenePhase
    @StateObject private var tutorialManager = TutorialManager.shared
    @State private var showingCalendar = false
    @State private var showingGridSelector = false
    @State private var showOnboarding = false
    @State private var boardWidth: CGFloat = 0

    
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
                        .padding( 16 * DeviceInfo.paddingMultiplier )
                        
                        // Small gap before header
                        
                        EnergyHeaderView(
                            energy: game.gameState.energy,
                            maxEnergy: game.gameState.maxEnergy,
                            bestScore: game.bestScore
                        )
                        .frame(maxWidth: boardWidth > 0 ? boardWidth : 320 * DeviceInfo.paddingMultiplier)
                    }
                    .padding(.horizontal, 8 * DeviceInfo.paddingMultiplier)
                    
                    ZStack(alignment: .top) {
                        MergeRotationGameBoardView(game: game)
                            .background(
                                GeometryReader { proxy in
                                    Color.clear
                                        .preference(key: BoardWidthPreferenceKey.self, value: proxy.size.width)
                                }
                            )
                            .anchorPreference(
                                key: BoardAnchorKey.self,
                                value: .bounds,
                                transform: { $0 }
                            )
                        
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
                    .onPreferenceChange(BoardWidthPreferenceKey.self) { width in
                        boardWidth = width
                    }
                    
                    UndoArea(game: game)
                        .anchorPreference(
                                key: UndoAreaAnchorKey.self,
                                value: .bounds,
                                transform: { $0 }
                            )
                    HowToPlayView(tileSize: game.gridSize.tileSize)
                    let bannerSize = DeviceInfo.isIPad
                        ? CGSize(width: 728, height: 90)
                        : CGSize(width: 320, height: 50)
                    
                    BannerAdView()
                        .frame(width: bannerSize.width, height: bannerSize.height)
                        .padding(.bottom, 16)
                        
                }
                
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
                        .padding(.vertical, 4)
                        .background(.ultraThinMaterial)
                        .cornerRadius(12)
                        .background(
                            GeometryReader { proxy in
                                Color.clear
                                    .preference(key: GridSizeButtonFrameKey.self, value: proxy.frame(in: .global))
                            }
                        )
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
                                .frame(width: 10, height: 10)
                                .background(.ultraThinMaterial)
                                .clipShape(Circle())
                                
                                    .opacity(0.01)               // 👈 invisible to the eye
                                    .contentShape(Rectangle())
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
            // Base overlay layer. Hint overlays are attached below via preference keys.
            EmptyView()
        }
        .overlayPreferenceValue(BoardAnchorKey.self) { boardAnchor in
            GeometryReader { geo in
                if tutorialManager.showFirstMoveHint, let boardAnchor {
                    let rect = geo[boardAnchor]

                    HintOverlay(
                        message: "👆 Swipe in any direction to move tiles",
                        arrowDirection: .down,
                        onDismiss: {
                            tutorialManager.markFirstMoveSeen()
                        }
                    )
                    // Place above the board; arrow points down to the board.
                    .position(x: rect.midX, y: rect.minY - 18)
                }
            }
        }
        .overlayPreferenceValue(UndoAreaAnchorKey.self) { undoAnchor in
            GeometryReader { geo in
                if tutorialManager.showUndoHint, let undoAnchor {
                    let rect = geo[undoAnchor]

                    HintOverlay(
                        message: "↩️ You can undo up to 3 moves per game",
                        arrowDirection: .up,
                        onDismiss: {
                            tutorialManager.markUndoSeen()
                        }
                    )
                    // Place above UndoArea.
                    .position(x: rect.midX, y: rect.minY - 16)
                }
            }
        }
        .overlayPreferenceValue(GridSizeButtonFrameKey.self) { buttonRectGlobal in
            GeometryReader { geo in
                if tutorialManager.showGridSizeHint {
                    // Convert the toolbar button global rect into this view's local coordinates
                    let rootGlobal = geo.frame(in: .global)
                    let x = buttonRectGlobal.midX - rootGlobal.minX
                    let y = buttonRectGlobal.maxY - rootGlobal.minY + 14

                    HintOverlay(
                        message: "🎯 Try different grid sizes!",
                        arrowDirection: .up,
                        onDismiss: {
                            tutorialManager.markGridSizeSeen()
                        }
                    )
                    // Place just below the toolbar button; arrow points up to the button.
                    .position(x: x, y: y)
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

private struct BoardWidthPreferenceKey: PreferenceKey {
    static var defaultValue: CGFloat = 0

    static func reduce(value: inout CGFloat, nextValue: () -> CGFloat) {
        value = nextValue()
    }
}

private struct UndoAreaAnchorKey: PreferenceKey {
    static var defaultValue: Anchor<CGRect>? = nil

    static func reduce(value: inout Anchor<CGRect>?, nextValue: () -> Anchor<CGRect>?) {
        value = nextValue() ?? value
    }
}

private struct BoardAnchorKey: PreferenceKey {
    static var defaultValue: Anchor<CGRect>? = nil

    static func reduce(value: inout Anchor<CGRect>?, nextValue: () -> Anchor<CGRect>?) {
        value = nextValue() ?? value
    }
}

private struct GridSizeButtonFrameKey: PreferenceKey {
    static var defaultValue: CGRect = .zero

    static func reduce(value: inout CGRect, nextValue: () -> CGRect) {
        let next = nextValue()
        if next != .zero {
            value = next
        }
    }
}

#Preview {
    MainView()
        .environmentObject(BirdEvolutionGameViewModel())
}
