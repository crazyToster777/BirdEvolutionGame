import GoogleMobileAds
import UIKit

final class RewardedAdManager: NSObject {

    static let shared = RewardedAdManager()
    private var rewardedAd: RewardedAd?

    private let adUnitID = "ca-app-pub-2241716040388986/2293506596" // TEST rewarded

    func load() {
        RewardedAd.load(
            with: adUnitID,
            request: Request()
        ) { [weak self] ad, error in
            if let error = error {
                print("Rewarded load error:", error)
                return
            }
            self?.rewardedAd = ad
        }
    }

    func show(from viewController: UIViewController, onReward: @escaping () -> Void) {
        guard let ad = rewardedAd else {
            print("Rewarded ad not ready")
            return
        }

        ad.present(from: viewController) {
            // 🔥 This is called ONLY if user earned reward
            onReward()
        }

        rewardedAd = nil
        load() // preload next
    }
}
