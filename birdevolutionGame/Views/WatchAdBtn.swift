import SwiftUI

struct WatchAdButton: View {

    let onReward: () -> Void
    @ObservedObject private var adManager = RewardedAdManager.shared

    var body: some View {
        Button {
            guard adManager.isAdReady else { return }
            if let rootVC = UIApplication.shared
                .connectedScenes
                .compactMap({ ($0 as? UIWindowScene)?.keyWindow })
                .first?
                .rootViewController {
                RewardedAdManager.shared.show(from: rootVC, onReward: onReward)
            }
        } label: {
            HStack(spacing: 8) {
                if adManager.isAdReady {
                    Image(systemName: "play.circle.fill")
                    Text("Watch ad to earn UNDO")
                } else {
                    ProgressView()
                        .tint(.white)
                    Text("Loading ad...")
                }
            }
            .font(.headline)
            .padding()
            .frame(maxWidth: .infinity)
            .background(adManager.isAdReady ? Color.blue : Color.gray)
            .foregroundColor(.white)
            .cornerRadius(12)
        }
        .disabled(!adManager.isAdReady)
        .padding(.horizontal, 80 * DeviceInfo.paddingMultiplier)
    }
}
