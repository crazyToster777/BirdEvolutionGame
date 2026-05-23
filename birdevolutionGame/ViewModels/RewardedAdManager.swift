import GoogleMobileAds
import UIKit
import Combine

final class RewardedAdManager: NSObject, ObservableObject {

    static let shared = RewardedAdManager()

    @Published var isAdReady: Bool = false

    private var rewardedAd: RewardedAd?
    private let adUnitID = "ca-app-pub-2241716040388986/2293506596"

    func load() {
        RewardedAd.load(
            with: adUnitID,
            request: Request()
        ) { [weak self] ad, error in
            DispatchQueue.main.async {
                if let error = error {
                    print("Rewarded load error:", error)
                    self?.isAdReady = false
                    return
                }
                self?.rewardedAd = ad
                self?.isAdReady = true
            }
        }
    }

    func show(from viewController: UIViewController, onReward: @escaping () -> Void) {
        guard let ad = rewardedAd else { return }

        isAdReady = false
        rewardedAd = nil

        ad.present(from: topViewController(from: viewController)) {
            onReward()
        }

        load()
    }

    private func topViewController(from root: UIViewController) -> UIViewController {
        if let presented = root.presentedViewController {
            return topViewController(from: presented)
        }
        return root
    }
}
