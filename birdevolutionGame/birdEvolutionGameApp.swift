import SwiftUI
import GoogleMobileAds

@main
struct newgameApp: App {

    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate

    @StateObject private var gameViewModel = BirdEvolutionGameViewModel()
    @StateObject private var audioManager = AudioManager.shared
    @StateObject private var themeManager = ThemeManager()

    var body: some Scene {
        WindowGroup {
            MainView()
                .environmentObject(gameViewModel)
                .environmentObject(audioManager)
                .environmentObject(themeManager)
        }
    }
}

final class AppDelegate: NSObject, UIApplicationDelegate {
    func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]? = nil
    ) -> Bool {

        MobileAds.shared.start(completionHandler: nil)

        return true
    }
}
