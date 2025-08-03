
import SwiftUI
import GoogleMobileAds

// MARK: - Banner View Controller (Google Doc)
class BannerViewController: UIViewController {
    var bannerView: BannerView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        bannerView = BannerView(adSize: AdSizeBanner)
        
        bannerView.adUnitID = bannerID
        
        bannerView.rootViewController = self
        
        bannerView.delegate = self
        
        addBannerViewToView(bannerView)
        
        bannerView.load(Request())
    }
    
    func addBannerViewToView(_ bannerView: BannerView) {
        bannerView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(bannerView)
        view.addConstraints([
            NSLayoutConstraint(item: bannerView,
                             attribute: .bottom,
                             relatedBy: .equal,
                             toItem: view.safeAreaLayoutGuide,
                             attribute: .bottom,
                             multiplier: 1,
                             constant: 0),
            NSLayoutConstraint(item: bannerView,
                             attribute: .centerX,
                             relatedBy: .equal,
                             toItem: view,
                             attribute: .centerX,
                             multiplier: 1,
                             constant: 0)
        ])
    }
}



// MARK: - SwiftUI Wrapper
struct GoogleBannerView: UIViewControllerRepresentable {
    let adUnitID: String
    let adSize: AdSize
    
    // Test ad unit ID from Google documentation
    static let testBannerID = "ca-app-pub-3940256099942544/2435281174"
    
    init(adUnitID: String = testBannerID, adSize: AdSize = AdSizeBanner) {
        self.adUnitID = adUnitID
        self.adSize = adSize
    }
    
    func makeUIViewController(context: Context) -> BannerViewController {
        let bannerVC = BannerViewController()
        return bannerVC
    }
    
    func updateUIViewController(_ uiViewController: BannerViewController, context: Context) {
        uiViewController.bannerView?.adUnitID = adUnitID
    }
}


// MARK: - Banner View Controller Delegate
extension BannerViewController: BannerViewDelegate {
    func bannerViewDidReceiveAd(_ bannerView: BannerView) {
        print("bannerViewDidReceiveAd")
    }

    func bannerView(_ bannerView: BannerView, didFailToReceiveAdWithError error: Error) {
        print("bannerView:didFailToReceiveAdWithError: \(error.localizedDescription)")
    }

    func bannerViewDidRecordImpression(_ bannerView: BannerView) {
        print("bannerViewDidRecordImpression")
    }

    func bannerViewWillPresentScreen(_ bannerView: BannerView) {
        print("bannerViewWillPresentScreen")
    }

    func bannerViewWillDismissScreen(_ bannerView: BannerView) {
        print("bannerViewWillDismissScreen")
    }

    func bannerViewDidDismissScreen(_ bannerView: BannerView) {
        print("bannerViewDidDismissScreen")
    }
}
