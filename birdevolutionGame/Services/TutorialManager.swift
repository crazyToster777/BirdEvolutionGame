import Foundation
import SwiftUI

class TutorialManager: ObservableObject {
    static let shared = TutorialManager()
    
    @Published var showFirstMoveHint = false
    @Published var showUndoHint = false
    @Published var showGridSizeHint = false
    
    private let hasSeenOnboardingKey = "hasSeenOnboarding"
    private let hasSeenFirstMoveKey = "hasSeenFirstMove"
    private let hasUsedUndoKey = "hasUsedUndo"
    private let hasChangedGridSizeKey = "hasChangedGridSize"
    
    var shouldShowOnboarding: Bool {
        !UserDefaults.standard.bool(forKey: hasSeenOnboardingKey)
    }
    
    func markOnboardingComplete() {
        UserDefaults.standard.set(true, forKey: hasSeenOnboardingKey)
    }
    
    func checkFirstMoveHint(moveCount: Int) {
        let hasSeenFirstMove = UserDefaults.standard.bool(forKey: hasSeenFirstMoveKey)
        if !hasSeenFirstMove && moveCount == 0 {
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                self.showFirstMoveHint = true
            }
        }
    }
    
    func markFirstMoveSeen() {
        UserDefaults.standard.set(true, forKey: hasSeenFirstMoveKey)
        showFirstMoveHint = false
    }
    
    func checkUndoHint(moveCount: Int, hasUsedUndo: Bool) {
        let hasSeenUndoHint = UserDefaults.standard.bool(forKey: hasUsedUndoKey)
        if !hasSeenUndoHint && !hasUsedUndo && moveCount >= 5 {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                self.showUndoHint = true
            }
        }
    }
    
    func markUndoSeen() {
        UserDefaults.standard.set(true, forKey: hasUsedUndoKey)
        showUndoHint = false
    }
    
    func checkGridSizeHint(gamesCompleted: Int) {
        let hasSeenGridSizeHint = UserDefaults.standard.bool(forKey: hasChangedGridSizeKey)
        if !hasSeenGridSizeHint && gamesCompleted >= 1 {
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                self.showGridSizeHint = true
            }
        }
    }
    
    func markGridSizeSeen() {
        UserDefaults.standard.set(true, forKey: hasChangedGridSizeKey)
        showGridSizeHint = false
    }
    
    func resetAllTutorials() {
        UserDefaults.standard.set(false, forKey: hasSeenOnboardingKey)
        UserDefaults.standard.set(false, forKey: hasSeenFirstMoveKey)
        UserDefaults.standard.set(false, forKey: hasUsedUndoKey)
        UserDefaults.standard.set(false, forKey: hasChangedGridSizeKey)
    }
}
