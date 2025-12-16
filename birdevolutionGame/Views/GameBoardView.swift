
import SwiftUI
import AVFoundation

struct MergeRotationGameBoardView: View {
    @ObservedObject var game: BirdEvolutionGameViewModel
    @EnvironmentObject var audioManager: AudioManager
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
                            tileSize: tileSize,
                            powerUpType: game.gameState.powerUpGrid[row][col],
                            onTap: {
                                game.activatePowerUp(at: Position(row: row, col: col))
                            }
                        )
                    }
                }
            }
        }
        .padding()
        .background(Color.clear)
        .cornerRadius(12)
        .gesture(
            DragGesture(minimumDistance: GameConstants.minimumDragDistance)
                .onEnded { value in
                    let deltaX = value.translation.width
                    let deltaY = value.translation.height
                    
                    // Play swipe sound and start music on first swipe
                    audioManager.playSwipeSound()
                    audioManager.playBackgroundMusic()
                
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
