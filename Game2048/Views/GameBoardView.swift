
import SwiftUI
struct MergeRotationGameBoardView: View {
    @ObservedObject var game: Game2048ViewModel
    @State private var rotationDirection: RotationDirection = .rightSpin
    @State private var mergedPositions: Set<Position> = []
    @State private var rotationTrigger = 0
    
    enum RotationDirection {
        case leftSpin
        case rightSpin 
        case upFlip
        case downFlip
    
    }
    
    var body: some View {
        VStack(spacing: 8) {
            ForEach(0..<4, id: \.self) { row in
                HStack(spacing: 8) {
                    ForEach(0..<4, id: \.self) { col in
                        TileView(
                            value: game.grid[row][col],
                            position: Position(row: row, col: col),
                            rotationTrigger: rotationTrigger,
                            rotationDirection: rotationDirection,
                            shouldRotate: mergedPositions.contains(Position(row: row, col: col))
                        )
                    }
                }
            }
        }
        .padding()
        .background(Color.gray.opacity(0.5))
        .cornerRadius(12)
        .gesture(
            DragGesture(minimumDistance: 30)
                .onEnded { value in
                    let deltaX = value.translation.width
                    let deltaY = value.translation.height
                    
                    if abs(deltaX) > abs(deltaY) {
                        if deltaX > 50 {
                            rotationDirection = .rightSpin
                            performMoveWithMergeRotation(.right)
                        } else if deltaX < -50 {
                            rotationDirection = .leftSpin
                            performMoveWithMergeRotation(.left)
                        }
                    } else {
                        if deltaY > 50 {
                            rotationDirection = .downFlip
                            performMoveWithMergeRotation(.down)
                        } else if deltaY < -50 {
                            rotationDirection = .upFlip
                            performMoveWithMergeRotation(.up)
                        }
                    }
                }
        )
    }
    
    private func performMoveWithMergeRotation(_ direction: Direction) {
        let mergedPositionsFromMove = game.move(direction)
        
        if !mergedPositionsFromMove.isEmpty {
            mergedPositions = mergedPositionsFromMove
            
            withAnimation(.easeInOut(duration: 0.15)) {
                rotationTrigger += 1
            }
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.7) {
                mergedPositions.removeAll()
            }
        }
    }
}
