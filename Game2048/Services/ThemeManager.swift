import SwiftUI

class ThemeManager: ObservableObject {
    
    // Background Management
    @Published var currentBackground: AppBackground {
        didSet {
            UserDefaults.standard.set(currentBackground.rawValue, forKey: "appBackground")
        }
    }
    
    init() {
        if let savedBg = UserDefaults.standard.string(forKey: "appBackground"),
           let bg = AppBackground(rawValue: savedBg) {
            self.currentBackground = bg
        } else {
            self.currentBackground = .sky
        }
    }
    
    func cycleBackground() {
        let allBackgrounds = AppBackground.allCases
        if let currentIndex = allBackgrounds.firstIndex(of: currentBackground) {
            let nextIndex = (currentIndex + 1) % allBackgrounds.count
            currentBackground = allBackgrounds[nextIndex]
        }
    }
}

enum AppBackground: String, CaseIterable {
    case sky = "Sky"
    case mountain = "Mountain"
    case grass = "Grass"
    
    var color: Color {
        return Color.clear // Always using images now
    }
    
    var backgroundImageName: String? {
        switch self {
        case .sky:
            return "background_sky"
        case .mountain:
            return "background_mountain"
        case .grass:
            return "background_grass"
        }
    }
}
