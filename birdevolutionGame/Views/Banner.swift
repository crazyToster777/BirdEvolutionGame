import SwiftUI
import GoogleMobileAds
import UIKit

struct BannerAdView: UIViewRepresentable {

    func makeUIView(context: Context) -> BannerView {
        let banner = BannerView(adSize: AdSizeBanner) // 320x50
        banner.adUnitID = "ca-app-pub-2241716040388986/9736005701" // TEST banner
        banner.rootViewController = topViewController()
        banner.translatesAutoresizingMaskIntoConstraints = false
        banner.load(Request())
        return banner
    }

    func updateUIView(_ uiView: BannerView, context: Context) {
        // nothing
    }

    private func topViewController() -> UIViewController? {
        let scenes = UIApplication.shared.connectedScenes
            .compactMap { $0 as? UIWindowScene }

        let window = scenes
            .flatMap { $0.windows }
            .first(where: { $0.isKeyWindow })

        return window?.rootViewController
    }
}
