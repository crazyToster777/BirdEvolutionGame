import SwiftUI

struct WatchAdButton: View {

    let onReward: () -> Void

    var body: some View {
        Button {
            if let rootVC = UIApplication.shared
                .connectedScenes
                .compactMap({ ($0 as? UIWindowScene)?.keyWindow })
                .first?
                .rootViewController {

                RewardedAdManager.shared.show(
                    from: rootVC,
                    onReward: onReward
                )
            }
        } label: {
            Text("Watch ad to earn UNDO")
                .font(.headline)
                .padding()
                .background(Color.blue)
                .foregroundColor(.white)
                .cornerRadius(12)
        }
    }
}
