
import SwiftUI


struct ScoreCard: View {
    let title: String
    let value: Int
    let color: Color
    
    var body: some View {
        VStack(spacing: 4) {
            Text(title)
                .font(.caption)
                .fontWeight(.semibold)
                .foregroundColor(color)
                .opacity(0.8)
                .minimumScaleFactor(0.7)
                .lineLimit(1)
            
            Text("\(value)")
                .font(.title2)
                .fontWeight(.bold)
                .foregroundColor(.primary)
                .minimumScaleFactor(0.6)
                .lineLimit(1)
                .animation(.easeInOut(duration: 0.3), value: value)
        }
        .frame(maxWidth: .infinity)
        .frame(minHeight: 60)
        .padding(.horizontal, 12)
        .padding(.vertical, 10)
        .background(
            RoundedRectangle(cornerRadius: 10)
                .fill(color.opacity(0.1))
                .overlay(
                    RoundedRectangle(cornerRadius: 10)
                        .stroke(color.opacity(0.3), lineWidth: 1)
                )
        )
        .shadow(color: color.opacity(0.2), radius: 3, x: 0, y: 1)
    }
}
