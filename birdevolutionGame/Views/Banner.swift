//
//  Banner.swift
//  birdevolution
//
//  Created by Dany on 19/01/2026.
//

import SwiftUI
import GoogleMobileAds
import UIKit

struct BannerAdView: UIViewRepresentable {

    // MARK: - UIViewRepresentable

    func makeCoordinator() -> Coordinator {
        Coordinator()
    }

    func makeUIView(context: Context) -> UIView {
        let container = UIView()
        container.backgroundColor = .clear

        let banner = BannerView(adSize: AdSizeBanner) // will be set to adaptive size in updateUIView
        banner.translatesAutoresizingMaskIntoConstraints = false
        banner.backgroundColor = .clear
        banner.adUnitID = "ca-app-pub-3940256099942544/2934735716" // TEST banner
        banner.rootViewController = BannerAdView.topMostViewController()

        container.addSubview(banner)

        // Center the banner horizontally so it never looks like it shifts the whole layout.
        // Do NOT constrain banner width to container width; AdMob controls the actual banner width via adSize.
        NSLayoutConstraint.activate([
            banner.centerXAnchor.constraint(equalTo: container.centerXAnchor),
            banner.centerYAnchor.constraint(equalTo: container.centerYAnchor)
        ])

        context.coordinator.banner = banner

        return container
    }

    func updateUIView(_ uiView: UIView, context: Context) {
        guard let banner = context.coordinator.banner else { return }

        let width = uiView.bounds.width
        // SwiftUI may call updateUIView before layout is final; wait until we have a real width.
        guard width > 50 else { return }

        // Avoid re-applying the same width repeatedly.
        let roundedWidth = (width * UIScreen.main.scale).rounded() / UIScreen.main.scale
        guard context.coordinator.lastWidth != roundedWidth else { return }
        context.coordinator.lastWidth = roundedWidth

        // Anchored adaptive banner size for the current orientation.
        let adaptiveSize = currentOrientationAnchoredAdaptiveBanner(width: roundedWidth)
        if banner.adSize.size != adaptiveSize.size {
            banner.adSize = adaptiveSize
            banner.load(Request())
            context.coordinator.hasLoaded = true
        }

        if !context.coordinator.hasLoaded {
            banner.load(Request())
            context.coordinator.hasLoaded = true
        }

        // Ensure we have a root view controller (can be nil early in app lifecycle).
        if banner.rootViewController == nil {
            banner.rootViewController = BannerAdView.topMostViewController()
        }
    }

    // MARK: - Coordinator

    final class Coordinator {
        var lastWidth: CGFloat = 0
        var hasLoaded: Bool = false
        weak var banner: BannerView?
    }

    // MARK: - Helpers

    private static func topMostViewController() -> UIViewController? {
        let scenes = UIApplication.shared.connectedScenes
            .compactMap { $0 as? UIWindowScene }

        let window = scenes
            .flatMap { $0.windows }
            .first(where: { $0.isKeyWindow })
            ?? scenes.flatMap { $0.windows }.first

        var vc = window?.rootViewController
        while let presented = vc?.presentedViewController {
            vc = presented
        }
        return vc
    }

    private func currentOrientationAnchoredAdaptiveBanner(width: CGFloat) -> AdSize {
        currentOrientationAnchoredAdaptiveBanner(width: width)
    }
}
