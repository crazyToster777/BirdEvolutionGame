import SwiftUI

struct PowerUpBarItemView: View {
    let type: PowerUpType
    let count: Int
    let onTap: () -> Void

    var body: some View {
        Button(action: onTap) {
            VStack(spacing: 4 * DeviceInfo.spacingMultiplier) {
                Text(type.emoji).font(.system(size: 28 * DeviceInfo.fontMultiplier))
                Text(type.displayName)
                    .font(.system(size: 10 * DeviceInfo.fontMultiplier, weight: .semibold))
                    .foregroundColor(.primary).lineLimit(1).minimumScaleFactor(0.7)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 8 * DeviceInfo.paddingMultiplier)
            .background(.ultraThinMaterial)
            .cornerRadius(12)
            .overlay(RoundedRectangle(cornerRadius: 12)
                .stroke(Color.yellow.opacity(count > 0 ? 0.6 : 0.2), lineWidth: 1.5))
            .overlay(alignment: .topTrailing) {
                Text("\(count)").font(.system(size: 12, weight: .bold)).foregroundColor(.white)
                    .frame(width: 20, height: 20)
                    .background(count > 0 ? Color.orange : Color.gray)
                    .clipShape(Circle()).offset(x: 6, y: -6)
            }
            .opacity(count > 0 ? 1.0 : 0.4)
        }
        .disabled(count == 0)
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
