import SwiftUI

struct HintOverlay: View {
    let message: String
    let arrowDirection: ArrowDirection
    let onDismiss: () -> Void
    
    @State private var isVisible = false
    
    var body: some View {
        VStack(spacing: 10) {
            if arrowDirection == .down {
                arrow
            }
            
            HStack {
                Text(message)
                    .font(.subheadline.bold())
                    .foregroundColor(.white)
                    .padding()
                
                Button(action: onDismiss) {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundColor(.white.opacity(0.8))
                        .font(.title3)
                }
                .padding(.trailing, 12)
            }
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(Color.blue)
                    .shadow(color: .black.opacity(0.3), radius: 10, x: 0, y: 5)
            )
            
            if arrowDirection == .up {
                arrow
            }
        }
        .scaleEffect(isVisible ? 1.0 : 0.8)
        .opacity(isVisible ? 1.0 : 0.0)
        .onAppear {
            withAnimation(.spring(response: 0.5, dampingFraction: 0.7)) {
                isVisible = true
            }
        }
    }
    
    private var arrow: some View {
        Image(systemName: arrowIcon)
            .font(.system(size: 30))
            .foregroundColor(.blue)
    }
    
    private var arrowIcon: String {
        switch arrowDirection {
        case .up: return "arrowtriangle.up.fill"
        case .down: return "arrowtriangle.down.fill"
        case .left: return "arrowtriangle.left.fill"
        case .right: return "arrowtriangle.right.fill"
        }
    }
}

enum ArrowDirection {
    case up, down, left, right
}

#Preview {
    ZStack {
        Color.gray.opacity(0.3)
            .ignoresSafeArea()
        
        HintOverlay(
            message: "👆 Swipe in any direction to move tiles",
            arrowDirection: .down,
            onDismiss: {}
        )
    }
}
