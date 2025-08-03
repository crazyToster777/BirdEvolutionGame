
import SwiftUI
struct WinView: View {
    let score: Int
    let maxTile: Int
    let onContinue: VoidCallback
    let onNewGame: VoidCallback
    
    @Environment(\.dismiss) private var dismiss
    @State private var confettiOffset: CGFloat = -50
    @State private var crownRotation: Double = 0
    @State private var showStats = false
    
    var body: some View {
        NavigationView {
            VStack(spacing: 32) {
                Spacer()
                
                // Crown and title
                VStack(spacing: 20) {
                    Text("👑")
                        .font(.system(size: 80))
                        .rotationEffect(.degrees(crownRotation))
                    
                    Text("Victory!")
                        .font(.largeTitle.bold())
                        .foregroundStyle(
                            LinearGradient(
                                colors: [.yellow, .orange],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                    
                    Text("You reached \(maxTile)!")
                        .font(.title2)
                        .foregroundColor(.secondary)
                }
                
                // Stats card
                VStack(spacing: 16) {
                    HStack {
                        Text("🏆 Achievement Stats")
                            .font(.headline)
                            .foregroundColor(.primary)
                        
                        Spacer()
                        
                        Button {
                            withAnimation(.spring()) {
                                showStats.toggle()
                            }
                        } label: {
                            Image(systemName: showStats ? "chevron.up" : "chevron.down")
                                .foregroundColor(.blue)
                        }
                    }
                    
                    if showStats {
                        VStack(spacing: 12) {
                            HStack {
                                Text("Max Tile:")
                                    .foregroundColor(.secondary)
                                Spacer()
                                Text("\(maxTile)")
                                    .fontWeight(.bold)
                                    .foregroundColor(.orange)
                            }
                            
                            HStack {
                                Text("Final Score:")
                                    .foregroundColor(.secondary)
                                Spacer()
                                Text("\(score)")
                                    .fontWeight(.bold)
                                    .foregroundColor(.blue)
                            }
                            
                            Divider()
                            
                            Text("🎯 Keep playing to reach \(maxTile * 2)!")
                                .font(.caption)
                                .foregroundColor(.green)
                                .fontWeight(.medium)
                        }
                        .transition(.opacity.combined(with: .move(edge: .top)))
                    }
                }
                .padding()
                .background(Color(.systemGray6))
                .cornerRadius(12)
                
                Spacer()
                
                // Action buttons
                VStack(spacing: 12) {
                    Button {
                        dismiss()
                        onContinue()
                    } label: {
                        HStack {
                            Image(systemName: "play.fill")
                            Text("Continue Playing")
                        }
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.blue.gradient)
                        .foregroundColor(.white)
                        .cornerRadius(12)
                        .shadow(color: .blue.opacity(0.3), radius: 4, x: 0, y: 2)
                    }
                    
                    Button {
                        dismiss()
                        onNewGame()
                    } label: {
                        HStack {
                            Image(systemName: "arrow.clockwise")
                            Text("New Game")
                        }
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.green.gradient)
                        .foregroundColor(.white)
                        .cornerRadius(12)
                        .shadow(color: .green.opacity(0.3), radius: 4, x: 0, y: 2)
                    }
                }
            }
            .padding()
            .navigationTitle("🎉 You Win!")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Close") {
                        dismiss()
                        onContinue()
                    }
                    .foregroundColor(.blue)
                }
            }
        }
        .onAppear {
            startAnimations()
        }
    }
    
    private func startAnimations() {
        withAnimation(.easeInOut(duration: 3.0).repeatForever(autoreverses: true)) {
            crownRotation = 20
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            confettiOffset = 200
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            withAnimation(.spring()) {
                showStats = true
            }
        }
    }
}
