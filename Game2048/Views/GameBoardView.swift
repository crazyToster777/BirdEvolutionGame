
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
                            shouldRotate: mergedPositions.contains(Position(row: row, col: col)),
                            isNewTile: newTilePositions.contains(Position(row: row, col: col)),
                            newTileTrigger: newTileTrigger
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
                    playRandomSwipe()
                
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
    

    func playRandomSwipe() {
         // List of available swipe sounds
         let sounds = ["swipe1", "swipe2"]
         
         // Pick one at random
         if let chosen = sounds.randomElement(),
            let soundURL = Bundle.main.url(forResource: chosen, withExtension: "wav") {
             
             var soundID: SystemSoundID = 0
             AudioServicesCreateSystemSoundID(soundURL as CFURL, &soundID)
             AudioServicesPlaySystemSound(soundID)
         }
     }
    
    private func performMoveWithMergeRotation(_ direction: Direction) {
        let moveResult = game.move(direction)
        
        if !moveResult.mergedPositions.isEmpty {
            mergedPositions = moveResult.mergedPositions
            
            withAnimation(.easeInOut(duration: 0.15)) {
                rotationTrigger += 1
            }
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.7) {
                mergedPositions.removeAll()
            }
        }
        
        if !moveResult.newTilePositions.isEmpty {
            newTilePositions = moveResult.newTilePositions
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                newTilePositions.removeAll()
            }
        }
    }
}
