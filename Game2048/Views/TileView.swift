
import SwiftUI


struct TileView: View {
    let value: Int
    let position: Position
    let rotationTrigger: Int
    let rotationDirection: MergeRotationGameBoardView.RotationDirection
    let shouldRotate: Bool
    let isNewTile: Bool
    let newTileTrigger: Int
    
    @State private var rotationX: Double = 0
    @State private var rotationY: Double = 0
    @State private var lastTrigger: Int = 0
    @State private var isAnimating = false
    @State private var scale: Double = 1.0
    @State private var lastNewTileTrigger: Int = 0
    
    init(value: Int, position: Position, rotationTrigger: Int, rotationDirection: MergeRotationGameBoardView.RotationDirection, shouldRotate: Bool, isNewTile: Bool, newTileTrigger: Int) {
        self.value = value
        self.position = position
        self.rotationTrigger = rotationTrigger
        self.rotationDirection = rotationDirection
        self.shouldRotate = shouldRotate
        self.isNewTile = isNewTile
        self.newTileTrigger = newTileTrigger
        
        _scale = State(initialValue: isNewTile ? 0.1 : 1.0)
    }
    
    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 8)
                .fill(tileGradient)
                .frame(width: 70, height: 70)
            
            
            if value > 0 {
                Image("\(value)") // loads the image set named "2"
                    .resizable()                // make it resizable
                    .scaledToFit()              // preserve aspect ratio
                    .frame(width: 70, height: 70)
                    .clipped()
                    .cornerRadius(8)
            }
        }
        .scaleEffect(scale)
        .rotation3DEffect(.degrees(rotationX), axis: (1,0,0))
        .rotation3DEffect(.degrees(rotationY), axis: (0,1,0))
        .animation(.spring(response: 0.3, dampingFraction: 0.7), value: value)
        .onChange(of: rotationTrigger) { oldValue, newValue in
            if newValue != lastTrigger && shouldRotate {
                performDirectionalRotation()
                lastTrigger = newValue
            }
        }
        .onAppear {
            if isNewTile {
                performNewTileAnimation()
            }
        }
        .onChange(of: newTileTrigger) { oldValue, newValue in
            if newValue != lastNewTileTrigger && isNewTile {
                performNewTileAnimation()
                lastNewTileTrigger = newValue
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
    private func getTileImg(for value: Int) -> String {
        switch value {
        case 2: return "2"
        case 4: return "4"
        case 8: return "8"
        case 16: return "16"
        case 32: return "32"
        case 64: return "64"
        case 128: return "128"
        default: return "2"
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
    
    private func performNewTileAnimation() {
        guard value > 0 else { return }
        
        withAnimation(.spring(response: 0.6, dampingFraction: 0.8, blendDuration: 0)) {
            scale = 1.0
        }
    }
}
