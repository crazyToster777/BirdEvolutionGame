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

    // MARK: - Body

    var body: some View {
        ZStack {
            backgroundLayer
            NavigationView {
                contentStack
                .background(Color.clear)
                .toolbar {
                    ToolbarItem(placement: .navigationBarLeading) {
                        GridSizeToolbarButton { showingGridSelector = true }
                    }
                    ToolbarItemGroup(placement: .navigationBarTrailing) {
                        #if DEBUG
                        debugMenu
                        #endif
                        ThemeMenuButton()
                        SoundToggleButton()
                        CalendarToolbarButton { showingCalendar = true }
                    }
                }
                .onAppear(perform: handleAppear)
                .sheet(isPresented: $showingGridSelector) {
                    GridSizeSelector(currentSize: game.gridSize).environmentObject(game)
                }
                .sheet(isPresented: $showingCalendar) {
                    CalendarView().environmentObject(game)
                }
                .fullScreenCover(isPresented: $showOnboarding) {
                    OnboardingView(isPresented: $showOnboarding)
                }
                .sheet(isPresented: $game.gameState.hasWon) {
                    WinView(
                        score: game.score,
                        maxTile: game.maxTileValue,
                        onContinue: {},
                        onNewGame: { game.startNewGame() }
                    )
                }
                .sheet(isPresented: $game.gameState.gameOver) {
                    GameOverView(
                        score: game.score,
                        bestScore: game.bestScore,
                        canUndo: game.canUndo,
                        onUndo: { game.undo() },
                        onNewGame: { game.startNewGame() }
                    )
                }
                .overlayPreferenceValue(BoardAnchorKey.self, boardHintOverlay)
                .overlayPreferenceValue(UndoAreaAnchorKey.self, undoHintOverlay)
                .overlayPreferenceValue(GridSizeButtonFrameKey.self, gridSizeHintOverlay)
            }
            .background(Color.clear)
            .navigationViewStyle(.stack)
            .onChange(of: scenePhase, perform: handleScenePhase)
        }
    }

    // MARK: - Background

    @ViewBuilder
    private var backgroundLayer: some View {
        if let imageName = themeManager.currentBackground.backgroundImageName {
            Image(imageName)
                .resizable()
                .aspectRatio(contentMode: .fill)
                .ignoresSafeArea()
        } else {
            themeManager.currentBackground.color
                .ignoresSafeArea()
        }
    }

    // MARK: - Content Stack

    private var contentStack: some View {
        VStack(spacing: 4) {
            MainHeaderSection(boardWidth: boardWidth)
            MainBoardSection { boardWidth = $0 }
            PowerUpBarView()
            UndoArea(game: game)
                .anchorPreference(key: UndoAreaAnchorKey.self, value: .bounds) { $0 }
            HowToPlayView(tileSize: game.gridSize.tileSize)
            bannerAdSection
            Spacer(minLength: 0)
        }
    }

    // MARK: - Banner Ad

    private var bannerAdSection: some View {
        let size = DeviceInfo.isIPad ? CGSize(width: 728, height: 90) : CGSize(width: 320, height: 50)
        return BannerAdView()
            .frame(width: size.width, height: size.height)
            .clipped()
            .padding(.bottom, 16)
    }

    // MARK: - Tutorial Hint Overlays

    private func boardHintOverlay(_ anchor: Anchor<CGRect>?) -> some View {
        GeometryReader { geo in
            if tutorialManager.showFirstMoveHint, let anchor {
                let rect = geo[anchor]
                HintOverlay(
                    message: "👆 Swipe in any direction to move tiles",
                    arrowDirection: .down,
                    onDismiss: { tutorialManager.markFirstMoveSeen() }
                )
                .position(x: rect.midX, y: rect.minY - 18)
            }
        }
    }

    private func undoHintOverlay(_ anchor: Anchor<CGRect>?) -> some View {
        GeometryReader { geo in
            if tutorialManager.showUndoHint, let anchor {
                let rect = geo[anchor]
                HintOverlay(
                    message: "↩️ You can undo up to 3 moves per game",
                    arrowDirection: .up,
                    onDismiss: { tutorialManager.markUndoSeen() }
                )
                .position(x: rect.midX, y: rect.minY - 16)
            }
        }
    }

    private func gridSizeHintOverlay(_ buttonRect: CGRect) -> some View {
        GeometryReader { geo in
            if tutorialManager.showGridSizeHint {
                let root = geo.frame(in: .global)
                HintOverlay(
                    message: "🎯 Try different grid sizes!",
                    arrowDirection: .up,
                    onDismiss: { tutorialManager.markGridSizeSeen() }
                )
                .position(
                    x: buttonRect.midX - root.minX,
                    y: buttonRect.maxY - root.minY + 14
                )
            }
        }
    }

    // MARK: - Event Handlers

    private func handleAppear() {
        showOnboarding = tutorialManager.shouldShowOnboarding
        if !tutorialManager.shouldShowOnboarding {
            tutorialManager.checkFirstMoveHint(moveCount: game.gameState.score > 0 ? 1 : 0)
        }
    }

    private func handleScenePhase(_ phase: ScenePhase) {
        switch phase {
        case .active:
            if !showingCalendar && !showOnboarding { game.resumeGame() }
        case .inactive, .background:
            game.pauseGame()
        @unknown default:
            break
        }
    }
}

// MARK: - Debug Menu

#if DEBUG
private extension MainView {
    var debugMenu: some View {
        Menu {
            Button("Instant Win") { game.testWinScreen() }
            Button("Instant Game Over") { game.testGameOver() }
            Button("Chaos Mode (Fill)") { game.fillAllCellsRandom() }
            Button("Show Onboarding") { showOnboarding = true }
        } label: {
            Image(systemName: "ladybug.fill")
                .font(.body)
                .foregroundColor(.red)
                .frame(width: 10, height: 10)
                .background(.ultraThinMaterial)
                .clipShape(Circle())
                .opacity(0.01)
                .contentShape(Rectangle())
        }
    }
}
#endif

// MARK: - Preview

#Preview {
    MainView()
        .environmentObject(BirdEvolutionGameViewModel())
}
