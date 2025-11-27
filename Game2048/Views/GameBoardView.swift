
import SwiftUI
import AVFoundation
import AudioToolbox

struct MergeRotationGameBoardView: View {
    @ObservedObject var game: Game2048ViewModel
    @State private var rotationDirection: RotationDirection = .rightSpin
    @State private var mergedPositions: Set<Position> = []
    @State private var newTilePositions: Set<Position> = []
    @State private var rotationTrigger = 0
    @State private var newTileTrigger = 0
    
    private var tileSize: CGFloat {
        game.gridSize.tileSize
    }
    
    private var spacing: CGFloat {
        game.gridSize.spacing
    }
    
    enum RotationDirection {
        case leftSpin
        case rightSpin 
        case upFlip
        case downFlip
    
    }
    
    var body: some View {
        VStack(spacing: spacing) {
            ForEach(0..<game.gridSize.rawValue, id: \.self) { row in
                HStack(spacing: spacing) {
                    ForEach(0..<game.gridSize.rawValue, id: \.self) { col in
                        TileView(
                            value: game.grid[row][col],
                            position: Position(row: row, col: col),
                            rotationTrigger: rotationTrigger,
                            rotationDirection: rotationDirection,
                            shouldRotate: mergedPositions.contains(Position(row: row, col: col)),
                            isNewTile: newTilePositions.contains(Position(row: row, col: col)),
                            newTileTrigger: newTileTrigger,
                            tileSize: tileSize
                        )
                    }
                }
            }
        }
        .padding()
        .background(Color.gray.opacity(0.5))
        .cornerRadius(12)
        .gesture(
            DragGesture(minimumDistance: GameConstants.minimumDragDistance)
                .onEnded { value in
                    let deltaX = value.translation.width
                    let deltaY = value.translation.height
                    playRandomSwipe()
                
                    if abs(deltaX) > abs(deltaY) {
                        if deltaX > GameConstants.swipeThreshold {
                            rotationDirection = .rightSpin
                            performMoveWithMergeRotation(.right)
                        } else if deltaX < -GameConstants.swipeThreshold {
                            rotationDirection = .leftSpin
                            performMoveWithMergeRotation(.left)
                        }
                    } else {
                        if deltaY > GameConstants.swipeThreshold {
                            rotationDirection = .downFlip
                            performMoveWithMergeRotation(.down)
                        } else if deltaY < -GameConstants.swipeThreshold {
                            rotationDirection = .upFlip
                            performMoveWithMergeRotation(.up)
                        }
                    }
                }
        )
    }
    

    func playRandomSwipe() {
         // List of available swipe sounds
         
         // Pick one at random
         if let chosen = GameConstants.swipeSounds.randomElement(),
            let soundURL = Bundle.main.url(forResource: chosen, withExtension: GameConstants.audioExtension) {
             
             var soundID: SystemSoundID = 0
             AudioServicesCreateSystemSoundID(soundURL as CFURL, &soundID)
             AudioServicesPlaySystemSound(soundID)
         }
     }
    
    private func performMoveWithMergeRotation(_ direction: Direction) {
        let moveResult = game.move(direction)
        
        if !moveResult.mergedPositions.isEmpty {
            mergedPositions = moveResult.mergedPositions
            
            withAnimation(.easeInOut(duration: GameConstants.mergeRotationDuration)) {
                rotationTrigger += 1
            }
            
            DispatchQueue.main.asyncAfter(deadline: .now() + GameConstants.mergeRotationDelay) {
                mergedPositions.removeAll()
            }
        }
        
        if !moveResult.newTilePositions.isEmpty {
            newTilePositions = moveResult.newTilePositions
            
            DispatchQueue.main.asyncAfter(deadline: .now() + GameConstants.newTileDelay) {
                newTilePositions.removeAll()
            }
        }
    }
}
