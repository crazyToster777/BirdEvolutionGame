import SwiftUI

struct PowerUpBarItemView: View {
    let type: PowerUpType
    let count: Int
    var isActive: Bool = false
    let onTap: () -> Void

    var body: some View {
        Button(action: onTap) {
            VStack(spacing: 4 * DeviceInfo.spacingMultiplier) {
                Text(type.emoji).font(.system(size: 28 * DeviceInfo.fontMultiplier))
                Text(isActive ? "ACTIVE" : type.displayName)
                    .font(.system(size: 10 * DeviceInfo.fontMultiplier, weight: .semibold))
                    .foregroundColor(isActive ? .cyan : .primary)
                    .lineLimit(1).minimumScaleFactor(0.7)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 8 * DeviceInfo.paddingMultiplier)
            .background(.ultraThinMaterial)
            .cornerRadius(12)
            .overlay(RoundedRectangle(cornerRadius: 12)
                .stroke(
                    isActive ? Color.cyan.opacity(0.9) : Color.yellow.opacity(count > 0 ? 0.6 : 0.2),
                    lineWidth: isActive ? 2 : 1.5
                )
            )
            .overlay(alignment: .topTrailing) {
                if isActive {
                    Image(systemName: "checkmark.circle.fill")
                        .font(.system(size: 14, weight: .bold))
                        .foregroundColor(.cyan)
                        .offset(x: 6, y: -6)
                } else {
                    Text("\(count)").font(.system(size: 12, weight: .bold)).foregroundColor(.white)
                        .frame(width: 20, height: 20)
                        .background(count > 0 ? Color.orange : Color.gray)
                        .clipShape(Circle()).offset(x: 6, y: -6)
                }
            }
            .shadow(color: isActive ? .cyan.opacity(0.6) : .clear, radius: isActive ? 8 : 0)
            .opacity(count > 0 || isActive ? 1.0 : 0.4)
            .animation(.easeInOut(duration: 0.3), value: isActive)
        }
        .disabled(count == 0 && !isActive)
    }
}

// MARK: - Ad Earn Variant (shown when a power-up type is exhausted)

struct PowerUpAdItemView: View {
    let type: PowerUpType
    let onReward: () -> Void
    @ObservedObject private var adManager = RewardedAdManager.shared

    var body: some View {
        Button(action: handleTap) {
            VStack(spacing: 4 * DeviceInfo.spacingMultiplier) {
                Text(type.emoji)
                    .font(.system(size: 28 * DeviceInfo.fontMultiplier))

                if adManager.isAdReady {
                    Text("Watch Ad")
                        .font(.system(size: 10 * DeviceInfo.fontMultiplier, weight: .semibold))
                        .foregroundColor(.primary)
                        .lineLimit(1)
                        .minimumScaleFactor(0.7)
                } else {
                    ProgressView()
                        .tint(.primary)
                        .scaleEffect(0.7)
                        .frame(height: 14 * DeviceInfo.fontMultiplier)
                }
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 8 * DeviceInfo.paddingMultiplier)
            .background(.ultraThinMaterial)
            .cornerRadius(12)
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(
                        Color.yellow.opacity(adManager.isAdReady ? 0.8 : 0.25),
                        lineWidth: 1.5
                    )
            )
            .overlay(alignment: .topTrailing) {
                Image(systemName: adManager.isAdReady ? "play.fill" : "ellipsis")
                    .font(.system(size: 7, weight: .black))
                    .foregroundColor(.white)
                    .frame(width: 18, height: 18)
                    .background(adManager.isAdReady ? Color.yellow : Color.gray.opacity(0.6))
                    .clipShape(Circle())
                    .offset(x: 6, y: -6)
            }
            .opacity(adManager.isAdReady ? 1.0 : 0.55)
        }
        .disabled(!adManager.isAdReady)
    }

    private func handleTap() {
        guard adManager.isAdReady,
              let rootVC = UIApplication.shared
                .connectedScenes
                .compactMap({ ($0 as? UIWindowScene)?.keyWindow })
                .first?.rootViewController
        else { return }
        RewardedAdManager.shared.show(from: rootVC, onReward: onReward)
    }
}

#Preview {
    HStack(spacing: 12) {
        PowerUpBarItemView(type: .energyRush, count: 3, onTap: {})
        PowerUpBarItemView(type: .freeze, count: 0, onTap: {})
        PowerUpBarItemView(type: .smash, count: 1, onTap: {})
        PowerUpBarItemView(type: .hint, count: 5, onTap: {})
    }
    .padding()
    .background(Color.gray.opacity(0.3))
}
