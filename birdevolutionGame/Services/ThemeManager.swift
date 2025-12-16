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
            self.currentBackground = .mountain
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
    
    
    case mountain = "Mountain"
    case sky = "Sky"
    case grass = "Grass"
    
    var color: Color {
        switch self {
        case  .mountain, .sky, .grass:
            return Color.clear // Image takes precedence
        }
    }
    
    var backgroundImageName: String? {
        switch self {
        case .mountain:
            return "background_mountain"
        case .sky:
            return "background_sky"
        case .grass:
            return "background_grass"
        }
    }
}
