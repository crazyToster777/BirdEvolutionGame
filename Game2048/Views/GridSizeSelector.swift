import SwiftUI

struct GridSizeSelector: View {
    @EnvironmentObject var game: Game2048ViewModel
    @Environment(\.dismiss) private var dismiss
    @State private var selectedSize: GridSize
    @State private var showConfirmation = false
    
    init(currentSize: GridSize) {
        _selectedSize = State(initialValue: currentSize)
    }
    
    var body: some View {
        NavigationView {
            VStack(spacing: 24) {
                Text("Choose Grid Size")
                    .font(.title2.bold())
                    .padding(.top)
                
                ForEach(GridSize.allCases, id: \.self) { size in
                    GridSizeCard(
                        gridSize: size,
                        isSelected: selectedSize == size,
                        isCurrent: game.gridSize == size
                    )
                    .onTapGesture {
                        selectedSize = size
                    }
                }
                
                Spacer()
                
                if selectedSize != game.gridSize {
                    Button {
                        if game.gameState.score > 0 {
                            showConfirmation = true
                        } else {
                            applyGridSize()
                        }
                    } label: {
                        HStack {
                            Image(systemName: "checkmark.circle.fill")
                            Text("Apply")
                        }
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.blue.gradient)
                        .foregroundColor(.white)
                        .cornerRadius(12)
                    }
                    .padding(.horizontal)
                }
            }
            .padding()
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Close") {
                        dismiss()
                    }
                }
            }
            .alert("Start New Game?", isPresented: $showConfirmation) {
                Button("Cancel", role: .cancel) { }
                Button("Continue", role: .destructive) {
                    applyGridSize()
                }
            } message: {
                Text("Changing grid size will start a new game. Your current progress will be saved to statistics.")
            }
        }
    }
    
    private func applyGridSize() {
        withAnimation {
            game.changeGridSize(to: selectedSize)
        }
        dismiss()
    }
}

struct GridSizeCard: View {
    let gridSize: GridSize
    let isSelected: Bool
    let isCurrent: Bool
    
    var body: some View {
        HStack(spacing: 16) {
            // Emoji icon
            Text(gridSize.emoji)
                .font(.system(size: 40))
            
            VStack(alignment: .leading, spacing: 4) {
                Text(gridSize.displayName)
                    .font(.headline)
                
                Text("\(gridSize.rawValue)×\(gridSize.rawValue) grid")
                    .font(.caption)
                    .foregroundColor(.secondary)
                
                if isCurrent {
                    Text("Current")
                        .font(.caption2)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 2)
                        .background(Color.green.opacity(0.2))
                        .foregroundColor(.green)
                        .cornerRadius(4)
                }
            }
            
            Spacer()
            
            if isSelected {
                Image(systemName: "checkmark.circle.fill")
                    .foregroundColor(.blue)
                    .font(.title2)
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(isSelected ? Color.blue.opacity(0.1) : Color(.systemGray6))
        )
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(isSelected ? Color.blue : Color.clear, lineWidth: 2)
        )
    }
}

#Preview {
    GridSizeSelector(currentSize: .small)
        .environmentObject(Game2048ViewModel())
}
