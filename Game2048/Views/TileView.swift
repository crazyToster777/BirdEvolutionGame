
import SwiftUI


struct TileView: View {
    let value: Int
    let position: Position
    let rotationTrigger: Int
    let rotationDirection: MergeRotationGameBoardView.RotationDirection
    let shouldRotate: Bool
    
    @State private var rotationX: Double = 0
    @State private var rotationY: Double = 0
    @State private var lastTrigger: Int = 0
    @State private var isAnimating = false
    
    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 8)
                .fill(tileGradient)
                .frame(width: 70, height: 70)
            
            if value > 0 {
                Text("\(value)")
                    .font(.title2)
                    .fontWeight(.bold)
                    .foregroundColor(.white)
            }
        }
        .rotation3DEffect(.degrees(rotationX), axis: (1,0,0))
        .rotation3DEffect(.degrees(rotationY), axis: (0,1,0))
        .animation(.spring(response: 0.3, dampingFraction: 0.7), value: value)
        .onChange(of: rotationTrigger) { oldValue, newValue in
            if newValue != lastTrigger && shouldRotate {
                performDirectionalRotation()
                lastTrigger = newValue
            }
        }
    }
    
    private var tileGradient: LinearGradient {
        guard value > 0 else {
            return LinearGradient(colors: [Color.gray.opacity(0.3)], startPoint: .top, endPoint: .bottom)
        }
        
        let colors = getTileColors(for: value)
        return LinearGradient(
            colors: colors,
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }
    

    
    private func getTileColors(for value: Int) -> [Color] {
        switch value {
        case 2: return [.orange, .red]
        case 4: return [.red, .pink]
        case 8: return [.purple, .blue]
        case 16: return [.blue, .cyan]
        case 32: return [.green, .mint]
        case 64: return [.cyan, .blue]
        case 128: return [.pink, .purple]
        case 256: return [.mint, .green]
        case 512: return [.brown, .orange]
        case 1024: return [.indigo, .purple]
        case 2048: return [.yellow, .orange]
        default: return [.gray, .black]
        }
    }
    
    private func performDirectionalRotation() {
        guard !isAnimating && value > 0 else { return }
        
        isAnimating = true
        
        switch rotationDirection {
        case .leftSpin:
            withAnimation(.easeInOut(duration: 0.8)) {
                rotationY -= 360
            }
            
        case .rightSpin:
            withAnimation(.easeInOut(duration: 0.8)) {
                rotationY += 360
            }
            
        case .upFlip:
            withAnimation(.easeInOut(duration: 0.8)) {
                rotationX -= 360
            }
            
        case .downFlip:
            withAnimation(.easeInOut(duration: 0.8)) {
                rotationX += 360
            }
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.8) {
            isAnimating = false
            rotationX = 0
            rotationY = 0
        }
    }
}
